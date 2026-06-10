#!/bin/bash
# 部署Flask API到云服务器的脚本
# 使用方法：./deploy_to_cloud.sh

set -e  # 遇到错误立即停止

echo "🚀 开始部署 Flask API 到云服务器..."
echo ""

# 服务器配置
SERVER_HOST="${SERVER_HOST:-your-server-host}"
SERVER_PORT="${SERVER_PORT:-22}"
SERVER_USER="root"
DEPLOY_DIR="/root/sd-flask-api"

echo "📊 服务器信息："
echo "  - 主机: ${SERVER_HOST}"
echo "  - 端口: ${SERVER_PORT}"
echo "  - 用户: ${SERVER_USER}"
echo "  - 部署目录: ${DEPLOY_DIR}"
echo ""

# 检查本地文件
echo "📁 检查本地文件..."
if [ ! -f "test5/server_api_remote.py" ]; then
    echo "❌ 找不到 server_api_remote.py"
    exit 1
fi

if [ ! -f "test5/client_sd_remote.py" ]; then
    echo "❌ 找不到 client_sd_remote.py"
    exit 1
fi

echo "✅ 本地文件检查完成"
echo ""

# 创建临时部署包
echo "📦 创建部署包..."
mkdir -p deploy_package
cp test5/server_api_remote.py deploy_package/
cp test5/client_sd_remote.py deploy_package/

# 创建requirements.txt
cat > deploy_package/requirements.txt <<EOF
flask==2.3.0
flask-cors==4.0.0
pillow==10.0.0
paramiko==3.3.1
EOF

# 创建服务器端安装脚本
cat > deploy_package/install.sh <<'EOF'
#!/bin/bash
# 在服务器上执行的安装脚本

echo "🔧 服务器端安装开始..."

# 检查Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 未安装，正在安装..."
    yum install -y python3 python3-pip || apt install -y python3 python3-pip
fi

echo "✅ Python版本: $(python3 --version)"

# 安装pip依赖
echo "📦 安装Python依赖..."
pip3 install --user flask flask-cors pillow paramiko

# 创建启动脚本
cat > start.sh <<'STARTEOF'
#!/bin/bash
cd /root/sd-flask-api
nohup python3 server_api_remote.py > api.log 2>&1 &
echo "✅ Flask API 已启动"
echo "📝 查看日志: tail -f /root/sd-flask-api/api.log"
echo "🌐 服务地址: http://服务器公网IP:8000"
STARTEOF

chmod +x start.sh

# 创建停止脚本
cat > stop.sh <<'STOPEOF'
#!/bin/bash
pkill -f server_api_remote.py
echo "⏹️  Flask API 已停止"
STOPEOF

chmod +x stop.sh

echo ""
echo "✅ 安装完成！"
echo ""
echo "📋 接下来的操作："
echo "  1. 启动服务: ./start.sh"
echo "  2. 查看日志: tail -f api.log"
echo "  3. 停止服务: ./stop.sh"
echo ""
EOF

chmod +x deploy_package/install.sh

echo "✅ 部署包创建完成"
echo ""

# 上传文件到服务器
echo "📤 上传文件到服务器..."
echo "⚠️  需要输入服务器密码（请勿将密码写入脚本或提交到 Git）"
echo ""

# 创建目录并上传文件
ssh -p ${SERVER_PORT} ${SERVER_USER}@${SERVER_HOST} "mkdir -p ${DEPLOY_DIR}" && \
scp -P ${SERVER_PORT} deploy_package/* ${SERVER_USER}@${SERVER_HOST}:${DEPLOY_DIR}/

if [ $? -eq 0 ]; then
    echo "✅ 文件上传成功"
else
    echo "❌ 文件上传失败"
    exit 1
fi

echo ""
echo "🎉 部署包已上传到服务器！"
echo ""
echo "📋 下一步操作："
echo ""
echo "1️⃣  SSH连接到服务器："
echo "   ssh -p ${SERVER_PORT} ${SERVER_USER}@${SERVER_HOST}"
echo "   密码: （运行时手动输入）"
echo ""
echo "2️⃣  在服务器上执行安装："
echo "   cd ${DEPLOY_DIR}"
echo "   chmod +x install.sh"
echo "   ./install.sh"
echo ""
echo "3️⃣  启动Flask API："
echo "   ./start.sh"
echo ""
echo "4️⃣  测试访问："
echo "   curl http://服务器公网IP:8000/health"
echo ""
echo "5️⃣  查看日志："
echo "   tail -f api.log"
echo ""

# 清理临时文件
rm -rf deploy_package

echo "✅ 部署脚本执行完成！"

