#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
快速测试服务器连接
在运行完整脚本前，先用这个脚本测试连接是否正常
"""

import paramiko
import sys


def test_ssh_connection():
    """测试 SSH 连接"""
    print("=" * 60)
    print("测试 SSH 连接")
    print("=" * 60)
    
    # 服务器配置
    host = "your-server-host"
    port = 22
    username = "root"
    password = "YOUR_PASSWORD"
    
    print(f"\n服务器地址: {host}")
    print(f"端口: {port}")
    print(f"用户名: {username}")
    print(f"密码: {'*' * len(password)}")
    
    try:
        print("\n正在连接...")
        
        # 创建 SSH 客户端
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        
        # 连接
        client.connect(
            hostname=host,
            port=port,
            username=username,
            password=password,
            timeout=30
        )
        
        print("✓ SSH 连接成功！")
        
        # 测试执行命令
        print("\n测试执行命令...")
        stdin, stdout, stderr = client.exec_command("pwd", timeout=10)
        current_dir = stdout.read().decode('utf-8').strip()
        print(f"✓ 当前目录: {current_dir}")
        
        # 测试 SFTP
        print("\n测试 SFTP...")
        sftp = client.open_sftp()
        print("✓ SFTP 连接成功！")
        
        # 列出当前目录
        print("\n当前目录文件:")
        files = sftp.listdir('.')
        for f in files[:10]:  # 只显示前10个
            print(f"  - {f}")
        if len(files) > 10:
            print(f"  ... 还有 {len(files) - 10} 个文件")
        
        # 检查 Stable Diffusion 项目目录
        print("\n检查 Stable Diffusion 项目目录...")
        
        project_dirs = [
            "/root/stablediffusion-main",
            "/root/stable-diffusion",
            "/root/sd",
            "~/stablediffusion",
            "~/stable-diffusion"
        ]
        
        found_dir = None
        for project_dir in project_dirs:
            try:
                sftp.stat(project_dir)
                print(f"✓ 找到项目目录: {project_dir}")
                found_dir = project_dir
                
                # 检查子目录
                try:
                    sftp.stat(f"{project_dir}/scripts")
                    print(f"  ✓ scripts/ 目录存在")
                except:
                    print(f"  ✗ scripts/ 目录不存在")
                
                try:
                    sftp.stat(f"{project_dir}/ckpt")
                    print(f"  ✓ ckpt/ 目录存在")
                    
                    # 列出模型文件
                    ckpt_files = sftp.listdir(f"{project_dir}/ckpt")
                    if ckpt_files:
                        print(f"  ✓ 找到 {len(ckpt_files)} 个模型文件:")
                        for ckpt in ckpt_files[:3]:
                            print(f"    - {ckpt}")
                except:
                    print(f"  ✗ ckpt/ 目录不存在")
                
                break
                
            except FileNotFoundError:
                print(f"✗ 未找到: {project_dir}")
        
        if not found_dir:
            print("\n⚠️  警告: 未找到 Stable Diffusion 项目目录")
            print("请手动检查项目路径，然后修改脚本中的 SERVER_PROJECT_DIR")
        else:
            print(f"\n✓ 建议使用目录: {found_dir}")
        
        # 关闭连接
        sftp.close()
        client.close()
        
        print("\n" + "=" * 60)
        print("✓ 所有测试通过！")
        print("=" * 60)
        print("\n下一步:")
        if found_dir:
            print(f"1. 在 client_sd_remote.py 中设置:")
            print(f"   SERVER_PROJECT_DIR = \"{found_dir}\"")
        print("2. 设置本地输入图片路径")
        print("3. 运行 python client_sd_remote.py")
        
        return True
        
    except paramiko.AuthenticationException:
        print("✗ 认证失败！请检查用户名和密码")
        return False
        
    except paramiko.SSHException as e:
        print(f"✗ SSH 错误: {e}")
        return False
        
    except TimeoutError:
        print("✗ 连接超时！请检查网络和服务器地址")
        return False
        
    except Exception as e:
        print(f"✗ 错误: {type(e).__name__}: {e}")
        return False


def main():
    """主函数"""
    print("\nStable Diffusion 远程连接测试工具")
    print("此脚本会测试:")
    print("  1. SSH 连接")
    print("  2. SFTP 文件传输")
    print("  3. 项目目录结构")
    print()
    
    try:
        success = test_ssh_connection()
        
        if success:
            sys.exit(0)
        else:
            sys.exit(1)
            
    except KeyboardInterrupt:
        print("\n\n用户中断")
        sys.exit(130)


if __name__ == "__main__":
    main()


