#!/bin/bash
set -e

# ============================================================================
# 将打包好的Chunk文件组织成发布版本
# 压缩包直接放到 releases/ 目录，用于上传到GitHub Releases
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
CHUNK_SOURCE="/home/user/work/workspace/jszr_mujoco_ue2/dist/chunks"
VERSION="${1:-2.0.8}"
RELEASE_DIR="${PROJECT_ROOT}/releases"
TEMP_DIR="${PROJECT_ROOT}/releases/.temp_${VERSION}"

log() {
    echo "[$(date '+%H:%M:%S')] $*"
}

log_section() {
    echo ""
    echo "===== $* ====="
    echo "$(printf '=%.0s' {1..60})"
}

error_exit() {
    log "ERROR: $*"
    exit 1
}

# 检查源目录
if [ ! -d "${CHUNK_SOURCE}/${VERSION}" ]; then
    error_exit "找不到源目录: ${CHUNK_SOURCE}/${VERSION}"
fi

log_section "[1] 准备发布目录结构"
{
    mkdir -p "${TEMP_DIR}"/{base,shared,maps}
    mkdir -p "${RELEASE_DIR}"
    log "✓ 创建临时打包目录: ${TEMP_DIR}"
    log "✓ 发布目录: ${RELEASE_DIR} (压缩包将直接放在这里)"
}

log_section "[2] 复制基础包 (Chunk 0)"
{
    BASE_SOURCE="${CHUNK_SOURCE}/${VERSION}/package_base"
    if [ -d "$BASE_SOURCE" ]; then
        log "复制基础包文件..."
        rsync -av --exclude="*.log" "$BASE_SOURCE/" "${TEMP_DIR}/base/"
        
        # 创建基础包压缩文件，直接放到 releases/ 目录
        log "压缩基础包..."
        cd "${TEMP_DIR}"
        tar -czf "${RELEASE_DIR}/base-${VERSION}.tar.gz" -C base .
        log "✓ 基础包: ${RELEASE_DIR}/base-${VERSION}.tar.gz ($(du -sh "${RELEASE_DIR}/base-${VERSION}.tar.gz" | cut -f1))"
    else
        error_exit "找不到基础包目录: $BASE_SOURCE"
    fi
}

log_section "[3] 复制共享资源包 (Chunk 1)"
{
    SHARED_SOURCE="${CHUNK_SOURCE}/${VERSION}/package_shared"
    if [ -d "$SHARED_SOURCE" ]; then
        log "复制共享资源包文件..."
        rsync -av --exclude="*.log" "$SHARED_SOURCE/" "${TEMP_DIR}/shared/"
        
        # 创建共享资源包压缩文件，直接放到 releases/ 目录
        log "压缩共享资源包..."
        cd "${TEMP_DIR}"
        tar -czf "${RELEASE_DIR}/shared-${VERSION}.tar.gz" -C shared .
        log "✓ 共享资源包: ${RELEASE_DIR}/shared-${VERSION}.tar.gz ($(du -sh "${RELEASE_DIR}/shared-${VERSION}.tar.gz" | cut -f1))"
    else
        log "⚠️  共享资源包目录不存在，跳过"
    fi
}

