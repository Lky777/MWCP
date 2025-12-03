#!/usr/bin/env python3
import os
import json
import requests
from datetime import datetime

def fetch_top_domains():
    api_token = os.environ.get('CLOUDFLARE_API_TOKEN')
    if not api_token:
        raise ValueError("CLOUDFLARE_API_TOKEN environment variable not set")
    
    url = "https://api.cloudflare.com/client/v4/radar/datasets/ranking_top_100000"
    headers = {
        "Authorization": f"Bearer {api_token}",
        "Content-Type": "application/json",
    }
    
    print("Fetching top 100k domains...")
    response = requests.get(url, headers=headers)
    
    # 添加调试信息
    print(f"状态码: {response.status_code}")
    print(f"响应头: {dict(response.headers)}")
    print(f"内容类型: {response.headers.get('Content-Type')}")
    print(f"响应大小: {len(response.text)} 字符")
    
    # 查看前500个字符
    print(f"响应前500字符: {response.text[:500]}")
    
    if response.status_code == 200:
        try:
            data = response.json()
            print("JSON解析成功！")
            print(f"数据结构: {type(data)}")
            
            if data.get('success'):
                print("API调用成功")
                # 创建数据目录
                os.makedirs('source', exist_ok=True)
                
                # 保存原始 JSON
                with open('source/top100k.json', 'w') as f:
                    json.dump(data, f, indent=2)
                print("数据已保存到 source/top100k.json")
                
                # 查看数据结构
                if 'result' in data:
                    print(f"结果类型: {type(data['result'])}")
                    if isinstance(data['result'], list):
                        print(f"列表长度: {len(data['result'])}")
                        if data['result']:
                            print(f"第一条数据: {data['result'][0]}")
            else:
                print(f"API返回失败: {data.get('errors', '未知错误')}")
                
        except json.JSONDecodeError as e:
            print(f"JSON解析错误: {e}")
            print("尝试保存原始响应...")
            os.makedirs('source', exist_ok=True)
            with open('source/raw_response.txt', 'w') as f:
                f.write(response.text)
            print("原始响应已保存到 source/raw_response.txt")
    
    else:
        print(f"请求失败，状态码: {response.status_code}")
        print(f"错误信息: {response.text}")

if __name__ == "__main__":
    fetch_top_domains()