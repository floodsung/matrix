# 安装 GitHub CLI 并上传 Release

## 步骤 1: 安装 GitHub CLI

```bash
sudo apt update
sudo apt install -y gh
```

## 步骤 2: 登录 GitHub

```bash
gh auth login
```

按提示操作：
1. 选择 `GitHub.com`
2. 选择 `HTTPS`
3. 选择认证方式：
   - `Login with a web browser` (推荐)
   - 或 `Paste an authentication token`

## 步骤 3: 运行上传脚本

```bash
cd /home/user/work/workspace/matrix
./scripts/dl_manager/upload_to_release.sh 2.0.8
```

脚本会自动：
- ✅ 创建 Release v2.0.8（草稿状态）
- ✅ 上传基础包 (~891MB)
- ✅ 上传共享资源包 (~183MB)
- ✅ 上传所有 14 个地图包
- ✅ 上传清单文件
- ✅ 询问是否发布 Release

## 注意事项

- 文件较大（总计约 12GB），上传可能需要较长时间
- 确保网络连接稳定
- 可以先创建为草稿，上传完成后再发布

