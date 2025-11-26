#!/bin/bash
set -e

# ============================================================================
# 安装Chunk包到运行目录
# 自动下载并组织文件到正确的目录结构
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
VERSION="${1:-2.0.8}"
GITHUB_REPO="Alphabaijinde/matrix"
GITHUB_RELEASE_URL="https://github.com/${GITHUB_REPO}/releases/download/v${VERSION}"
TARGET_DIR="${PROJECT_ROOT}/matrix/src/UeSim/Linux/jszr_mujoco_ue"
PAK_DIR="${TARGET_DIR}/Content/Paks"

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

# 检查wget或curl
if command -v wget &> /dev/null; then
    DOWNLOAD_CMD="wget -q --show-progress"
elif command -v curl &> /dev/null; then
    DOWNLOAD_CMD="curl -L -O --progress-bar"
else
    error_exit "需要 wget 或 curl 来下载文件"
fi

download_file() {
    local url=$1
    local output=$2
    log "下载: $(basename "$output")"
    
    if command -v wget &> /dev/null; then
        wget -q --show-progress -O "$output" "$url" || return 1
    else
        curl -L --progress-bar -o "$output" "$url" || return 1
    fi
}

extract_tar() {
    local tar_file=$1
    local extract_dir=$2
    log "解压: $(basename "$tar_file")"
    mkdir -p "$extract_dir"
    tar -xzf "$tar_file" -C "$extract_dir" || return 1
}

log_section "MATRiX Chunk包安装器 v${VERSION}"

# 创建临时下载目录
DOWNLOAD_DIR="${PROJECT_ROOT}/.chunk_downloads_${VERSION}"
mkdir -p "$DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR"

# 确保目标目录存在
mkdir -p "$PAK_DIR"

log_section "[1] 下载基础包 (必需)"
{
    BASE_FILE="base-${VERSION}.tar.gz"
    BASE_URL="${GITHUB_RELEASE_URL}/${BASE_FILE}"
    
    if download_file "$BASE_URL" "$BASE_FILE"; then
        log "✓ 基础包下载完成"
        
        # 解压基础包到目标目录
        log "安装基础包..."
        extract_tar "$BASE_FILE" "$TARGET_DIR"
        
        # 移动chunk文件到Paks目录
        if [ -d "${TARGET_DIR}/Content/Paks" ]; then
            mv "${TARGET_DIR}/Content/Paks"/*.pak "${TARGET_DIR}/Content/Paks"/*.ucas "${TARGET_DIR}/Content/Paks"/*.utoc "$PAK_DIR/" 2>/dev/null || true
        fi
        
        log "✓ 基础包安装完成"
    else
        error_exit "基础包下载失败，请检查网络连接和版本号"
    fi
}

log_section "[2] 下载共享资源包 (推荐)"
{
    SHARED_FILE="shared-${VERSION}.tar.gz"
    SHARED_URL="${GITHUB_RELEASE_URL}/${SHARED_FILE}"
    
    read -p "是否下载共享资源包? (推荐，多个地图依赖) [Y/n]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        if download_file "$SHARED_URL" "$SHARED_FILE"; then
            log "✓ 共享资源包下载完成"
            extract_tar "$SHARED_FILE" "$PAK_DIR"
            log "✓ 共享资源包安装完成"
        else
            log "⚠️  共享资源包下载失败，跳过"
        fi
    else
        log "跳过共享资源包"
    fi
}

log_section "[3] 下载地图包 (可选)"
{
    echo "可用地图包:"
    echo "  11. SceneWorld"
    echo "  12. Town10World"
    echo "  13. YardWorld"
    echo "  14. CrowdWorld"
    echo "  15. VeniceWorld"
    echo "  16. RunningWorld"
    echo "  17. HouseWorld"
    echo "  18. IROSFlatWorld"
    echo "  19. IROSSlopedWorld"
    echo "  20. Town10Zombie"
    echo "  21. IROSFlatWorld2025"
    echo "  22. IROSSloppedWorld2025"
    echo "  23. OfficeWorld"
    echo "  24. Custom"
    echo ""
    echo "输入要下载的地图名称（用空格分隔，或输入 'all' 下载全部，直接回车跳过）:"
    read -r maps_input
    
    if [ -z "$maps_input" ]; then
        log "跳过地图包下载"
    elif [ "$maps_input" = "all" ]; then
        log "下载所有地图包..."
        map_names=("SceneWorld" "Town10World" "YardWorld" "CrowdWorld" "VeniceWorld" "RunningWorld" "HouseWorld" "IROSFlatWorld" "IROSSlopedWorld" "Town10Zombie" "IROSFlatWorld2025" "IROSSloppedWorld2025" "OfficeWorld" "Custom")
        for map_name in "${map_names[@]}"; do
            MAP_FILE="${map_name}-${VERSION}.tar.gz"
            MAP_URL="${GITHUB_RELEASE_URL}/${MAP_FILE}"
            if download_file "$MAP_URL" "$MAP_FILE"; then
                extract_tar "$MAP_FILE" "$PAK_DIR"
                log "  ✓ ${map_name} 安装完成"
            else
                log "  ⚠️  ${map_name} 下载失败，跳过"
            fi
        done
    else
        for map_name in $maps_input; do
            MAP_FILE="${map_name}-${VERSION}.tar.gz"
            MAP_URL="${GITHUB_RELEASE_URL}/${MAP_FILE}"
            if download_file "$MAP_URL" "$MAP_FILE"; then
                extract_tar "$MAP_FILE" "$PAK_DIR"
                log "  ✓ ${map_name} 安装完成"
            else
                log "  ⚠️  ${map_name} 下载失败，跳过"
            fi
        done
    fi
}

log_section "[4] 清理和验证"
{
    # 清理下载目录
    cd "$PROJECT_ROOT"
    rm -rf "$DOWNLOAD_DIR"
    log "✓ 清理临时文件"
    
    # 验证安装
    log "验证安装..."
    if [ -f "${PAK_DIR}/pakchunk0-Linux.pak" ]; then
        log "✓ 基础包验证通过"
    else
        error_exit "基础包验证失败"
    fi
    
    chunk_count=$(ls -1 "${PAK_DIR}"/pakchunk*.pak 2>/dev/null | wc -l)
    log "✓ 已安装 ${chunk_count} 个chunk文件"
}

log_section "[5] 完成"
{
    echo ""
    echo "✅ Chunk包安装完成！"
    echo ""
    echo "已安装的包:"
    echo "  - 基础包 (Chunk 0)"
    if [ -f "${PAK_DIR}/pakchunk1-Linux.pak" ]; then
        echo "  - 共享资源包 (Chunk 1)"
    fi
    echo "  - 地图包: $(ls -1 "${PAK_DIR}"/pakchunk[1-9][0-9]*-Linux.pak 2>/dev/null | wc -l) 个"
    echo ""
    echo "运行目录: ${TARGET_DIR}"
    echo ""
    echo "现在可以运行模拟器了:"
    echo "  cd ${PROJECT_ROOT}/matrix"
    echo "  ./run_sim.sh 0 0  # 运行EmptyWorld"
}

