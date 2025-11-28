# MATRiX Chunk Packages 使用指南

## 📦 什么是Chunk Packages?

MATRiX现在支持模块化打包，将模拟器内容分为：
- **基础包**: 必需的核心文件和EmptyWorld地图
- **共享资源包**: 多个地图共享的资源（推荐安装）
- **地图包**: 各个独立的地图，可按需下载

这种设计让用户可以：
- ✅ 只下载需要的内容，节省存储空间
- ✅ 快速开始（只需下载基础包）
- ✅ 按需扩展（需要哪个地图再下载）

## 🚀 快速安装

### 自动安装（推荐）

```bash
./scripts/release_manager/install_chunks.sh 2.0.8
```

### 手动安装

1. **下载基础包**（必需）
   ```bash
   wget https://github.com/Alphabaijinde/matrix/releases/download/v2.0.8/base-2.0.8.tar.gz
   ```

2. **下载共享资源包**（推荐）
   ```bash
   wget https://github.com/Alphabaijinde/matrix/releases/download/v2.0.8/shared-2.0.8.tar.gz
   ```

3. **下载地图包**（按需）
   ```bash
   wget https://github.com/Alphabaijinde/matrix/releases/download/v2.0.8/SceneWorld-2.0.8.tar.gz
   ```

4. **解压到运行目录**
   ```bash
   cd src/UeSim/Linux/jszr_mujoco_ue
   tar -xzf ../../../../base-2.0.8.tar.gz
   cd Content/Paks
   tar -xzf ../../../../shared-2.0.8.tar.gz
   tar -xzf ../../../../SceneWorld-2.0.8.tar.gz
   ```

## 📋 包说明

### 基础包 (base-2.0.8.tar.gz) - 必需
- **大小**: ~900MB
- **内容**: 
  - EmptyWorld地图
  - 核心蓝图和系统文件
  - Chunk 0 (pakchunk0)
- **必需**: ✅ 是

### 共享资源包 (shared-2.0.8.tar.gz) - 推荐
- **大小**: ~180MB
- **内容**: 
  - Fab/Warehouse共享资源
  - StarterContent共享资源
  - Chunk 1 (pakchunk1)
- **必需**: ⚠️ 否，但多个地图依赖，强烈建议安装

### 地图包 - 可选

| 地图包 | 大小 | Chunk ID | 说明 |
|--------|------|----------|------|
| SceneWorld | ~280MB | 11 | 仓库场景 |
| Town10World | ~3.6GB | 12 | 城镇场景（大） |
| YardWorld | ~780MB | 13 | 庭院场景 |
| CrowdWorld | ~410MB | 14 | 人群场景 |
| VeniceWorld | ~340MB | 15 | 威尼斯场景 |
| RunningWorld | ~36MB | 16 | 跑步场景 |
| HouseWorld | ~340MB | 17 | 房屋场景 |
| IROSFlatWorld | ~187MB | 18 | IROS平地场景 |
| IROSSlopedWorld | ~435MB | 19 | IROS斜坡场景 |
| Town10Zombie | ~3.6GB | 20 | 僵尸场景（大） |
| IROSFlatWorld2025 | ~123MB | 21 | IROS 2025平地场景 |
| IROSSloppedWorld2025 | ~123MB | 22 | IROS 2025斜坡场景 |
| OfficeWorld | ~6.7MB | 23 | 办公室场景 |
| Custom | ~11MB | 24 | 自定义场景 |

## 🔍 验证安装

安装后检查：

```bash
cd src/UeSim/Linux/jszr_mujoco_ue/Content/Paks
ls -lh pakchunk*.pak
```

应该看到：
- `pakchunk0-Linux.pak` - 基础包（必需）
- `pakchunk1-Linux.pak` - 共享资源包（如果已安装）
- `pakchunk11-Linux.pak` 等 - 地图包（如果已安装）

## 🎮 使用

安装完成后，运行模拟器：

```bash
# 已在 matrix 根目录
./scripts/run_sim.sh 0 0  # 运行EmptyWorld（只需要基础包）
./scripts/run_sim.sh 1 1  # 切换到SceneWorld（需要SceneWorld地图包）
```

## ❓ 常见问题

**Q: 我只想运行EmptyWorld，需要下载哪些包？**  
A: 只需要基础包（base包）即可。

**Q: 为什么共享资源包是推荐的？**  
A: 因为多个地图都依赖共享资源包中的资源，如果不安装，这些地图可能无法正常加载。

**Q: 我可以只下载部分地图包吗？**  
A: 可以！你可以根据需要只下载要使用的地图包。

**Q: 如何更新到新版本？**  
A: 下载新版本的包，解压覆盖旧文件即可。建议先备份。

## 📚 更多信息

- [主 README](../README.md) - 项目主文档
- [中文文档](README_CN.md) - 中文使用指南
