#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Stable Diffusion HTTP API 服务器
接收来自 iOS App 的请求，调用 SD 生成图片
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import base64
import io
import os
import sys
from PIL import Image
from datetime import datetime
import tempfile
import subprocess

app = Flask(__name__)
CORS(app)

# ============ 配置 ============
PROJECT_DIR = "/root/stablediffusion-main"  # 你的 SD 项目目录
CHECKPOINT_PATH = f"{PROJECT_DIR}/ckpt/512-base-ema.ckpt"  # 模型路径
OUTPUT_DIR = f"{PROJECT_DIR}/api_outputs"  # 输出目录

os.makedirs(OUTPUT_DIR, exist_ok=True)

@app.route('/test', methods=['GET'])
def test():
    """测试接口"""
    return jsonify({
        'status': 'ok',
        'message': 'Server is running',
        'project_dir': PROJECT_DIR
    })

@app.route('/health', methods=['GET'])
def health():
    """健康检查"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat()
    })

@app.route('/generate', methods=['POST'])
def generate():
    """
    图像生成接口
    
    请求格式:
    {
        "image_base64": "base64字符串",
        "prompt": "提示词",
        "negative_prompt": "负面提示词",
        "steps": 30,
        "cfg_scale": 7.5,
        "strength": 0.75
    }
    """
    try:
        print("\n" + "="*60)
        print("收到生成请求")
        print("="*60)
        
        data = request.json
        image_base64 = data.get('image_base64', '')
        prompt = data.get('prompt', 'beautiful artwork')
        negative_prompt = data.get('negative_prompt', 'bad quality, blurry, distorted, ugly')
        steps = data.get('steps', 30)
        cfg_scale = data.get('cfg_scale', 7.5)
        strength = data.get('strength', 0.75)
        
        print(f"提示词: {prompt}")
        print(f"步数: {steps}")
        print(f"CFG: {cfg_scale}")
        print(f"强度: {strength}")
        
        # 1. 解码 base64 图片
        print("\n[1/5] 解码输入图片...")
        if ',' in image_base64:
            image_base64 = image_base64.split(',')[1]
        
        image_data = base64.b64decode(image_base64)
        image = Image.open(io.BytesIO(image_data))
        print(f"图片尺寸: {image.size}")
        
        # 2. 保存临时输入文件
        print("[2/5] 保存临时文件...")
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        temp_input = f"{PROJECT_DIR}/inputs/input_{timestamp}.png"
        os.makedirs(os.path.dirname(temp_input), exist_ok=True)
        image.save(temp_input)
        print(f"保存到: {temp_input}")
        
        # 3. 调用 img2img 脚本
        print("[3/5] 运行 Stable Diffusion...")
        
        # 创建唯一的输出目录（避免读取旧图片）
        unique_output_dir = f"{OUTPUT_DIR}/run_{timestamp}"
        os.makedirs(unique_output_dir, exist_ok=True)
        
        # 生成随机种子（确保每次结果不同）
        import random
        random_seed = random.randint(1, 999999999)
        
        # 构建命令
        # 注意：旧版本的 img2img.py 可能不支持某些参数，这里只使用基本参数
        cmd = [
            'python',
            f'{PROJECT_DIR}/scripts/img2img.py',
            '--prompt', prompt,
            '--init-img', temp_input,
            '--ckpt', CHECKPOINT_PATH,
            '--n_samples', '1',
            '--n_iter', '1',
            '--scale', str(cfg_scale),
            '--strength', str(strength),
            '--ddim_steps', str(steps),
            '--seed', str(random_seed),  # 添加随机种子
            '--outdir', unique_output_dir
        ]
        
        print(f"随机种子: {random_seed}")
        
        # 移除 negative_prompt，因为旧版本 img2img.py 不支持这个参数
        
        print(f"执行命令: {' '.join(cmd)}")
        
        # 记录开始时间（用于筛选新生成的文件）
        import time
        start_time = time.time()
        print(f"⏰ 开始生成时间: {datetime.fromtimestamp(start_time)}")
        
        # 执行命令
        result = subprocess.run(
            cmd,
            cwd=PROJECT_DIR,
            capture_output=True,
            text=True,
            timeout=300  # 5分钟超时
        )
        
        # 显示完整输出（用于调试）
        print("=" * 60)
        print("SD 命令输出 (stdout):")
        print(result.stdout)
        print("=" * 60)
        if result.stderr:
            print("SD 命令错误 (stderr):")
            print(result.stderr)
            print("=" * 60)
        
        if result.returncode != 0:
            print(f"✗ 执行失败 (退出码: {result.returncode})")
            return jsonify({
                'success': False,
                'message': f'生成失败: {result.stderr}'
            }), 500
        
        print("✓ 生成完成")
        
        # 4. 读取 SD 生成的文件
        print("[4/5] 读取生成结果...")
        
        # 首先检查 SD 输出到的唯一目录（--outdir 参数指定的）
        sd_output_path = f"{unique_output_dir}/img2img-samples/samples"
        
        if not os.path.exists(sd_output_path):
            # 如果唯一目录不存在，检查是否直接输出到了 unique_output_dir
            sd_output_path = unique_output_dir
        
        # 在 SD 输出目录中搜索所有 PNG 文件（递归搜索）
        import glob
        generated_files = glob.glob(f"{unique_output_dir}/**/*.png", recursive=True)
        
        if not generated_files:
            return jsonify({
                'success': False,
                'message': f'SD 没有在 {unique_output_dir} 生成任何文件'
            }), 500
        
        # 获取最新的文件（按修改时间）
        files_with_time = [(f, os.path.getmtime(f)) for f in generated_files]
        files_with_time.sort(key=lambda x: x[1], reverse=True)
        latest_file = files_with_time[0][0]
        
        print(f"✅ 找到新生成的文件: {latest_file}")
        print(f"   修改时间: {datetime.fromtimestamp(files_with_time[0][1])}")
        
        # 复制到输出目录，使用唯一命名
        import shutil
        unique_result_filename = f"generated_{timestamp}.png"
        unique_result_path = os.path.join(OUTPUT_DIR, unique_result_filename)
        shutil.copy2(latest_file, unique_result_path)
        print(f"💾 保存副本到: {unique_result_path}")
        
        # 5. 编码为 base64
        print("[5/5] 编码返回...")
        with open(unique_result_path, 'rb') as f:
            result_data = f.read()
            result_base64 = base64.b64encode(result_data).decode()
        
        # 清理临时文件（可选）
        try:
            os.remove(temp_input)
        except:
            pass
        
        print("✅ 完成！")
        print("="*60 + "\n")
        
        return jsonify({
            'success': True,
            'images': [result_base64],
            'message': '生成成功'
        })
        
    except subprocess.TimeoutExpired:
        print("✗ 生成超时")
        return jsonify({
            'success': False,
            'message': '生成超时，请减少步数或降低分辨率'
        }), 500
        
    except Exception as e:
        print(f"✗ 错误: {e}")
        import traceback
        traceback.print_exc()
        
        return jsonify({
            'success': False,
            'message': f'服务器错误: {str(e)}'
        }), 500

if __name__ == '__main__':
    print("="*60)
    print("Stable Diffusion HTTP API 服务器")
    print("="*60)
    print(f"项目目录: {PROJECT_DIR}")
    print(f"模型路径: {CHECKPOINT_PATH}")
    print(f"监听地址: http://0.0.0.0:8000")
    print("\n使用 Ctrl+C 停止服务器")
    print("="*60 + "\n")
    
    app.run(
        host='0.0.0.0',
        port=8000,
        debug=False,
        threaded=True
    )

