#!/usr/bin/env python3
"""Preserve URDF visual colors as explicit MJCF materials."""

from __future__ import annotations

import argparse
from dataclasses import asdict, dataclass
import hashlib
import json
import math
import os
from pathlib import Path
import re
import stat
import sys
import xml.etree.ElementTree as ET


DEFAULT_RGBA = "0.75294 0.75294 0.75294 1"
GENERATED_PREFIX = "urdf_visual_"


class VisualMaterialError(RuntimeError):
    """Raised when URDF material data cannot be applied safely."""


@dataclass(frozen=True)
class VisualStyle:
    source_name: str
    rgba: str
    material_name: str


@dataclass(frozen=True)
class MaterialSummary:
    source_visuals: int
    source_styles: int
    styled_geoms: int
    unmatched_visual_geoms: int
    generated_materials: int


def _canonical_rgba(raw: str, *, context: str) -> str:
    parts = raw.split()
    if len(parts) == 3:
        parts.append("1")
    if len(parts) != 4:
        raise VisualMaterialError(f"{context} must contain three or four RGBA values")
    try:
        values = [float(value) for value in parts]
    except ValueError as exc:
        raise VisualMaterialError(f"{context} contains a non-numeric RGBA value") from exc
    if any(not math.isfinite(value) or value < 0.0 or value > 1.0 for value in values):
        raise VisualMaterialError(f"{context} RGBA values must be finite and within [0, 1]")
    return " ".join(f"{value:.9g}" for value in values)


def _material_slug(name: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "_", name.lower()).strip("_")
    return slug[:40] or "color"


def _style(source_name: str, rgba: str) -> VisualStyle:
    canonical = _canonical_rgba(rgba, context=f"material {source_name!r}")
    digest = hashlib.sha256(f"{source_name}\0{canonical}".encode()).hexdigest()[:8]
    return VisualStyle(
        source_name=source_name,
        rgba=canonical,
        material_name=f"{GENERATED_PREFIX}{_material_slug(source_name)}_{digest}",
    )


def _global_materials(urdf_root: ET.Element) -> dict[str, str]:
    colors: dict[str, str] = {}
    for material in urdf_root.findall("material"):
        name = material.get("name")
        color = material.find("color")
        if name and color is not None and color.get("rgba"):
            colors[name] = _canonical_rgba(
                color.get("rgba", ""), context=f"global material {name!r}"
            )
    return colors


def _visual_style(
    visual: ET.Element, global_materials: dict[str, str]
) -> VisualStyle:
    material = visual.find("material")
    source_name = "default"
    rgba = DEFAULT_RGBA
    if material is not None:
        source_name = material.get("name") or "inline"
        color = material.find("color")
        if color is not None and color.get("rgba"):
            rgba = color.get("rgba", DEFAULT_RGBA)
        elif material.get("name") in global_materials:
            rgba = global_materials[material.get("name", "")]
    return _style(source_name, rgba)


def _source_styles(
    urdf_root: ET.Element,
) -> tuple[
    dict[tuple[str, str], VisualStyle],
    dict[str, VisualStyle],
    int,
]:
    global_materials = _global_materials(urdf_root)
    by_link_mesh: dict[tuple[str, str], VisualStyle] = {}
    mesh_candidates: dict[str, set[VisualStyle]] = {}
    source_visuals = 0
    for link in urdf_root.findall("link"):
        link_name = link.get("name")
        if not link_name:
            continue
        for visual in link.findall("visual"):
            mesh = visual.find("geometry/mesh")
            filename = mesh.get("filename") if mesh is not None else None
            if not filename:
                continue
            source_visuals += 1
            mesh_name = Path(filename).stem
            style = _visual_style(visual, global_materials)
            key = (link_name, mesh_name)
            previous = by_link_mesh.get(key)
            if previous is not None and previous != style:
                raise VisualMaterialError(
                    f"URDF assigns conflicting materials to {link_name}/{mesh_name}"
                )
            by_link_mesh[key] = style
            mesh_candidates.setdefault(mesh_name, set()).add(style)
    by_unique_mesh = {
        mesh_name: next(iter(styles))
        for mesh_name, styles in mesh_candidates.items()
        if len(styles) == 1
    }
    return by_link_mesh, by_unique_mesh, source_visuals


