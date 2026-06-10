#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Stable Diffusion 远程调用客户端
从本地电脑发送图片到服务器，执行生成，并下载结果
"""

import paramiko
import os
import time
from datetime import datetime
import json


class SDRemoteClient:
    """Stable Diffusion 远程客户端"""
    
    def __init__(self, host, port, username, password):
        """
        初始化远程连接
        
        参数:
            host: 服务器地址
            port: SSH 端口
            username: 用户名
            password: 密码
        """
        self.host = host
        self.port = port
        self.username = username
        self.password = password
        self.ssh_client = None
        self.sftp_client = None
        
    def connect(self):
        """建立 SSH 连接"""
        try:
            print(f"正在连接到服务器 {self.host}:{self.port}...")
            
            # 创建 SSH 客户端
            self.ssh_client = paramiko.SSHClient()
            self.ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            
            # 连接服务器
            self.ssh_client.connect(
                hostname=self.host,
                port=self.port,
                username=self.username,
                password=self.password,
                timeout=30
            )
            
            # 创建 SFTP 客户端
            self.sftp_client = self.ssh_client.open_sftp()
            
            print("✓ 连接成功！")
            return True
            
        except Exception as e:
            print(f"✗ 连接失败: {e}")
            return False
    
    def disconnect(self):
        """关闭连接"""
        if self.sftp_client:
            self.sftp_client.close()
        if self.ssh_client:
            self.ssh_client.close()
        print("连接已关闭")
    
    def upload_file(self, local_path, remote_path):
        """
        上传文件到服务器
        
        参数:
            local_path: 本地文件路径
            remote_path: 服务器路径
        
        返回:
            bool: 是否成功
        """
        try:
            print(f"正在上传文件: {local_path} -> {remote_path}")
            
            # 确保远程目录存在
            remote_dir = os.path.dirname(remote_path)
            try:
                self.sftp_client.stat(remote_dir)
            except FileNotFoundError:
                # 创建远程目录
                self._mkdir_p(remote_dir)
            
            # 上传文件
            self.sftp_client.put(local_path, remote_path)
            
            print(f"✓ 上传成功")
            return True
            
        except Exception as e:
            print(f"✗ 上传失败: {e}")
            return False
    
    def _mkdir_p(self, remote_directory):
        """递归创建远程目录"""
        dirs = []
        dir = remote_directory
        while len(dir) > 1:
            dirs.append(dir)
            dir = os.path.dirname(dir)
        
        if len(dir) == 1 and not dir.startswith("/"):
            dirs.append(dir)
        
        while len(dirs):
            dir = dirs.pop()
            try:
                self.sftp_client.stat(dir)
            except:
                self.sftp_client.mkdir(dir)
    
    def execute_command(self, command, timeout=600):
        """
        在服务器上执行命令
        
        参数:
            command: 要执行的命令
            timeout: 超时时间（秒）
        
        返回:
            tuple: (stdout, stderr, exit_code)
        """
        try:
            print(f"\n正在执行命令:")
            print(f"  {command}")
            print(f"请稍候，生成图像可能需要较长时间...")
            
            # 使用 bash -l -c 强制加载登录 shell 环境
            # 这样会执行 ~/.bash_profile, ~/.bashrc 等配置文件
            # 就像手动 SSH 登录一样
            
            # 使用单引号包裹命令，避免转义问题
            # 但需要处理命令中的单引号
            safe_command = command.replace("'", "'\"'\"'")  # 替换单引号
            wrapped_command = f"bash -l -c '{safe_command}'"
            
            stdin, stdout, stderr = self.ssh_client.exec_command(
                wrapped_command,
                timeout=timeout,
                get_pty=True  # 同时使用伪终端
            )
            
            # 等待命令执行完成
            exit_code = stdout.channel.recv_exit_status()
            
            # 获取输出
            # 注意: 使用 get_pty=True 时，stderr 会合并到 stdout
            stdout_text = stdout.read().decode('utf-8')
            # 伪终端模式下，错误信息在 stdout 中，stderr 为空
            stderr_text = ""
            
            # 如果 stdout 为空，尝试读取 stderr
            if not stdout_text.strip():
                try:
                    stderr_text = stderr.read().decode('utf-8')
                except:
                    pass
            
            if exit_code == 0:
                print(f"✓ 命令执行成功")
            else:
                print(f"✗ 命令执行失败 (退出码: {exit_code})")
            
            # 打印输出
            # 使用伪终端时，所有输出都在 stdout（包括错误信息）
            if stdout_text:
                # 检查输出中是否有错误关键字
                if exit_code != 0 or any(err in stdout_text.lower() for err in ['error', 'traceback', 'exception']):
                    print("\n执行输出（包含错误）:")
                    print(stdout_text)
                else:
                    print("\n标准输出:")
                    print(stdout_text)
            
            # stderr 一般为空（伪终端模式）
            if stderr_text:
                print("\n错误输出:")
                print(stderr_text)
            
            # 使用伪终端时，如果失败，stderr_text 通常为空，错误在 stdout_text 中
            if exit_code != 0 and not stderr_text and stdout_text:
                stderr_text = stdout_text  # 将 stdout 作为 stderr 返回以保持兼容性
            
            return stdout_text, stderr_text, exit_code
            
        except Exception as e:
            print(f"✗ 执行命令时出错: {e}")
            import traceback
            traceback.print_exc()
            return "", str(e), -1
    
    def download_directory(self, remote_dir, local_dir):
        """
        下载整个目录
        
        参数:
            remote_dir: 服务器目录路径
            local_dir: 本地目录路径
        
        返回:
            list: 下载的文件列表
        """
        try:
            print(f"\n正在下载目录: {remote_dir} -> {local_dir}")
            
            # 创建本地目录
            os.makedirs(local_dir, exist_ok=True)
            
            downloaded_files = []
            
            # 列出远程目录
            try:
                files = self.sftp_client.listdir(remote_dir)
            except FileNotFoundError:
                print(f"✗ 远程目录不存在: {remote_dir}")
                return []
            
            # 下载每个文件
            for filename in files:
                remote_file = os.path.join(remote_dir, filename).replace('\\', '/')
                local_file = os.path.join(local_dir, filename)
                
                try:
                    # 检查是否是文件
                    stat = self.sftp_client.stat(remote_file)
                    if not self._is_directory(stat):
                        print(f"  下载: {filename}")
                        self.sftp_client.get(remote_file, local_file)
                        downloaded_files.append(local_file)
                except Exception as e:
                    print(f"  跳过: {filename} ({e})")
            
            print(f"✓ 下载完成，共 {len(downloaded_files)} 个文件")
            return downloaded_files
            
        except Exception as e:
            print(f"✗ 下载目录失败: {e}")
            return []
    
    def _is_directory(self, stat):
        """判断是否是目录"""
        import stat as stat_module
        return stat_module.S_ISDIR(stat.st_mode)
    
    def find_python_path(self, server_project_dir):
        """
        查找 Python 的完整路径
        
        返回:
            str: Python 的完整路径或命令
        """
        print("\n正在查找 Python 路径...")
        
        # 尝试在项目目录下找到 Python
        find_commands = [
            f"cd {server_project_dir} && which python",
            f"cd {server_project_dir} && which python3",
            "which python",
            "which python3",
        ]
        
        for cmd in find_commands:
            try:
                # 使用 bash -l 加载完整环境
                wrapped_cmd = f"bash -l -c '{cmd}'"
                stdin, stdout, stderr = self.ssh_client.exec_command(wrapped_cmd, timeout=5, get_pty=True)
                exit_code = stdout.channel.recv_exit_status()
                if exit_code == 0:
                    output = stdout.read().decode('utf-8').strip()
                    # 清理输出（移除终端控制字符）
                    output = output.split('\n')[-1].strip()  # 取最后一行
                    if output and output.startswith('/'):
                        print(f"  ✓ 找到 Python: {output}")
                        return output
            except:
                continue
        
        print("  ✗ 未找到 Python 路径")
        return None
    
    def detect_python_command(self, server_project_dir):
        """
        自动检测服务器上的 Python 命令
        
        返回:
            str: 可用的 Python 命令（包含虚拟环境激活）
        """
        print("正在检测 Python 环境...")
        
        # 尝试的命令列表（按优先级排序）
        test_commands = [
            # 优先：在项目目录下直接测试 python（可能有自动激活的虚拟环境）
            f"cd {server_project_dir} && python --version",
            # 尝试显式激活虚拟环境
            f"cd {server_project_dir} && source venv/bin/activate && python --version",
            f"cd {server_project_dir} && source env/bin/activate && python --version",
            f"cd {server_project_dir} && source .venv/bin/activate && python --version",
            # 在项目目录下尝试 python3
            f"cd {server_project_dir} && python3 --version",
            # 尝试 conda 环境
            f"cd {server_project_dir} && conda activate base && python --version",
            # 全局命令
            "python3 --version",
            "python --version",
            "/usr/bin/python3 --version",
            "/usr/local/bin/python3 --version",
        ]
        
        for cmd in test_commands:
            try:
                # 使用 bash -l 加载登录环境
                safe_cmd = cmd.replace("'", "'\"'\"'")
                wrapped_cmd = f"bash -l -c '{safe_cmd}'"
                stdin, stdout, stderr = self.ssh_client.exec_command(
                    wrapped_cmd, 
                    timeout=10,
                    get_pty=True
                )
                exit_code = stdout.channel.recv_exit_status()
                
                if exit_code == 0:
                    output = stdout.read().decode('utf-8').strip()
                    # 清理终端控制字符和多余的换行
                    output = output.replace('\r\n', ' ').replace('\n', ' ').strip()
                    print(f"  ✓ 找到 Python: {output}")
                    
                    # 提取命令前缀（用于后续执行）
                    if cmd.startswith(f"cd {server_project_dir}"):
                        # 命令包含 cd 到项目目录
                        if "source" in cmd and "activate" in cmd:
                            # 虚拟环境
                            venv_part = cmd.split(" && ")[1]  # source venv/bin/activate
                            return f"cd {server_project_dir} && {venv_part} && python"
                        elif "conda activate" in cmd:
                            return f"cd {server_project_dir} && conda activate base && python"
                        elif "python3" in cmd:
                            # cd 到目录后使用 python3
                            return f"cd {server_project_dir} && python3"
                        else:
                            # cd 到目录后直接使用 python（最常见的情况）
                            return f"cd {server_project_dir} && python"
                    elif cmd.startswith("python3"):
                        return "python3"
                    elif cmd.startswith("/usr"):
                        return cmd.split()[0]  # 完整路径
                    else:
                        return "python"
            except:
                continue
        
        # 如果都失败了，默认使用项目目录下的 python
        print("  ⚠️  未能自动检测，使用默认: cd 到项目目录后使用 python")
        return f"cd {server_project_dir} && python"
    
    def generate_image(
        self,
        local_image_path,
        prompt,
        server_project_dir="/root/stablediffusion-main",
        checkpoint_path=None,
        output_dir=None,
        python_command=None,
        steps=20,
        strength=0.75
    ):
        """
        完整的图像生成流程
        
        参数:
            local_image_path: 本地输入图片路径
            prompt: 提示词
            server_project_dir: 服务器上的项目目录
            checkpoint_path: 模型检查点路径（服务器上）
            output_dir: 输出目录（本地）
            python_command: Python 命令（可选，None 则自动检测）
            steps: 生成步数（默认20，越少越快但质量略低）
            strength: 强度（默认0.75）
        
        返回:
            list: 生成的图片路径列表
        """
        try:
            print("=" * 70)
            print("开始远程图像生成流程")
            print("=" * 70)
            
            # 1. 生成时间戳
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            
            # 2. 准备远程路径
            remote_input_dir = f"{server_project_dir}/inputs"
            remote_input_file = f"{remote_input_dir}/input_{timestamp}.jpg"
            
            # 3. 上传输入图片
            print("\n[1/4] 上传输入图片")
            if not self.upload_file(local_image_path, remote_input_file):
                return []
            
            # 4. 检测 Python 命令（如果没有指定）
            if python_command is None:
                # 首先尝试查找 Python 的完整路径
                python_path = self.find_python_path(server_project_dir)
                if python_path:
                    # 找到完整路径，使用它
                    python_command = f"cd {server_project_dir} && {python_path}"
                else:
                    # 使用自动检测
                    python_command = self.detect_python_command(server_project_dir)
            
            # 5. 构建命令
            print("\n[2/4] 准备执行命令")
            
            # 默认检查点路径
            if checkpoint_path is None:
                checkpoint_path = f"{server_project_dir}/ckpt/512-base-ema.ckpt"
            
            # 构建 Stable Diffusion 脚本的命令行参数
            command = f'cd {server_project_dir} && {python_command} scripts/img2img.py'
            command += f' --init-img "{remote_input_file}"'
            command += f' --outdir "{server_project_dir}/outputs/img2img-samples/samples"' # 确保输出目录存在
            command += f' --ckpt "{checkpoint_path}"'
            command += f' --n_samples 1'  # 固定只生成1批
            command += f' --n_iter 1'     # 强制每批只生成1张图
            
            # 添加可选参数
            if steps:
                command += f' --ddim_steps {steps}'  # 添加步数参数以加快速度
            if strength:
                command += f' --strength {strength}'  # 添加强度参数
            
            # 转义提示词中的特殊字符，防止命令行解析错误
            safe_prompt = prompt.replace('"', '\\"').replace('$', '\\$').replace('`', '\\`')
            command += f' --prompt "{safe_prompt}"'
            
            print(f"使用 Python 命令: {python_command}")
            print(f"生成参数: steps={steps}, strength={strength}")
            
            # 6. 执行命令
            print("\n[3/4] 执行生成命令")
            # 优化：降低超时时间（使用更少的步数应该更快）
            stdout, stderr, exit_code = self.execute_command(command, timeout=300)
            
            if exit_code != 0:
                print(f"✗ 生成失败 (退出码: {exit_code})")
                print(f"标准输出: {stdout}")
                print(f"错误输出: {stderr}")
                
                # 尝试检查输出目录是否存在
                print("\n检查输出目录...")
                stdout2, stderr2, exit_code2 = self.execute_command(f'ls -la {server_project_dir}/outputs/', timeout=10)
                print(f"输出目录内容: {stdout2}")
                
                # 尝试检查是否有任何生成的文件
                stdout3, stderr3, exit_code3 = self.execute_command(f'find {server_project_dir}/outputs/ -name "*.png" -o -name "*.jpg" | head -10', timeout=10)
                print(f"找到的图片文件: {stdout3}")
                
                return []
            
            # 6. 下载生成的图片
            print("\n[4/4] 下载生成结果")
            
            # 准备本地输出目录
            if output_dir is None:
                output_dir = f"output_{timestamp}"
            
            os.makedirs(output_dir, exist_ok=True)
            
            # 从服务器下载
            # img2img 的输出路径是 outputs/img2img-samples/samples
            remote_output_dir = f"{server_project_dir}/outputs/img2img-samples/samples"
            downloaded_files = self.download_directory(remote_output_dir, output_dir)
            
            print("\n" + "=" * 70)
            print("流程完成！")
            print("=" * 70)
            print(f"生成的图片保存在: {os.path.abspath(output_dir)}")
            print(f"共 {len(downloaded_files)} 个文件:")
            for file in downloaded_files:
                print(f"  - {file}")
            
            return downloaded_files
            
        except Exception as e:
            print(f"\n✗ 生成流程出错: {e}")
            return []

def main():
    """主函数 - 示例用法"""
    
    # ============ 配置区域 ============
    # 服务器配置
    SERVER_CONFIG = {
        "host": "your-server-host",
        "port": 22,
        "username": "root",
        "password": "YOUR_PASSWORD"  # 请勿提交真实密码，使用环境变量或本地 config
    }
    
    # 项目路径配置
    SERVER_PROJECT_DIR = "/root/stablediffusion-main"  # 服务器上的项目目录
    CHECKPOINT_PATH = f"{SERVER_PROJECT_DIR}/ckpt/512-base-ema.ckpt"  # 模型路径
    
    # ⚠️ 重要：如果自动检测失败，请手动指定 Python 命令
    # 方法1: SSH 登录服务器，运行 'which python' 查看完整路径
    # 方法2: 如果使用虚拟环境，指定激活命令
    # 示例：
    # PYTHON_COMMAND = "/usr/bin/python3"  # 完整路径
    # PYTHON_COMMAND = "source /root/stablediffusion-main/venv/bin/activate && python"  # 虚拟环境
    PYTHON_COMMAND = None  # None = 自动检测
    
    # 本地配置
    LOCAL_INPUT_IMAGE = r"D:/stablediffusion-main/data/data_final/light.jpg"  # 本地输入图片
    LOCAL_OUTPUT_DIR = "generated_images"  # 本地输出目录
    
    # 提示词
    PROMPT = """A detailed anime-style illustration of a unique fantasy object born from the harmonious fusion of two distinct elements.
