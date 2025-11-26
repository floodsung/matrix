# Git LFS 使用说明

## ⚠️ 当前状态

**本项目不使用 Git LFS**。大型发布包文件（.tar.gz）通过 **GitHub Releases** 分发，而不是存储在 Git 仓库中。

## 📦 发布包分发方式

所有 `.tar.gz` 发布包文件应上传到 GitHub Releases，而不是提交到 Git 仓库。

### 原因
- 文件太大（总计约 12GB），超出 Git LFS 免费配额（1GB）
- GitHub Releases 更适合分发大型二进制文件
- 用户可以按需下载，不需要克隆整个仓库

### 配置内容

- **跟踪文件类型**: `*.tar.gz` (所有压缩包)
- **配置文件**: `.gitattributes`
- **LFS 版本**: git-lfs/3.0.2

### 当前 LFS 文件

所有发布包文件（16个 .tar.gz 文件，总计约 12GB）已由 Git LFS 跟踪：

- `base-2.0.8.tar.gz` (~891MB)
- `shared-2.0.8.tar.gz` (~183MB)
- 14个地图包文件 (6.7MB - 3.6GB)

## 📝 使用说明

### 克隆仓库（包含 LFS 文件）

```bash
git clone https://github.com/Alphabaijinde/matrix.git
cd matrix
git lfs pull  # 下载 LFS 文件
```

### 检查 LFS 文件状态

```bash
# 查看所有 LFS 跟踪的文件
git lfs ls-files

# 查看 LFS 文件大小
git lfs ls-files | awk '{print $3}' | xargs du -h
```

### 添加新的 LFS 文件

```bash
# 自动跟踪（如果 .gitattributes 已配置）
git add your-large-file.tar.gz

# 手动跟踪
git lfs track "*.your-extension"
git add .gitattributes
git add your-large-file.tar.gz
```

## ⚠️ 注意事项

1. **GitHub LFS 配额**: 
   - 免费账户: 1GB 存储空间，1GB/月 带宽
   - 如果超过配额，需要升级账户或使用其他存储方案

2. **克隆速度**: 
   - LFS 文件需要单独下载，可能较慢
   - 建议使用 `git lfs pull` 单独下载需要的文件

3. **替代方案**: 
   - 如果 LFS 配额不足，可以考虑：
     - 只将小文件（<100MB）放入 LFS
     - 大文件（>1GB）直接上传到 GitHub Releases
     - 使用外部存储（如 Google Drive, Baidu Netdisk）

## 🔗 相关链接

- [Git LFS 文档](https://git-lfs.github.com/)
- [GitHub LFS 配额](https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-storage-and-bandwidth-usage)