def _is_visual_mesh(geom: ET.Element) -> bool:
    if geom.get("type") != "mesh":
        return False
    return (
        geom.get("class") in {"visual", "visualgeom"}
        or geom.get("group") == "2"
        or geom.get("name", "").endswith("_visual")
    )


def _ensure_materials(asset: ET.Element, styles: set[VisualStyle]) -> int:
    for material in list(asset.findall("material")):
        if material.get("name", "").startswith(GENERATED_PREFIX):
            asset.remove(material)

    children = list(asset)
    insert_at = 0
    for index, child in enumerate(children):
        if child.tag == "material":
            insert_at = index + 1
    for style in sorted(styles, key=lambda item: item.material_name):
        asset.insert(
            insert_at,
            ET.Element(
                "material",
                attrib={"name": style.material_name, "rgba": style.rgba},
            ),
        )
        insert_at += 1
    return len(styles)


def _write_atomic(tree: ET.ElementTree, path: Path) -> None:
    temporary = path.with_name(f".{path.name}.materials.tmp")
    mode = stat.S_IMODE(path.stat().st_mode)
    try:
        tree.write(temporary, encoding="utf-8", xml_declaration=False)
        os.chmod(temporary, mode)
        os.replace(temporary, path)
    finally:
        temporary.unlink(missing_ok=True)


def apply_urdf_visual_materials(urdf_path: Path, mjcf_path: Path) -> MaterialSummary:
    urdf_path = urdf_path.resolve()
    mjcf_path = mjcf_path.resolve()
    if not urdf_path.is_file():
        raise VisualMaterialError(f"URDF does not exist: {urdf_path}")
    if not mjcf_path.is_file():
        raise VisualMaterialError(f"MJCF does not exist: {mjcf_path}")

    urdf_root = ET.parse(urdf_path).getroot()
    by_link_mesh, by_unique_mesh, source_visuals = _source_styles(urdf_root)
    tree = ET.parse(mjcf_path)
    root = tree.getroot()
    asset = root.find("asset")
    if asset is None:
        asset = ET.Element("asset")
        root.insert(0, asset)

    styles = set(by_link_mesh.values())
    generated_materials = _ensure_materials(asset, styles)
    styled_geoms = 0
    unmatched_visual_geoms = 0
    for body in root.iter("body"):
        link_name = body.get("name", "")
        for geom in body.findall("geom"):
            if not _is_visual_mesh(geom):
                continue
            mesh_name = geom.get("mesh", "")
            style = by_link_mesh.get((link_name, mesh_name))
            if style is None:
                style = by_unique_mesh.get(mesh_name)
            if style is None:
                unmatched_visual_geoms += 1
                continue
            geom.set("material", style.material_name)
            geom.set("rgba", style.rgba)
            styled_geoms += 1

    _write_atomic(tree, mjcf_path)
    return MaterialSummary(
        source_visuals=source_visuals,
        source_styles=len(styles),
        styled_geoms=styled_geoms,
        unmatched_visual_geoms=unmatched_visual_geoms,
        generated_materials=generated_materials,
    )


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--urdf", type=Path, required=True)
    parser.add_argument("--mjcf", type=Path, required=True)
    return parser.parse_args()


def main() -> int:
    args = _parse_args()
    try:
        summary = apply_urdf_visual_materials(args.urdf, args.mjcf)
    except (OSError, ET.ParseError, VisualMaterialError) as exc:
        print(f"[ERROR] URDF visual material application failed: {exc}", file=sys.stderr)
        return 1
    print("[INFO] URDF visual materials " + json.dumps(asdict(summary), sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
