#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Stable Diffusion HTTP API 服务端（通过 SSH 连接远程服务器）
为 iOS 应用提供 HTTP API 接口，实际生成在远程服务器上进行
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import base64
import os
import io
import logging
from datetime import datetime
from PIL import Image
import sys

# 添加 client_sd_remote 的路径
sys.path.insert(0, os.path.dirname(__file__))

try:
    from client_sd_remote import SDRemoteClient
    HAS_SSH_CLIENT = True
except ImportError:
    HAS_SSH_CLIENT = False
    print("⚠️  警告: 无法导入 client_sd_remote，将使用模拟模式")

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# 创建 Flask 应用
app = Flask(__name__)
CORS(app)  # 允许跨域请求

# ============ 配置区域 ============
# 远程服务器配置（根据 README.md）
SERVER_CONFIG = {
    "host": "your-server-host",
    "port": 22,
    "username": "root",
    "password": "YOUR_PASSWORD"
}

# 服务器上的 SD 项目路径
SERVER_PROJECT_DIR = "/root/stablediffusion-main"
CHECKPOINT_PATH = f"{SERVER_PROJECT_DIR}/ckpt/512-base-ema.ckpt"

# 本地临时目录
TEMP_DIR = "/tmp/sd_api"
os.makedirs(TEMP_DIR, exist_ok=True)

# ============ API 端点 ============

@app.route('/health', methods=['GET'])
def health_check():
    """健康检查"""
    return jsonify({
        'status': 'ok',
        'message': 'Stable Diffusion API is running',
        'timestamp': datetime.now().isoformat(),
        'ssh_client_available': HAS_SSH_CLIENT,
        'server': SERVER_CONFIG["host"]
    })


@app.route('/test', methods=['POST'])
def test_connection():
    """测试远程服务器连接"""
    if not HAS_SSH_CLIENT:
        return jsonify({
            'success': False,
            'error': '缺少 paramiko 库，请安装: pip3 install paramiko'
        }), 500
    
    try:
        logger.info("测试远程服务器连接...")
        
        client = SDRemoteClient(
            host=SERVER_CONFIG["host"],
            port=SERVER_CONFIG["port"],
            username=SERVER_CONFIG["username"],
            password=SERVER_CONFIG["password"]
        )
        
        if client.connect():
            client.disconnect()
            logger.info("✅ 连接测试成功")
            return jsonify({
                'success': True,
                'message': '成功连接到远程 SD 服务器',
                'server': SERVER_CONFIG["host"],
                'port': SERVER_CONFIG["port"]
            })
        else:
            logger.error("❌ 连接测试失败")
            return jsonify({
                'success': False,
                'error': '无法连接到远程 SD 服务器'
            }), 500
    
    except Exception as e:
        logger.error(f"连接测试出错: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@app.route('/generate', methods=['POST'])
def generate_image():
    """
    图像生成 API
    
    请求体 (JSON):
    {
        "prompt": "提示词",
        "image_base64": "base64 编码的图像",
        "steps": 50,  // 可选
        "strength": 0.75  // 可选
    }
    
    响应 (JSON):
    {
        "success": true/false,
        "images": ["base64_image1", "base64_image2", ...],
        "error": "错误信息（如果失败）"
    }
    """
    
    # 如果没有 SSH 客户端，返回模拟结果
    if not HAS_SSH_CLIENT:
        logger.warning("⚠️  使用模拟模式（缺少 paramiko）")
        return simulate_generation(request.json)
    
    try:
        logger.info("="*70)
        logger.info("收到图像生成请求")
        logger.info("="*70)
        
        # 1. 解析请求
        data = request.json
        if not data:
            return jsonify({
                'success': False,
                'error': '无效的请求数据'
            }), 400
        
        prompt = data.get('prompt', '')
        image_base64 = data.get('image_base64', '')
        steps = data.get('steps', 50)
        strength = data.get('strength', 0.75)
        
        if not prompt:
            return jsonify({
                'success': False,
                'error': '提示词不能为空'
            }), 400
        
        if not image_base64:
            return jsonify({
                'success': False,
                'error': '输入图像不能为空'
            }), 400
        
        logger.info(f"提示词: {prompt[:100]}...")
        logger.info(f"参数: steps={steps}, strength={strength}")
        
        # 2. 解码并保存输入图像
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        temp_input = os.path.join(TEMP_DIR, f"input_{timestamp}.jpg")
        temp_output = os.path.join(TEMP_DIR, f"output_{timestamp}")
        
        try:
            # 解码 base64
            if ',' in image_base64:
                image_base64 = image_base64.split(',')[1]
            
            image_data = base64.b64decode(image_base64)
            image = Image.open(io.BytesIO(image_data))
            
            # 转换为 RGB（如果是 RGBA）
            if image.mode == 'RGBA':
                background = Image.new('RGB', image.size, (255, 255, 255))
                background.paste(image, mask=image.split()[3])
                image = background
            elif image.mode != 'RGB':
                image = image.convert('RGB')
            
            # 确保图片大小合适（至少512x512）
            if image.size[0] < 512 or image.size[1] < 512:
                logger.info(f"图片太小 ({image.size})，调整到 512x512")
                image = image.resize((512, 512), Image.Resampling.LANCZOS)
            
            # 保存为 JPEG
            image.save(temp_input, 'JPEG', quality=95)
            logger.info(f"✅ 输入图像已保存: {temp_input} (尺寸: {image.size})")
            
        except Exception as e:
            logger.error(f"❌ 图像解码失败: {e}")
            return jsonify({
                'success': False,
                'error': f'图像解码失败: {str(e)}'
            }), 400
        
        # 3. 连接远程 SD 服务器
        logger.info("正在连接远程 Stable Diffusion 服务器...")
        client = SDRemoteClient(
            host=SERVER_CONFIG["host"],
            port=SERVER_CONFIG["port"],
            username=SERVER_CONFIG["username"],
            password=SERVER_CONFIG["password"]
        )
        
        try:
            if not client.connect():
                logger.error("❌ 无法连接到远程 SD 服务器 - client.connect() 返回 False")
                return jsonify({
                    'success': False,
                    'error': '无法连接到远程 Stable Diffusion 服务器 (连接失败)'
                }), 500
        except Exception as e:
            logger.error(f"❌ 连接远程 SD 服务器时发生异常: {e}", exc_info=True)
            return jsonify({
                'success': False,
                'error': f'无法连接到远程 Stable Diffusion 服务器 (异常: {str(e)})'
            }), 500

        
        try:
            # 4. 执行图像生成（传递 steps 和 strength 参数）
            logger.info("开始远程生成图像...")
            generated_files = client.generate_image(
                local_image_path=temp_input,
                prompt=prompt,
                server_project_dir=SERVER_PROJECT_DIR,
                checkpoint_path=CHECKPOINT_PATH,
                output_dir=temp_output,
                steps=steps,  # 传递步数参数以优化速度
                strength=strength  # 传递强度参数
            )
            
            if not generated_files:
                logger.error("❌ 图像生成失败")
                return jsonify({
                    'success': False,
                    'error': '图像生成失败，请查看服务器日志'
                }), 500
            
            # 5. 读取并编码生成的图像（只返回最新的一张）
            # 过滤掉 grid 图片，只要单张生成的图片
            single_images = [f for f in generated_files if 'grid' not in os.path.basename(f).lower()]
            
            if not single_images:
                logger.warning("⚠️  没有找到单张图片，使用所有文件")
                single_images = generated_files
            
            # 按文件名排序，取最新的一张（通常文件名是递增的数字）
            single_images.sort(reverse=True)
            target_image = single_images[0]
            
            logger.info(f"📌 选择图像: {target_image} (共 {len(generated_files)} 个文件)")
            
            result_images = []
            try:
                with open(target_image, 'rb') as f:
                    img_data = f.read()
                    img_base64 = base64.b64encode(img_data).decode('utf-8')
                    result_images.append(img_base64)
                logger.info(f"✅ 已编码图像: {target_image}")
            except Exception as e:
                logger.error(f"❌ 无法读取生成的图像 {target_image}: {e}")
                return jsonify({
                    'success': False,
                    'error': f'无法读取生成的图像: {e}'
                }), 500
            
            logger.info(f"✅ 成功生成并返回 1 张图像 (实际生成了 {len(generated_files)} 张)")
            
            # 6. 清理临时文件
            try:
                os.remove(temp_input)
                for file_path in generated_files:
                    if os.path.exists(file_path):
                        os.remove(file_path)
                if os.path.exists(temp_output) and not os.listdir(temp_output):
                    os.rmdir(temp_output)
                logger.info("✅ 临时文件已清理")
            except Exception as e:
                logger.warning(f"⚠️  清理临时文件失败: {e}")
            
            # 7. 返回结果
            return jsonify({
                'success': True,
                'images': result_images,
                'count': len(result_images)
            })
            
        finally:
            # 8. 断开连接
            client.disconnect()
            logger.info("已断开与远程 SD 服务器的连接")
    
    except Exception as e:
        logger.error(f"❌ 处理请求时出错: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'error': f'服务器内部错误: {str(e)}'
        }), 500


