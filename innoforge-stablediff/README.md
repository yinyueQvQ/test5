# Stable Diffusion 远程调用工具

从本地 Windows 电脑远程调用服务器上的 Stable Diffusion 进行图像生成。

## 🎯 核心功能

- ✅ **自动化流程**: 本地图片 → 上传 → 服务器生成 → 自动下载
- ✅ **SSH/SFTP 连接**: 通过 SSH 远程执行命令，SFTP 传输文件
- ✅ **简单易用**: 只需配置 3 个参数即可运行
- ✅ **连接测试**: 自动检测服务器状态和项目目录
- ✅ **详细日志**: 实时显示上传、生成、下载进度
- ✅ **错误处理**: 完善的错误提示和解决方案
- ✅ **批量处理**: 支持批量处理多张图片
- ✅ **HTTP API**: 可选的 API 方式，适合集成到 App
- ✅ **中文文档**: 详细的中文注释和使用指南

## 🎬 使用场景

- 📱 本地电脑配置较低，服务器有强大的 GPU
- 🌐 需要在多台电脑上使用同一个 SD 服务
- 🔧 想要将 SD 集成到自己的应用中
- 📦 需要批量处理大量图片

## 📦 项目文件说明

| 文件 | 用途 | 必需性 |
|------|------|--------|
| `client_sd_remote.py` | **SSH 方式远程调用（推荐）** | ⭐ 核心 |
| `test_connection.py` | 测试服务器连接 | ⭐ 推荐 |
| `快速开始.md` | **3 步快速开始指南** | ⭐ 必读 |
| `远程调用指南.md` | 完整的远程调用文档 | 📖 参考 |
| `server_api.py` | HTTP API 服务端（可选） | 🔧 可选 |
| `client_api.py` | HTTP API 客户端（可选） | 🔧 可选 |
| `requirements.txt` | 依赖列表 | ✅ 必需 |

## 安装依赖

**一键安装**：

```bash
pip install -r requirements.txt
```

这会安装：
- `requests` - HTTP 请求库
- `paramiko` - SSH/SFTP 远程连接库

或者手动安装：

```bash
pip install paramiko requests
```

## 🚀 三步快速开始


### 步骤 1：测试连接

```bash
python test_connection.py
```

这会自动检测：
- ✅ SSH 连接是否正常
- ✅ SFTP 文件传输是否可用
- ✅ 服务器上的项目目录位置

### 步骤 2：配置参数

打开 `client_sd_remote.py`，修改以下配置：

```python
# 服务器配置（已填好，可根据需要修改）
SERVER_CONFIG = {
    "host": "your-server-host",
    "port": 22,
    "username": "root",
    "password": "YOUR_PASSWORD"
}

# ⚠️ 修改为你的实际路径
SERVER_PROJECT_DIR = "/root/stablediffusion"  # 服务器项目目录
LOCAL_INPUT_IMAGE = r"D:\your\image.jpg"      # 本地输入图片
```

### 步骤 3：运行生成

```bash
python client_sd_remote.py
```

**完整流程**：
```
本地图片 → 上传到服务器 → 服务器生成 → 下载到本地 ✓
```

生成的图片保存在 `generated_images/` 目录。

---

📖 **详细教程**：查看 [快速开始.md](快速开始.md) 获取图文详解

📘 **完整文档**：查看 [远程调用指南.md](远程调用指南.md) 了解更多功能

## 💻 代码示例

### 基础用法（推荐）

直接运行主脚本：

```bash
# 修改配置后直接运行
python client_sd_remote.py
```

### 高级用法：在代码中调用

如果要集成到自己的项目中：

```python
from client_sd_remote import SDRemoteClient

# 创建客户端
client = SDRemoteClient(
    host="your-server-host",
    port=22,
    username="root",
    password="YOUR_PASSWORD"
)

# 连接
if client.connect():
    # 生成图像
    generated_files = client.generate_image(
        local_image_path="D:/my_image.jpg",
        prompt="a beautiful anime-style illustration...",
        server_project_dir="/root/stablediffusion",
        checkpoint_path="/root/stablediffusion/ckpt/512-base-ema.ckpt",
        output_dir="my_output"
    )
    
    # 断开连接
    client.disconnect()
    
    print(f"✓ 成功生成 {len(generated_files)} 张图片")
```

### 批量处理多张图片

```python
from client_sd_remote import SDRemoteClient

client = SDRemoteClient(...)
client.connect()

# 批量处理
images = ["img1.jpg", "img2.jpg", "img3.jpg"]
for img in images:
    print(f"\n处理: {img}")
    client.generate_image(
        local_image_path=img,
        prompt="your prompt...",
        server_project_dir="/root/stablediffusion"
    )

client.disconnect()
```

### HTTP API 方式（适合 App 集成）

如果需要构建 Web App 或移动 App：