log_section "[4] 复制地图包 (Chunk 11-24)"
{
    MAPS_SOURCE="${CHUNK_SOURCE}/${VERSION}/package_maps"
    if [ -d "$MAPS_SOURCE" ]; then
        log "复制地图包文件..."
        
        for map_dir in "$MAPS_SOURCE"/*/; do
            if [ -d "$map_dir" ]; then
                map_name=$(basename "$map_dir")
                if [ -n "$(ls -A "$map_dir" 2>/dev/null)" ]; then
                    log "  处理地图: $map_name"
                    
                    # 复制到临时目录
                    temp_map_dir="${TEMP_DIR}/maps/${map_name}"
                    mkdir -p "$temp_map_dir"
                    rsync -av "$map_dir" "$temp_map_dir/"
                    
                    # 为每个地图创建压缩文件，直接放到 releases/ 目录
                    cd "${TEMP_DIR}/maps"
                    tar -czf "${RELEASE_DIR}/${map_name}-${VERSION}.tar.gz" -C "${map_name}" .
                    map_size=$(du -sh "${RELEASE_DIR}/${map_name}-${VERSION}.tar.gz" | cut -f1)
                    log "    ✓ ${map_name}-${VERSION}.tar.gz ($map_size)"
                fi
            fi
        done
        
        log "✓ 所有地图包已复制并压缩"
    else
        log "⚠️  地图包目录不存在，跳过"
    fi
}

log_section "[5] 生成清单文件"
{
    cd "${RELEASE_DIR}"
    
    cat > "manifest-${VERSION}.json" << EOF
{
  "version": "${VERSION}",
  "release_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "packages": {
    "base": {
      "file": "base-${VERSION}.tar.gz",
      "required": true,
      "description": "基础包 (Chunk 0) - 包含EmptyWorld和核心蓝图",
      "size": $(stat -f%z "base-${VERSION}.tar.gz" 2>/dev/null || stat -c%s "base-${VERSION}.tar.gz" 2>/dev/null || echo 0)
    },
    "shared": {
      "file": "shared-${VERSION}.tar.gz",
      "required": false,
      "description": "共享资源包 (Chunk 1) - 包含Fab/Warehouse和StarterContent共享资源",
      "size": $(stat -f%z "shared-${VERSION}.tar.gz" 2>/dev/null || stat -c%s "shared-${VERSION}.tar.gz" 2>/dev/null || echo 0)
    },
    "maps": [
EOF

    # 添加地图包信息
    cd "${RELEASE_DIR}"
    first=true
    for map_tar in *-${VERSION}.tar.gz; do
        # 跳过 base 和 shared
        if [[ "$map_tar" == base-* ]] || [[ "$map_tar" == shared-* ]]; then
            continue
        fi
        if [ -f "$map_tar" ]; then
            map_name=$(echo "$map_tar" | sed "s/-${VERSION}.tar.gz//")
            if [ "$first" = true ]; then
                first=false
            else
                echo "," >> "manifest-${VERSION}.json"
            fi
            cat >> "manifest-${VERSION}.json" << EOF
      {
        "name": "${map_name}",
        "file": "${map_tar}",
        "required": false,
        "description": "地图包 - ${map_name}",
        "size": $(stat -f%z "$map_tar" 2>/dev/null || stat -c%s "$map_tar" 2>/dev/null || echo 0)
      }
EOF
        fi
    done
    
    cd "${RELEASE_DIR}"
    cat >> "manifest-${VERSION}.json" << EOF
    ]
  }
}
EOF

    log "✓ 清单文件已生成: manifest-${VERSION}.json"
}

log_section "[6] 清理临时文件"
{
    if [ -d "$TEMP_DIR" ]; then
        log "清理临时目录..."
        rm -rf "$TEMP_DIR"
        log "✓ 临时目录已清理"
    fi
}

log_section "[7] 总结"
{
    cd "${RELEASE_DIR}"
    echo ""
    echo "✅ 发布包准备完成！"
    echo ""
    echo "📦 包文件 (在 releases/ 目录):"
    echo "  - 基础包: base-${VERSION}.tar.gz ($(du -sh "base-${VERSION}.tar.gz" | cut -f1))"
    if [ -f "shared-${VERSION}.tar.gz" ]; then
        echo "  - 共享资源包: shared-${VERSION}.tar.gz ($(du -sh "shared-${VERSION}.tar.gz" | cut -f1))"
    fi
    map_count=$(ls -1 *-${VERSION}.tar.gz 2>/dev/null | grep -v "^base-" | grep -v "^shared-" | wc -l)
    echo "  - 地图包数量: ${map_count}"
    echo ""
    echo "📁 发布目录: ${RELEASE_DIR}"
    echo ""
    echo "下一步:"
    echo "1. 检查发布文件: ls -lh ${RELEASE_DIR}/*.tar.gz"
    echo "2. 上传到 GitHub Releases: ./scripts/release_manager/upload_to_release.sh ${VERSION}"
    echo "3. Git 提交时 releases/ 目录保持为空（只有 .gitkeep）"
}
