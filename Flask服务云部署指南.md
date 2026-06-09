# Flask API 云服务器部署完整指南 🚀

## 📋 目标

将 `server_api_remote.py` 部署到云服务器，让iPhone在任何网络下都能访问。

---

## 第一步：准备云服务器 ☁️

### 选择云服务商

推荐使用：
- **阿里云** (国内速度快)
- **腾讯云** (新用户优惠多)
- **AWS** (国际化)
- **DigitalOcean** (便宜，国外)

### 服务器配置建议

**基础配置**（Flask API不需要GPU）：
- CPU: 1-2核
- 内存: 2GB
- 存储: 20GB
- 带宽: 1-3Mbps
- 系统: Ubuntu 22.04 / CentOS 7+

💰 **费用**：约 50-100元/月

### 购买后获取信息

记录以下信息：
- 公网IP地址：如 `123.456.789.10`
- SSH端口：通常是 `22`
- 用户名：通常是 `root`
- 密码：购买时设置的

---

## 第二步：连接到云服务器 🔐

### 方法1：使用终端（Mac/Linux）

```bash
# SSH连接到服务器
ssh root@123.456.789.10

# 输入密码后即可登录
```

### 方法2：配置SSH密钥（推荐，更安全）

```bash
# 1. 生成密钥对（如果还没有）
ssh-keygen -t rsa -b 4096

# 2. 复制公钥到服务器
ssh-copy-id root@123.456.789.10

# 3. 以后就可以免密登录
ssh root@123.456.789.10
```

---

## 第三步：服务器环境配置 ⚙️

登录到服务器后，执行以下命令：

### 1. 更新系统

```bash
# Ubuntu/Debian
sudo apt update
sudo apt upgrade -y

# CentOS/RedHat
sudo yum update -y
```

### 2. 安装Python 3.9+

```bash
# Ubuntu/Debian
sudo apt install python3 python3-pip python3-venv -y

# CentOS/RedHat
sudo yum install python3 python3-pip -y

# 验证安装
python3 --version
pip3 --version
```

### 3. 安装必要工具

```bash
# 安装 git, screen, vim 等工具
sudo apt install git screen vim curl -y  # Ubuntu
# 或
sudo yum install git screen vim curl -y  # CentOS
```

---

## 第四步：上传项目文件 📤

### 方法1：使用 SCP 上传（推荐）

在**你的Mac终端**执行（不是服务器）：

```bash
# 进入项目目录
cd /Users/zhuojinli/Desktop/test5

# 创建部署文件夹（临时）
mkdir -p deploy_files
cp test5/server_api_remote.py deploy_files/
cp test5/client_sd_remote.py deploy_files/
cp test5/requirements.txt deploy_files/

# 上传到服务器
scp -r deploy_files/* root@123.456.789.10:/root/sd-api/

# 清理临时文件
rm -rf deploy_files
```

### 方法2：使用 Git（如果项目在GitHub）

在**服务器**执行：

```bash
# 克隆项目
cd /root
git clone https://github.com/你的用户名/你的项目.git sd-api
cd sd-api
```

### 方法3：手动创建文件

如果文件不多，可以直接在服务器上创建：

```bash
# 在服务器上
mkdir -p /root/sd-api
cd /root/sd-api

# 创建文件
vim server_api_remote.py
# 粘贴代码内容，保存退出（:wq）

vim client_sd_remote.py
# 粘贴代码内容

vim requirements.txt
# 粘贴依赖列表
```

---

## 第五步：安装Python依赖 📦

在**服务器**上执行：

```bash
cd /root/sd-api

# 创建虚拟环境
python3 -m venv venv

# 激活虚拟环境
source venv/bin/activate

# 安装依赖
pip install -U pip
pip install flask flask-cors pillow paramiko

# 或者使用 requirements.txt
pip install -r requirements.txt
```

---

## 第六步：测试运行 🧪

### 1. 先测试能否运行

```bash
cd /root/sd-api
source venv/bin/activate

# 临时运行（测试用）
python server_api_remote.py
```

