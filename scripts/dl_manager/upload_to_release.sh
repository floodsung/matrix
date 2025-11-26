#!/bin/bash
set -e

# ============================================================================
# 使用 GitHub CLI 上传文件到 Release
# 需要先安装: sudo apt install gh
# 需要先登录: gh auth login
# ============================================================================

VERSION="${1:-2.0.8}"
REPO="Alphabaijinde/matrix"
RELEASE_DIR="releases/chunks/${VERSION}"

if ! command -v gh &> /dev/null; then
    echo "错误: 需要安装 GitHub CLI"
    echo "安装: sudo apt install gh"
    echo "登录: gh auth login"
    exit 1
fi

echo "=========================================="
echo "上传文件到 GitHub Release v${VERSION}"
echo "=========================================="

# 检查 Release 是否存在
if ! gh release view "v${VERSION}" --repo "$REPO" &>/dev/null; then
    echo "创建 Release v${VERSION}..."
    gh release create "v${VERSION}" \
        --repo "$REPO" \
        --title "MATRiX v${VERSION} - Modular Chunk Packages" \
        --notes-file "${RELEASE_DIR}/README.md" \
        --draft
fi

# 上传基础包
echo "上传基础包..."
gh release upload "v${VERSION}" \
    "${RELEASE_DIR}/base-${VERSION}.tar.gz" \
    --repo "$REPO" \
    --clobber

# 上传共享资源包
echo "上传共享资源包..."
gh release upload "v${VERSION}" \
    "${RELEASE_DIR}/shared-${VERSION}.tar.gz" \
    --repo "$REPO" \
    --clobber

# 上传地图包
echo "上传地图包..."
for map_tar in "${RELEASE_DIR}/maps"/*.tar.gz; do
    if [ -f "$map_tar" ]; then
        echo "  上传: $(basename "$map_tar")"
        gh release upload "v${VERSION}" \
            "$map_tar" \
            --repo "$REPO" \
            --clobber
    fi
done

# 上传清单文件
if [ -f "${RELEASE_DIR}/manifest-${VERSION}.json" ]; then
    echo "上传清单文件..."
    gh release upload "v${VERSION}" \
        "${RELEASE_DIR}/manifest-${VERSION}.json" \
        --repo "$REPO" \
        --clobber
fi

echo ""
echo "✅ 所有文件已上传！"
echo ""
echo "发布 Release:"
echo "  gh release edit v${VERSION} --repo ${REPO} --draft=false"
