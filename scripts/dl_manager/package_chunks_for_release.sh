#!/bin/bash
set -e

# ============================================================================
# 将打包好的Chunk文件组织成发布版本
# 用于上传到GitHub Releases
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
CHUNK_SOURCE="/home/user/work/workspace/jszr_mujoco_ue2/dist/chunks"
VERSION="${1:-2.0.8}"
RELEASE_DIR="${PROJECT_ROOT}/releases/chunks/${VERSION}"

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
    mkdir -p "${RELEASE_DIR}"/{base,shared,maps}
    log "✓ 创建发布目录: ${RELEASE_DIR}"
}

log_section "[2] 复制基础包 (Chunk 0)"
{
    BASE_SOURCE="${CHUNK_SOURCE}/${VERSION}/package_base"
    if [ -d "$BASE_SOURCE" ]; then
        log "复制基础包文件..."
        rsync -av --exclude="*.log" "$BASE_SOURCE/" "${RELEASE_DIR}/base/"
        
        # 创建基础包压缩文件
        log "压缩基础包..."
        cd "${RELEASE_DIR}"
        tar -czf "base-${VERSION}.tar.gz" -C base .
        log "✓ 基础包: base-${VERSION}.tar.gz ($(du -sh "base-${VERSION}.tar.gz" | cut -f1))"
    else
        error_exit "找不到基础包目录: $BASE_SOURCE"
    fi
}

log_section "[3] 复制共享资源包 (Chunk 1)"
{
    SHARED_SOURCE="${CHUNK_SOURCE}/${VERSION}/package_shared"
    if [ -d "$SHARED_SOURCE" ]; then
        log "复制共享资源包文件..."
        rsync -av --exclude="*.log" "$SHARED_SOURCE/" "${RELEASE_DIR}/shared/"
        
        # 创建共享资源包压缩文件
        log "压缩共享资源包..."
        cd "${RELEASE_DIR}"
        tar -czf "shared-${VERSION}.tar.gz" -C shared .
        log "✓ 共享资源包: shared-${VERSION}.tar.gz ($(du -sh "shared-${VERSION}.tar.gz" | cut -f1))"
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
                    temp_map_dir="${RELEASE_DIR}/maps/${map_name}"
                    mkdir -p "$temp_map_dir"
                    rsync -av "$map_dir" "$temp_map_dir/"
                    
                    # 为每个地图创建压缩文件
                    cd "${RELEASE_DIR}/maps"
                    tar -czf "${map_name}-${VERSION}.tar.gz" -C "${map_name}" .
                    map_size=$(du -sh "${map_name}-${VERSION}.tar.gz" | cut -f1)
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
    cd "${RELEASE_DIR}/maps"
    first=true
    for map_tar in *-${VERSION}.tar.gz; do
        if [ -f "$map_tar" ]; then
            map_name=$(echo "$map_tar" | sed "s/-${VERSION}.tar.gz//")
            if [ "$first" = true ]; then
                first=false
            else
                echo "," >> "${RELEASE_DIR}/manifest-${VERSION}.json"
            fi
            cat >> "${RELEASE_DIR}/manifest-${VERSION}.json" << EOF
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

log_section "[6] 生成README"
{
    cd "${RELEASE_DIR}"
    
    cat > "README.md" << EOF
# MATRiX Chunk Packages ${VERSION}

## 📦 包说明

### 基础包 (必需)
- **文件**: \`base-${VERSION}.tar.gz\`
- **内容**: EmptyWorld地图 + 核心蓝图 + Chunk 0
- **大小**: $(du -sh "base-${VERSION}.tar.gz" | cut -f1)
- **必需**: ✅ 是

### 共享资源包 (推荐)
- **文件**: \`shared-${VERSION}.tar.gz\`
- **内容**: Fab/Warehouse + StarterContent 共享资源 (Chunk 1)
- **大小**: $(du -sh "shared-${VERSION}.tar.gz" | cut -f1)
- **必需**: ⚠️  否（但多个地图依赖此包，建议下载）

### 地图包 (可选)
以下地图包可按需下载：

EOF

    cd "${RELEASE_DIR}/maps"
    for map_tar in *-${VERSION}.tar.gz; do
        if [ -f "$map_tar" ]; then
            map_name=$(echo "$map_tar" | sed "s/-${VERSION}.tar.gz//")
            map_size=$(du -sh "$map_tar" | cut -f1)
            echo "- **${map_name}**: \`${map_tar}\` ($map_size)" >> "${RELEASE_DIR}/README.md"
        fi
    done
    
    cat >> "${RELEASE_DIR}/README.md" << EOF

## 🚀 安装说明

1. **下载必需包**:
   \`\`\`bash
   # 下载基础包（必需）
   wget https://github.com/Alphabaijinde/matrix/releases/download/v${VERSION}/base-${VERSION}.tar.gz
   \`\`\`

2. **下载共享资源包（推荐）**:
   \`\`\`bash
   wget https://github.com/Alphabaijinde/matrix/releases/download/v${VERSION}/shared-${VERSION}.tar.gz
   \`\`\`

3. **下载地图包（按需）**:
   \`\`\`bash
   # 例如下载SceneWorld
   wget https://github.com/Alphabaijinde/matrix/releases/download/v${VERSION}/SceneWorld-${VERSION}.tar.gz
   \`\`\`

4. **运行安装脚本**:
   \`\`\`bash
   # 使用安装脚本自动组织文件
   ./scripts/dl_manager/install_chunks.sh ${VERSION}
   \`\`\`

## 📋 完整清单

查看 \`manifest-${VERSION}.json\` 获取完整的包信息和大小。

EOF

    log "✓ README.md 已生成"
}

log_section "[7] 总结"
{
    cd "${RELEASE_DIR}"
    echo ""
    echo "✅ 发布包准备完成！"
    echo ""
    echo "📦 包文件:"
    echo "  - 基础包: base-${VERSION}.tar.gz ($(du -sh "base-${VERSION}.tar.gz" | cut -f1))"
    if [ -f "shared-${VERSION}.tar.gz" ]; then
        echo "  - 共享资源包: shared-${VERSION}.tar.gz ($(du -sh "shared-${VERSION}.tar.gz" | cut -f1))"
    fi
    echo "  - 地图包数量: $(ls -1 maps/*-${VERSION}.tar.gz 2>/dev/null | wc -l)"
    echo ""
    echo "📁 发布目录: ${RELEASE_DIR}"
    echo ""
    echo "下一步:"
    echo "1. 检查发布文件"
    echo "2. 提交到Git: git add releases/ && git commit -m 'Add chunk packages ${VERSION}'"
    echo "3. 推送到GitHub: git push origin feature/chunk-packages-release"
    echo "4. 在GitHub上创建Release并上传这些文件"
}

