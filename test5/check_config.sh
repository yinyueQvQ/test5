#!/bin/bash

echo "🔍 检查配置状态"
echo "========================================"

# 检查 Flask 服务器
echo ""
echo "1️⃣ 检查 Flask 服务器（端口 8000）"
if lsof -Pi :8000 -sTCP:LISTEN -t >/dev/null ; then
    echo "✅ Flask 服务器正在运行"
    lsof -Pi :8000 -sTCP:LISTEN
else
    echo "❌ Flask 服务器未运行"
    echo "   启动命令: python3 server_api_remote.py"
fi

# 检查 ngrok
echo ""
echo "2️⃣ 检查 ngrok"
if pgrep -x "ngrok" > /dev/null; then
    echo "✅ ngrok 正在运行"
    echo "   查看 ngrok 界面: http://localhost:4040"
else
    echo "❌ ngrok 未运行"
    echo "   启动命令: ngrok http 8000"
fi

# 测试本地连接
echo ""
echo "3️⃣ 测试本地连接"
if curl -s http://localhost:8000/health > /dev/null 2>&1; then
    echo "✅ 本地服务器可访问"
    curl -s http://localhost:8000/health
else
    echo "❌ 本地服务器不可访问"
fi

# 读取 Swift 配置
echo ""
echo "4️⃣ Swift 配置"
echo "当前 publicEndpoint："
grep "publicEndpoint.*https" StableDiffusionManager.swift | grep -v "//" | head -1

echo ""
echo "当前使用的端点："
grep "return.*Endpoint" StableDiffusionManager.swift | grep -v "//" | head -1

echo ""
echo "========================================"
echo "💡 提示："
echo "  - 如果 ngrok 未运行，执行: ngrok http 8000"
echo "  - 如果 URL 变了，更新 StableDiffusionManager.swift 中的 publicEndpoint"
echo "  - 拔数据线前确保所有检查都通过 ✅"



