# GitHub 上传清单

上传前请对照本清单，避免泄露敏感信息或推送超大文件。

## ✅ 需要上传

| 类别 | 路径 |
|------|------|
| Xcode 工程 | `innoforge.xcodeproj/`（不含 `xcuserdata/`） |
| iOS 源码 | `test5/*.swift`、`test5/Info.plist` |
| UI 资源 | `test5/Assets.xcassets/` |
| 小体积模型 | `test5/animeganPaprika.mlmodel`（~8 MB） |
| Flask 服务 | `test5/server_api.py`、`test5/server_api_remote.py` |
| SD 工具链 | `innoforge-stablediff/`（不含 `generated_images/`） |
| 测试 | `test5Tests/`、`test5UITests/` |
| 部署脚本 | `deploy_to_cloud.sh` |
| 公开文档 | `README.md`、`docs/`、`Flask服务云部署指南.md`、`SD_SETUP_README.md`、`TESTING_GUIDE.md` 等 |
| 版本控制 | `.gitignore` |

## ❌ 不要上传

| 类别 | 路径 | 原因 |
|------|------|------|
| 大模型 | `test5/is-net-genral-use.mlmodel` | 168 MB，超 GitHub 100 MB 限制 |
| 编译产物 | `*.mlmodelc`、`DerivedData/`、`build/` | 本地自动生成 |
| Python 环境 | `venv/`、`__pycache__/` | 可本地重建 |
| 生成图片 | `innoforge-stablediff/generated_images/` | 运行输出，非源码 |
| 用户配置 | `xcuserdata/`、`.vscode/` | 个人 IDE 设置 |
| 系统文件 | `.DS_Store` | 无意义 |
| 敏感文档 | 见 `.gitignore` 中「内部调试文档」列表 | 含服务器密码、内网 IP |
| 空文件 | `h` | 无意义 |

## ⚠️ 大文件方案（IS-Net 模型）

任选其一：

1. **Git LFS**：`git lfs track "test5/is-net-genral-use.mlmodel"`
2. **Release 附件**：在 GitHub Release 中上传，README 提供下载链接
3. **网盘分发**：百度网盘 / Google Drive，在 `docs/MODEL_SETUP.md` 附链接

## 清理已跟踪但不应上传的文件

若仓库里已经 `git add` 过大文件或敏感文档，需先从 Git 索引移除（本地文件保留）：

```bash
# 大模型（超 GitHub 100MB 限制）
git rm --cached test5/is-net-genral-use.mlmodel

# 生成图片
git rm -r --cached innoforge-stablediff/generated_images/

# Python 环境与缓存
git rm -r --cached venv/ test5/__pycache__/ 2>/dev/null || true

# 含密码的内部文档
git rm --cached Termius配置指南.md MUST_READ_看这里.md SERVER_STATUS.md 2>/dev/null || true
git rm --cached 紧急排查-暂无图像.md 更新ngrok地址.md 紧急回滚说明.md 2>/dev/null || true
git rm --cached 调试指南-真实合成.md 【重要】测试真实合成.md 快速测试-优化后.md 2>/dev/null || true
git rm --cached test试步骤-无线模式.md XCODE_CONSOLE_GUIDE.png.txt 2>/dev/null || true

# Xcode 用户数据
git rm -r --cached innoforge.xcodeproj/xcuserdata/ 2>/dev/null || true
```

## 推荐上传命令

```bash
cd innoforge

# 确认 .gitignore 生效
git status

# 首次提交
git add .
git commit -m "Initial commit: Innoforge iOS app"

# 关联远程仓库并推送
git remote add origin https://github.com/<username>/innoforge.git
git branch -M main
git push -u origin main
```

## 上传前自检

- [ ] `git status` 中无 `venv/`、`generated_images/`、`xcuserdata/`
- [ ] 代码中无真实服务器密码（已替换为 `YOUR_PASSWORD`）
- [ ] `StableDiffusionManager.swift` 中 ngrok 地址已改为占位符
- [ ] IS-Net 模型已通过 LFS 或文档说明处理
