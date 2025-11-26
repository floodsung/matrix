# MATRiX Chunk Packages Releases

本目录包含MATRiX模拟器的模块化Chunk包，支持按需下载和安装。

## 📦 包结构说明

### 基础包 (Base Package) - **必需**
- **文件**: `base-{VERSION}.tar.gz`
- **内容**: 
  - EmptyWorld地图
  - 核心蓝图 (BP_MapAutoSwitch, MujoCoSim, BP_SpawnManager等)
  - Chunk 0 (pakchunk0)
- **必需**: ✅ **是** - 必须下载安装

### 共享资源包 (Shared Resources) - **推荐**
- **文件**: `shared-{VERSION}.tar.gz`
- **内容**: 
  - Fab/Warehouse共享资源
  - StarterContent共享资源
  - Chunk 1 (pakchunk1)
- **必需**: ⚠️ **否** - 但多个地图依赖此包，强烈建议下载

### 地图包 (Map Packages) - **可选**
每个地图包包含该地图及其独有资源：
- `SceneWorld-{VERSION}.tar.gz` - 仓库场景
- `Town10World-{VERSION}.tar.gz` - 城镇场景
- `YardWorld-{VERSION}.tar.gz` - 庭院场景
- `CrowdWorld-{VERSION}.tar.gz` - 人群场景
- `VeniceWorld-{VERSION}.tar.gz` - 威尼斯场景
- `RunningWorld-{VERSION}.tar.gz` - 跑步场景
- `HouseWorld-{VERSION}.tar.gz` - 房屋场景
- `IROSFlatWorld-{VERSION}.tar.gz` - IROS平地场景
- `IROSSlopedWorld-{VERSION}.tar.gz` - IROS斜坡场景
- `Town10Zombie-{VERSION}.tar.gz` - 僵尸场景
- `IROSFlatWorld2025-{VERSION}.tar.gz` - IROS 2025平地场景
- `IROSSloppedWorld2025-{VERSION}.tar.gz` - IROS 2025斜坡场景
- `OfficeWorld-{VERSION}.tar.gz` - 办公室场景
- `Custom-{VERSION}.tar.gz` - 自定义场景

## 🚀 快速开始

### 方法1: 使用自动安装脚本 (推荐)

```bash
# 1. 克隆或下载MATRiX仓库
git clone https://github.com/Alphabaijinde/matrix.git
cd matrix

# 2. 运行安装脚本
./scripts/dl_manager/install_chunks.sh 2.0.8
```

脚本会自动：
- 下载基础包（必需）
- 询问是否下载共享资源包（推荐）
- 交互式选择要下载的地图包
- 自动解压并组织文件到正确的目录

### 方法2: 手动下载和安装

```bash
# 1. 下载基础包（必需）
wget https://github.com/Alphabaijinde/matrix/releases/download/v2.0.8/base-2.0.8.tar.gz

# 2. 下载共享资源包（推荐）
wget https://github.com/Alphabaijinde/matrix/releases/download/v2.0.8/shared-2.0.8.tar.gz

# 3. 下载需要的地图包（可选）
wget https://github.com/Alphabaijinde/matrix/releases/download/v2.0.8/SceneWorld-2.0.8.tar.gz

# 4. 解压到运行目录
cd matrix/src/UeSim/Linux/jszr_mujoco_ue
tar -xzf ../../../../base-2.0.8.tar.gz
cd Content/Paks
tar -xzf ../../../../shared-2.0.8.tar.gz
tar -xzf ../../../../SceneWorld-2.0.8.tar.gz
```

## 📋 版本列表

查看各版本的详细信息和文件大小：

- [v2.0.8](./chunks/2.0.8/README.md) - 当前版本

## 🔍 验证安装

安装完成后，检查chunk文件：

```bash
cd matrix/src/UeSim/Linux/jszr_mujoco_ue/Content/Paks
ls -lh pakchunk*.pak
```

应该看到：
- `pakchunk0-Linux.pak` - 基础包（必需）
- `pakchunk1-Linux.pak` - 共享资源包（如果已安装）
- `pakchunk11-Linux.pak` 等 - 地图包（如果已安装）

## 🎮 运行模拟器

安装完成后，运行模拟器：

```bash
cd matrix
./run_sim.sh 0 0  # 运行EmptyWorld（基础包）
./run_sim.sh 1 1  # 切换到SceneWorld（需要SceneWorld地图包）
```

## 📊 包大小参考

| 包类型 | 大小 | 说明 |
|--------|------|------|
| 基础包 | ~900MB | 必需 |
| 共享资源包 | ~180MB | 推荐 |
| SceneWorld | ~280MB | 可选 |
| Town10World | ~3.6GB | 可选（大） |
| YardWorld | ~780MB | 可选 |
| 其他地图 | 6MB-450MB | 可选 |

## ❓ 常见问题

### Q: 我只想运行EmptyWorld，需要下载哪些包？
A: 只需要下载基础包（base包）即可。

### Q: 为什么共享资源包是推荐的？
A: 因为多个地图都依赖共享资源包中的资源（如Fab/Warehouse），如果不安装，这些地图可能无法正常加载。

### Q: 我可以只下载部分地图包吗？
A: 可以！你可以根据需要只下载要使用的地图包，这样可以节省存储空间。

### Q: 如何更新到新版本？
A: 下载新版本的包，解压覆盖旧文件即可。建议先备份旧版本。

### Q: 安装后如何验证？
A: 检查 `matrix/src/UeSim/Linux/jszr_mujoco_ue/Content/Paks/` 目录中是否有对应的 `pakchunk*.pak` 文件。

## 🔗 相关链接

- [MATRiX主仓库](https://github.com/Alphabaijinde/matrix)
- [完整文档](../README.md)
- [安装指南](../README.md#-installation--build)

