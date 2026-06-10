# CoreML 模型配置

Innoforge 依赖两个端侧 CoreML 模型。由于体积限制，部分模型未包含在 Git 仓库中。

## 模型清单

| 模型 | 文件 | 大小 | 仓库内 |
|------|------|------|--------|
| IS-Net 语义分割 | `test5/is-net-genral-use.mlmodel` | ~168 MB | ❌ 需自行获取 |
| AnimeGAN 风格迁移 | `test5/animeganPaprika.mlmodel` | ~8 MB | ✅ 已包含 |

## 获取 IS-Net 模型

**方式一：Git LFS（推荐，适合开发者）**

```bash
# 安装 Git LFS 后
git lfs install
git lfs track "test5/is-net-genral-use.mlmodel"
# 将模型文件放入 test5/ 后提交
```

**方式二：手动放置**

1. 获取 `is-net-genral-use.mlmodel`（项目训练/转换产物）
2. 复制到 `test5/is-net-genral-use.mlmodel`
3. 在 Xcode 中确认模型已加入 Target

> GitHub 单文件上限为 **100 MB**，IS-Net 模型无法直接通过普通 `git push` 上传，必须使用 Git LFS 或外部网盘分发。

## Xcode 编译说明

首次添加 `.mlmodel` 后，Xcode 会自动编译为 `.mlmodelc`。`.mlmodelc` 目录已在 `.gitignore` 中忽略，每位开发者本地自动生成即可。