1. 在服务器上运行 `server_api.py`
2. 在客户端使用 `client_api.py` 或直接调用 HTTP API

```python
import requests
import base64

# 读取图片
with open("input.jpg", "rb") as f:
    image_base64 = base64.b64encode(f.read()).decode()

# 发送请求
response = requests.post(
    "http://your-server:8000/generate",
    json={
        "prompt": "your prompt",
        "image_base64": image_base64,
        "steps": 50
    }
)

# 获取结果
result = response.json()
if result["success"]:
    for img_b64 in result["images"]:
        img_data = base64.b64decode(img_b64)
        # 保存或处理图片
```

## 📁 生成的图像

成功生成的图像会自动下载到本地，保存位置：
- **默认目录**: `generated_images/` 
- **自定义目录**: 在 `generate_image()` 中通过 `output_dir` 参数指定
- **HTTP API 方式**: `api_generated/` 目录下

## ❓ 常见问题

### 1. SSH 连接失败

**错误**: `Connection timeout` 或 `Connection refused`

**解决方法:**
```bash
# 先手动测试 SSH 连接
ssh -p 22 root@your-server-host

# 如果能连接，说明配置正确
# 如果不能连接，检查：
# - 网络连接是否正常
# - 服务器是否在线
# - 端口和地址是否正确
```

### 2. 找不到项目目录

**错误**: `No such file or directory: /root/stablediffusion`

**解决方法:**
```bash
# 运行测试脚本自动检测
python test_connection.py

# 或者 SSH 登录手动查找
ssh -p 22 root@your-server-host
ls -la ~
find ~ -name "stablediffusion" -o -name "stable-diffusion"

# 找到正确路径后，修改脚本中的 SERVER_PROJECT_DIR
```

### 3. 找不到模型文件

**错误**: `FileNotFoundError: checkpoint not found`

**解决方法:**
```bash
# SSH 登录查看模型目录
ssh -p 22 root@your-server-host
ls /root/stablediffusion/ckpt/

# 复制实际的模型文件名，修改脚本中的 CHECKPOINT_PATH
```

### 4. 命令执行失败

**错误**: `Command failed with exit code 1`

**解决方法:**
- 查看脚本输出的详细错误信息
- SSH 登录服务器手动测试命令
- 常见原因：
  - 输入图片格式不支持（建议使用 JPG）
  - 服务器磁盘空间不足
  - GPU 内存不足
  - Python 环境或依赖问题

### 5. 下载的目录为空

**错误**: 下载完成但没有生成图片

**解决方法:**
```bash
# SSH 登录检查输出目录
ssh -p 22 root@your-server-host
ls /root/stablediffusion/outputs/samples/

# 如果目录为空，说明生成失败
# 检查命令输出的错误信息
```

## 🔧 参数说明

### `SDRemoteClient` 初始化参数

| 参数 | 说明 | 示例 |
|------|------|------|
| `host` | 服务器地址 | `your-server-host` |
| `port` | SSH 端口 | `22` |
| `username` | SSH 用户名 | `root` |
| `password` | SSH 密码 | `your_password` |

### `generate_image()` 参数

| 参数 | 说明 | 必需 | 默认值 |
|------|------|------|--------|
| `local_image_path` | 本地输入图片路径 | ✅ | - |
| `prompt` | 生成提示词 | ✅ | - |
| `server_project_dir` | 服务器项目目录 | ✅ | - |
| `checkpoint_path` | 模型文件路径 | ❌ | 自动推断 |
| `output_dir` | 本地输出目录 | ❌ | `output_{timestamp}` |

### 服务器命令参数（可自定义）

在 `client_sd_remote.py` 约第 180 行可添加更多参数：

```python
# 采样步数
command += ' --ddim_steps 50'

# CFG scale
command += ' --scale 7.5'

# img2img 强度
command += ' --strength 0.75'

# 生成数量
command += ' --n_samples 4'
```

## ⚙️ 技术栈

- **Python** 3.6+
- **paramiko** - SSH/SFTP 连接
- **requests** - HTTP 请求（HTTP API 方式）
- **标准库**: os, base64, json, datetime

## 📋 注意事项

1. ⚠️ **安全提示**: 不要将包含密码的脚本上传到公开仓库
2. 💾 **磁盘空间**: 定期清理服务器上的输入和输出文件
3. ⏱️ **生成时间**: 取决于服务器 GPU 性能和参数设置
4. 🔒 **SSH 密钥**: 建议使用 SSH 密钥认证替代密码
5. 🌐 **网络稳定**: 确保网络连接稳定，生成过程可能需要几分钟

## 📄 许可证

MIT License

---

**开发者**: 为远程 Stable Diffusion 调用而设计  
**最后更新**: 2025年10月  
**问题反馈**: 如有问题请查看文档或提 Issue