def simulate_generation(data):
    """模拟生成（当无法连接远程服务器时）"""
    logger.warning("使用模拟模式生成")
    
    # 创建一个简单的模拟图像
    image = Image.new('RGB', (512, 512), color=(100, 150, 200))
    
    # 转换为 base64
    buffer = io.BytesIO()
    image.save(buffer, format='PNG')
    img_base64 = base64.b64encode(buffer.getvalue()).decode('utf-8')
    
    return jsonify({
        'success': True,
        'images': [img_base64],
        'count': 1,
        'note': '这是模拟结果（无法连接远程服务器）'
    })


# ============ 主函数 ============

if __name__ == '__main__':
    logger.info("=" * 70)
    logger.info("Stable Diffusion HTTP API 服务启动（远程模式）")
    logger.info("=" * 70)
    logger.info(f"远程服务器: {SERVER_CONFIG['host']}:{SERVER_CONFIG['port']}")
    logger.info(f"项目目录: {SERVER_PROJECT_DIR}")
    logger.info(f"SSH 客户端: {'可用' if HAS_SSH_CLIENT else '不可用（模拟模式）'}")
    logger.info(f"API 端点:")
    logger.info(f"  - GET  /health   - 健康检查")
    logger.info(f"  - POST /test     - 测试连接")
    logger.info(f"  - POST /generate - 生成图像")
    logger.info("=" * 70)
    
    if not HAS_SSH_CLIENT:
        logger.warning("⚠️  警告: 缺少 paramiko 库")
        logger.warning("   安装方法: pip3 install paramiko")
        logger.warning("   当前将使用模拟模式")
    
    # 启动服务
    # 0.0.0.0 表示监听所有网络接口，允许外部访问
    app.run(
        host='0.0.0.0',  # 允许外部访问
        port=8000,       # API 端口
        debug=False,     # 生产环境设为 False
        threaded=True    # 支持并发请求
    )

