from __future__ import annotations

import importlib.util
from pathlib import Path
import unittest


REPO_ROOT = Path(__file__).resolve().parents[1]
SCRIPT_PATH = REPO_ROOT / "scripts" / "run_matrix_sonic.py"
SPEC = importlib.util.spec_from_file_location("run_matrix_sonic", SCRIPT_PATH)
assert SPEC is not None and SPEC.loader is not None
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class MatrixSonicRuntimeTest(unittest.TestCase):
    def test_root_up_z_is_one_for_upright_quaternion(self) -> None:
        self.assertAlmostEqual(MODULE._root_up_z([0, 0, 0, 1, 0, 0, 0]), 1.0)

    def test_root_up_z_is_negative_for_upside_down_quaternion(self) -> None:
        self.assertAlmostEqual(MODULE._root_up_z([0, 0, 0, 0, 1, 0, 0]), -1.0)


if __name__ == "__main__":
    unittest.main()