Preserve the recognizable essence of both components while enhancing their unity through intricate details and balanced visual flow.
Use refined, graceful lines, soft and gentle pastel tones, and radiant glowing accents to evoke a magical, dreamlike atmosphere.
The lighting should feel warm, ethereal, and luminous, with subtle reflections and a sense of otherworldly serenity.
Depict the object isolated on a pure white background, highlighting its delicate craftsmanship and enchanted glow.A new item created by fusing a 【素材1名称】 and a 【素材2名称】 into one coherent design."""
    
    # ============ 执行流程 ============
    
    # 1. 检查本地文件是否存在
    if not os.path.exists(LOCAL_INPUT_IMAGE):
        print(f"✗ 错误: 本地图片不存在: {LOCAL_INPUT_IMAGE}")
        print("请修改 LOCAL_INPUT_IMAGE 为实际的图片路径")
        return
    
    # 2. 创建客户端
    client = SDRemoteClient(
        host=SERVER_CONFIG["host"],
        port=SERVER_CONFIG["port"],
        username=SERVER_CONFIG["username"],
        password=SERVER_CONFIG["password"]
    )
    
    # 3. 连接服务器
    if not client.connect():
        return
    
    try:
        # 4. 如果自动检测失败，提供帮助信息
        if PYTHON_COMMAND is None:
            print("\n💡 提示：如果遇到 'python: command not found' 错误")
            print("   请按 Ctrl+C 中断，然后:")
            print("   1. SSH 登录服务器")
            print(f"   2. 运行: cd {SERVER_PROJECT_DIR} && which python")
            print("   3. 将输出的完整路径填入脚本的 PYTHON_COMMAND 变量\n")
        
        # 5. 执行生成
        generated_files = client.generate_image(
            local_image_path=LOCAL_INPUT_IMAGE,
            prompt=PROMPT,
            server_project_dir=SERVER_PROJECT_DIR,
            checkpoint_path=CHECKPOINT_PATH,
            output_dir=LOCAL_OUTPUT_DIR,
            python_command=PYTHON_COMMAND
        )
        
        if generated_files:
            print(f"\n✓ 成功生成 {len(generated_files)} 张图片！")
        else:
            print(f"\n✗ 没有生成图片")
    
    finally:
        # 5. 断开连接
        client.disconnect()


if __name__ == "__main__":
    main()


