# MATRiX Chunk Packages 发布指南

## 📋 发布流程

### 1. 准备发布包

在 `jszr_mujoco_ue2` 项目中打包：

```bash
cd /home/user/work/workspace/jszr_mujoco_ue2
./Script/package_with_chunks.sh 2.0.8
```

### 2. 生成发布文件

在 `matrix` 项目中运行打包脚本：

```bash
cd /home/user/work/workspace/matrix
./scripts/dl_manager/package_chunks_for_release.sh 2.0.8
```

这会生成：
- `releases/chunks/2.0.8/base-2.0.8.tar.gz` - 基础包
- `releases/chunks/2.0.8/shared-2.0.8.tar.gz` - 共享资源包
- `releases/chunks/2.0.8/maps/*.tar.gz` - 14个地图包
- `releases/chunks/2.0.8/manifest-2.0.8.json` - 清单文件
- `releases/chunks/2.0.8/README.md` - 版本说明

### 3. 提交到Git

```bash
cd /home/user/work/workspace/matrix

# 添加文件
git add releases/
git add scripts/dl_manager/
git add .gitignore
git add CHUNK_PACKAGES_GUIDE.md
git add RELEASE_GUIDE.md

# 提交
git commit -m "Add chunk packages v2.0.8 with modular download support

- Add base package (required)
- Add shared resources package (recommended)
- Add 14 map packages (optional)
- Add automatic installer script
- Add documentation and guides"

# 推送到GitHub
git push origin feature/chunk-packages-release
```

### 4. 在GitHub上创建Release

**重要**: `.tar.gz` 文件**不上传到 Git 仓库**，而是上传到 GitHub Releases。

1. 访问: https://github.com/Alphabaijinde/matrix/releases/new
2. **Tag**: `v2.0.8`
3. **Title**: `MATRiX v2.0.8 - Modular Chunk Packages`
4. **Description**: 使用 `releases/chunks/2.0.8/README.md` 的内容
5. **上传文件** (从 `releases/chunks/2.0.8/` 目录):
   - `base-2.0.8.tar.gz` (必需, ~891MB)
   - `shared-2.0.8.tar.gz` (推荐, ~183MB)
   - `SceneWorld-2.0.8.tar.gz` (~280MB)
   - `Town10World-2.0.8.tar.gz` (~3.6GB)
   - `YardWorld-2.0.8.tar.gz` (~780MB)
   - ... (所有14个地图包)
   - `manifest-2.0.8.json` (可选，用于自动化工具)

**注意**: 
- 文件较大，上传可能需要一些时间
- 建议分批上传，或使用 GitHub CLI (`gh release upload`)

### 5. 合并到主分支（可选）

```bash
git checkout main
git merge feature/chunk-packages-release
git push origin main
```

## 📦 文件清单

### 必需文件
- ✅ `base-2.0.8.tar.gz` - 基础包 (~900MB)

### 推荐文件
- ⚠️ `shared-2.0.8.tar.gz` - 共享资源包 (~180MB)

### 可选文件（地图包）
- `SceneWorld-2.0.8.tar.gz` (~280MB)
- `Town10World-2.0.8.tar.gz` (~3.6GB)
- `YardWorld-2.0.8.tar.gz` (~780MB)
- `CrowdWorld-2.0.8.tar.gz` (~410MB)
- `VeniceWorld-2.0.8.tar.gz` (~340MB)
- `RunningWorld-2.0.8.tar.gz` (~36MB)
- `HouseWorld-2.0.8.tar.gz` (~340MB)
- `IROSFlatWorld-2.0.8.tar.gz` (~187MB)
- `IROSSlopedWorld-2.0.8.tar.gz` (~435MB)
- `Town10Zombie-2.0.8.tar.gz` (~3.6GB)
- `IROSFlatWorld2025-2.0.8.tar.gz` (~123MB)
- `IROSSloppedWorld2025-2.0.8.tar.gz` (~123MB)
- `OfficeWorld-2.0.8.tar.gz` (~6.7MB)
- `Custom-2.0.8.tar.gz` (~11MB)

### 元数据文件
- `manifest-2.0.8.json` - 包清单（用于自动化工具）

## 🔗 下载链接格式

GitHub Releases 下载链接格式：
```
https://github.com/Alphabaijinde/matrix/releases/download/v{VERSION}/{PACKAGE}-{VERSION}.tar.gz
```

例如：
```
https://github.com/Alphabaijinde/matrix/releases/download/v2.0.8/base-2.0.8.tar.gz
https://github.com/Alphabaijinde/matrix/releases/download/v2.0.8/shared-2.0.8.tar.gz
https://github.com/Alphabaijinde/matrix/releases/download/v2.0.8/SceneWorld-2.0.8.tar.gz
```

## ✅ 验证清单

发布前检查：
- [ ] 所有 `.tar.gz` 文件已生成
- [ ] 文件大小合理（基础包 ~900MB，共享资源包 ~180MB）
- [ ] `manifest-2.0.8.json` 已生成且内容正确
- [ ] `README.md` 已生成且链接正确
- [ ] 安装脚本 `install_chunks.sh` 已测试
- [ ] 文档已更新（`CHUNK_PACKAGES_GUIDE.md`, `releases/README.md`）

## 📝 Release Notes 模板

```markdown
# MATRiX v2.0.8 - Modular Chunk Packages

## 🎉 新特性

- ✨ 支持模块化Chunk包下载
- 📦 基础包、共享资源包、地图包分离
- 🚀 自动安装脚本
- 📚 完整文档和指南

## 📦 包说明

### 基础包 (必需)
- **文件**: `base-2.0.8.tar.gz` (~900MB)
- **内容**: EmptyWorld + 核心蓝图 + Chunk 0

### 共享资源包 (推荐)
- **文件**: `shared-2.0.8.tar.gz` (~180MB)
- **内容**: Fab/Warehouse + StarterContent 共享资源

### 地图包 (可选)
14个独立地图包，可按需下载。详见 [Chunk Packages Guide](CHUNK_PACKAGES_GUIDE.md)

## 🚀 快速开始

```bash
# 克隆仓库
git clone https://github.com/Alphabaijinde/matrix.git
cd matrix

# 自动安装
./scripts/dl_manager/install_chunks.sh 2.0.8
```

## 📚 文档

- [Chunk Packages 使用指南](CHUNK_PACKAGES_GUIDE.md)
- [完整发布说明](releases/README.md)
- [主README](README.md)
```