应该看到：
```
 * Running on http://0.0.0.0:8000
```

按 `Ctrl+C` 停止。

### 2. 测试API是否工作

打开新终端，测试健康检查：

```bash
curl http://你的服务器IP:8000/health
# 应该返回：{"status": "ok"}
```

---

## 第七步：配置后台运行 🔄

让服务在后台持续运行，即使SSH断开也不会停止。

### 方法1：使用 screen（简单）

```bash
# 创建一个screen会话
screen -S sd-api

# 在screen中启动服务
cd /root/sd-api
source venv/bin/activate
python server_api_remote.py

# 按 Ctrl+A 然后按 D 退出screen（服务继续运行）

# 以后查看运行状态
screen -r sd-api

# 列出所有screen会话
screen -ls
```

### 方法2：使用 systemd（推荐，生产环境）

创建systemd服务文件：

```bash
sudo vim /etc/systemd/system/sd-api.service
```

写入以下内容：

```ini
[Unit]
Description=Stable Diffusion API Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/sd-api
Environment="PATH=/root/sd-api/venv/bin"
ExecStart=/root/sd-api/venv/bin/python server_api_remote.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

启动服务：

```bash
# 重载systemd配置
sudo systemctl daemon-reload

# 启动服务
sudo systemctl start sd-api

# 设置开机自启
sudo systemctl enable sd-api

# 查看服务状态
sudo systemctl status sd-api

# 查看日志
sudo journalctl -u sd-api -f
```

常用命令：
```bash
sudo systemctl start sd-api    # 启动
sudo systemctl stop sd-api     # 停止
sudo systemctl restart sd-api  # 重启
sudo systemctl status sd-api   # 查看状态
```

### 方法3：使用 nohup（最简单）

```bash
cd /root/sd-api
source venv/bin/activate
nohup python server_api_remote.py > sd-api.log 2>&1 &

# 查看日志
tail -f sd-api.log
```

---

## 第八步：配置防火墙 🔥

确保8000端口可以被外部访问：

### Ubuntu (UFW)

```bash
# 允许8000端口
sudo ufw allow 8000/tcp

# 查看规则
sudo ufw status
```

### CentOS (firewalld)

```bash
# 允许8000端口
sudo firewall-cmd --permanent --add-port=8000/tcp
sudo firewall-cmd --reload

# 查看规则
sudo firewall-cmd --list-ports
```

### 云服务器安全组

⚠️ **重要**：还需要在云服务商控制台配置安全组：

1. 登录云服务商控制台（阿里云/腾讯云等）
2. 找到你的云服务器
3. 进入"安全组"设置
4. 添加规则：
   - 协议：TCP
   - 端口：8000
   - 来源：0.0.0.0/0（允许所有IP）
5. 保存

---

## 第九步：测试公网访问 🌐

### 在你的Mac或iPhone上测试

```bash
# 测试健康检查
curl http://你的服务器公网IP:8000/health

# 应该返回
{"status": "ok"}
```

如果成功，说明部署完成！🎉

---

## 第十步：更新iOS代码 📱

修改 `test5/StableDiffusionManager.swift`：

```swift
// 🌐 服务器地址配置
private let localEndpoint = "http://192.168.31.11:8000/generate"
private let publicEndpoint = "http://你的服务器公网IP:8000/generate"  // ← 改这里

// 🔧 使用公网地址
private var apiEndpoint: String {
    return publicEndpoint  // ← 改这里
}
```

重新运行iOS应用，在任何网络下都能用了！📱✨

---

## 进阶：配置域名和HTTPS 🔒

### 1. 购买域名（可选）

在阿里云、腾讯云、GoDaddy等购买域名，如：
- `myapp-api.com`

### 2. 配置DNS解析

在域名管理后台添加A记录：
- 主机记录：`@` 或 `api`
- 记录类型：`A`
- 记录值：你的服务器公网IP
- TTL：600

### 3. 安装Nginx和SSL证书

```bash
# 安装Nginx
sudo apt install nginx -y

