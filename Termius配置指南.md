# Termius SSH 客户端配置指南 📱

## 📥 安装Termius

### Mac版
1. 打开 App Store
2. 搜索 "Termius"
3. 点击"获取"并安装

### iPhone版（可选）
同样在App Store搜索"Termius"安装

---

## ⚙️ 配置服务器连接

### 第一步：添加主机

1. 打开Termius
2. 点击左下角的 **"+"** 按钮
3. 选择 **"New Host"**

### 第二步：填写服务器信息

在弹出的表单中填写：

| 字段 | 值 |
|------|-----|
| **Label** | GPU服务器 |
| **Address** | `connect.westc.gpuhub.com` |
| **Port** | `42742` |
| **Username** | `root` |
| **Password** | `hHI9fR1QZ8g/` |

### 第三步：保存

点击右上角的 **"Save"** 或 **"保存"**

---

## 🚀 连接到服务器

### 方法1：双击连接
在主机列表中双击 "GPU服务器"

### 方法2：右键菜单
右键点击主机 → 选择 "Connect"

### 连接成功的标志
- 看到命令提示符：`[root@xxx ~]#`
- 可以输入命令了

---

## 📝 执行部署命令

连接成功后，在Termius的终端窗口中输入：

### 1. 检查文件是否上传
```bash
ls /root/sd-flask-api/
```

如果显示 "No such file or directory"，说明还没上传文件。

### 2. 上传文件（如果还没上传）

**方法A：用Termius的SFTP功能**
1. 在Termius中右键点击主机
2. 选择 "SFTP"
3. 将Mac上的文件拖入服务器的 `/root/sd-flask-api/` 目录

**方法B：在Mac终端运行部署脚本**
```bash
cd /Users/zhuojinli/Desktop/test5
./deploy_to_cloud.sh
```

### 3. 安装和启动

在Termius终端中执行：

```bash
# 进入目录
cd /root/sd-flask-api

# 查看文件
ls -la

# 添加执行权限
chmod +x install.sh

# 安装依赖
./install.sh

# 启动服务
./start.sh
```

### 4. 测试服务

```bash
curl http://127.0.0.1:8000/health
```

应该返回：`{"status":"ok"}`

---

## 🎨 Termius的优势

### 1. 保存连接信息
- 不用每次输入密码
- 一键连接

### 2. 多标签页
- 可以同时连接多个服务器
- 方便对比和操作

### 3. SFTP文件传输
- 直接拖拽上传文件
- 不需要用scp命令

### 4. 命令片段
- 保存常用命令
- 一键执行

### 5. 同步到手机
- Mac配置好后
- iPhone也能用同样的配置

---

## 📋 常用操作

### 查看服务状态
```bash
ps aux | grep server_api_remote
```

### 查看日志
```bash
tail -f /root/sd-flask-api/api.log
```

### 停止服务
```bash
cd /root/sd-flask-api
./stop.sh
```

### 重启服务
```bash
cd /root/sd-flask-api
./stop.sh
./start.sh
```

### 获取公网IP
```bash
curl ifconfig.me
```

---

## 🔥 进阶功能

### 1. 创建代码片段（Snippets）

在Termius中：
1. 点击 "Snippets"
2. 创建新片段
3. 保存常用命令

例如：
- 名称：启动Flask
- 命令：`cd /root/sd-flask-api && ./start.sh`

### 2. 端口转发

如果需要将服务器的端口映射到本地：
1. 右键主机 → Port Forwarding
2. 添加规则：
   - Local: 8000
   - Remote: 8000

### 3. 键盘快捷键

- `Cmd + T`：新建标签页
- `Cmd + W`：关闭当前标签
- `Cmd + 数字`：切换标签页

---

## ⚠️ 注意事项

### 1. 保持连接
- Termius会自动重连
- 如果断开，双击主机重新连接

### 2. 文件编辑
- 可以用 `vim` 或 `nano` 编辑文件
- 或者用SFTP下载到本地编辑后上传

### 3. 后台运行
- 关闭Termius后服务会继续运行
- 使用 `screen` 或 `nohup` 确保服务持续

---

## 🆘 故障排查

### 问题1：连接超时
- 检查网络连接
- 确认服务器IP和端口正确

### 问题2：密码错误
- 确认密码：`hHI9fR1QZ8g/`
- 注意大小写和特殊字符

### 问题3：权限被拒绝
- 确认用户名是 `root`
- 检查SSH密钥设置

### 问题4：SFTP无法连接
- 右键主机 → Edit
- 确认SFTP设置已启用

---

## 🎯 快速测试清单

连接成功后，依次执行：

```bash
# 1. 确认当前位置
pwd

# 2. 查看Python版本
python3 --version

# 3. 检查磁盘空间
df -h

# 4. 查看内存
free -h

# 5. 测试网络
ping -c 3 baidu.com

# 6. 进入部署目录
cd /root/sd-flask-api

# 7. 列出文件
ls -la
```

---

## 📱 iPhone上使用Termius

如果你安装了iPhone版Termius：

1. 打开Termius
2. 登录同一个账号
3. 连接配置会自动同步
4. 点击主机即可连接

**优点**：
- 随时随地管理服务器
- 查看日志
- 紧急重启服务

---

## 🎉 其他推荐工具

### 1. VS Code Remote SSH
- 在VS Code中直接编辑服务器文件
- 适合写代码

### 2. Cyberduck（文件传输）
- SFTP客户端
- 专门用于上传/下载文件

### 3. iTerm2 + Oh My Zsh
- 增强版终端
- 更美观的界面

---

更新时间：2025-10-31