# 安装Certbot（Let's Encrypt免费SSL）
sudo apt install certbot python3-certbot-nginx -y

# 获取SSL证书
sudo certbot --nginx -d myapp-api.com

# 配置Nginx反向代理
sudo vim /etc/nginx/sites-available/sd-api
```

Nginx配置示例：

```nginx
server {
    listen 80;
    server_name myapp-api.com;
    
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

启用配置：

```bash
sudo ln -s /etc/nginx/sites-available/sd-api /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 4. 更新iOS代码使用域名

```swift
private let publicEndpoint = "https://myapp-api.com/generate"
```

---

## 🔍 故障排查

### 问题1：无法访问8000端口

```bash
# 1. 检查服务是否运行
ps aux | grep server_api_remote

# 2. 检查端口是否监听
netstat -tuln | grep 8000
# 或
ss -tuln | grep 8000

# 3. 检查防火墙
sudo ufw status  # Ubuntu
sudo firewall-cmd --list-ports  # CentOS

# 4. 检查云服务商安全组
# 登录控制台查看
```

### 问题2：服务启动失败

```bash
# 查看详细错误日志
cd /root/sd-api
source venv/bin/activate
python server_api_remote.py

# 或查看systemd日志
sudo journalctl -u sd-api -n 50
```

### 问题3：无法连接远程GPU服务器

```bash
# 测试SSH连接
ssh root@connect.westc.gpuhub.com -p 42742

# 检查密码是否正确
# 检查网络是否通畅
```

### 问题4：内存不足

```bash
# 查看内存使用
free -h

# 如果内存不足，增加swap
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

---

## 📊 监控和日志

### 查看服务状态

```bash
# systemd服务
sudo systemctl status sd-api

# 查看实时日志
sudo journalctl -u sd-api -f

# screen会话
screen -r sd-api
```

### 设置日志轮转

创建 `/etc/logrotate.d/sd-api`：

```
/root/sd-api/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 0640 root root
}
```

---

## 💰 成本估算

| 项目 | 费用 | 说明 |
|------|------|------|
| 云服务器 | 50-100元/月 | 基础配置足够 |
| 域名 | 50-100元/年 | 可选 |
| SSL证书 | 免费 | Let's Encrypt |
| 带宽 | 包含在服务器内 | - |
| **总计** | **约60-110元/月** | - |

---

## ✅ 部署检查清单

- [ ] 云服务器购买完成
- [ ] SSH可以正常连接
- [ ] Python环境安装完成
- [ ] 项目文件已上传
- [ ] 依赖包安装完成
- [ ] 服务可以正常启动
- [ ] 防火墙规则已配置
- [ ] 安全组规则已配置
- [ ] 可以通过公网IP访问
- [ ] iOS代码已更新
- [ ] 后台运行配置完成
- [ ] （可选）域名已配置
- [ ] （可选）HTTPS已配置

---

## 🎯 快速部署脚本

把以下脚本保存为 `deploy.sh`，一键部署：

```bash
#!/bin/bash
# 在服务器上执行

echo "🚀 开始部署 Stable Diffusion API..."

# 创建目录
mkdir -p /root/sd-api
cd /root/sd-api

# 创建虚拟环境
python3 -m venv venv
source venv/bin/activate

# 安装依赖
pip install -U pip
pip install flask flask-cors pillow paramiko

# 创建systemd服务
cat > /etc/systemd/system/sd-api.service <<EOF
[Unit]
Description=Stable Diffusion API Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/sd-api
Environment="PATH=/root/sd-api/venv/bin"
ExecStart=/root/sd-api/venv/bin/python server_api_remote.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# 启动服务
systemctl daemon-reload
systemctl start sd-api
systemctl enable sd-api

# 配置防火墙
ufw allow 8000/tcp

echo "✅ 部署完成！"
echo "📊 查看状态: systemctl status sd-api"
echo "📝 查看日志: journalctl -u sd-api -f"
```

使用方法：
```bash
chmod +x deploy.sh
./deploy.sh
```

---

更新时间：2025-10-31

