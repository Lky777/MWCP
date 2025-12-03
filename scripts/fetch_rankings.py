#!/usr/bin/env python3

import os
import sys
import requests
import json
import time
from datetime import datetime

def fetch_top_domains():

    api_token = os.getenv("CLOUDFLARE_API_TOKEN")
    
    # API 配置
    url = "https://api.cloudflare.com/client/v4/radar/ranking/top"
    headers = {
        "Authorization": f"Bearer {api_token}",
        "Content-Type": "application/json"
    }
    
    # 分页获取数据
    domains = []
    offset = 0
    batch_size = 100000  # 较小的批量大小
    limit = 100000
    max_retries = 3
    
    print(f"开始获取 Cloudflare Radar 热门域名数据")
    print(f"目标数量: {limit} 个域名")
    print(f"输出目录: source/")
    
    while len(domains) < limit:
        retry_count = 0
        success = False
        
        while not success and retry_count < max_retries:
            try:
                params = {
                    "limit": batch_size,
                    "offset": offset,
                    "rankingType": "POPULAR",
                    "format": "json"
                }
                
                print(f"请求参数: 偏移量={offset}, 批量大小={batch_size}")
                
                response = requests.get(url, headers=headers, params=params, timeout=60)
                
                if response.status_code == 429:
                    # 速率限制，等待更长时间
                    wait_time = 30 * (retry_count + 1)
                    print(f"遇到速率限制，等待 {wait_time} 秒后重试...")
                    time.sleep(wait_time)
                    retry_count += 1
                    continue
                
                if response.status_code != 200:
                    print(f"HTTP 状态码: {response.status_code}")
                    print(f"响应内容: {response.text[:500]}")
                    response.raise_for_status()
                    
                data = response.json()
                
                if not data.get("success"):
                    print(f"API 错误: {data.get('errors', ['未知错误'])}")
                    # 如果是速率限制错误，等待后重试
                    if any("rate limit" in str(err).lower() for err in data.get("errors", [])):
                        wait_time = 30 * (retry_count + 1)
                        print(f"API 速率限制，等待 {wait_time} 秒后重试...")
                        time.sleep(wait_time)
                        retry_count += 1
                        continue
                    else:
                        sys.exit(1)
                
                # 检查响应结构
                if "result" in data and "top_0" in data["result"]:
                    batch = data["result"]["top_0"]
                elif "result" in data and isinstance(data["result"], list):
                    batch = data["result"]
                else:
                    print(f"警告: 未找到预期的数据结构")
                    print(f"响应键: {list(data.keys())}")
                    batch = []
                
                if not batch:
                    print("没有更多数据")
                    success = True
                    break
                
                print(f"获取到 {len(batch)} 个域名")
                domains.extend(batch)
                offset += batch_size
                
                # 显示进度
                if len(domains) % 1000 == 0:
                    print(f"进度: {len(domains)}/100000")
                    print(f"已处理批次: {offset // batch_size}")
                
                # 数据不足时退出
                if len(batch) < batch_size:
                    print(f"批次数据不足 {batch_size}，可能已到末尾")
                    success = True
                    break
                
                success = True
                
                # 请求成功后添加延迟以避免速率限制
                if success:
                    time.sleep(1)  # 每次请求后等待1秒
                
            except requests.exceptions.RequestException as e:
                print(f"网络请求失败: {e}")
                if retry_count < max_retries - 1:
                    wait_time = 10 * (retry_count + 1)
                    print(f"等待 {wait_time} 秒后重试...")
                    time.sleep(wait_time)
                    retry_count += 1
                else:
                    sys.exit(1)
            except Exception as e:
                print(f"处理数据失败: {e}")
                import traceback
                traceback.print_exc()
                if retry_count < max_retries - 1:
                    wait_time = 10 * (retry_count + 1)
                    print(f"等待 {wait_time} 秒后重试...")
                    time.sleep(wait_time)
                    retry_count += 1
                else:
                    sys.exit(1)
        
        if not success:
            print(f"::error::在 {max_retries} 次重试后仍然失败")
            sys.exit(1)
        
        # 如果批次数据不足，说明已获取所有数据
        if len(batch) < batch_size:
            break
    
    if not domains:
        print("::error::未获取到任何数据")
        sys.exit(1)
    
    print(f"✓ 成功获取 {len(domains)} 个热门域名")
    
    # 准备输出数据
    result = {
        "metadata": {
            "fetch_date": datetime.now().isoformat(),
            "total_domains": len(domains),
            "ranking_type": "POPULAR",
            "source": "Cloudflare Radar Latest",
            "batch_size": batch_size,
            "final_offset": offset
        },
        "domains": domains
    }
    
    # 创建 source 目录并保存数据
    try:
        os.makedirs("source", exist_ok=True)
        output_path = "source/top100k.json"
        
        with open(output_path, "w", encoding="utf-8") as f:
            json.dump(result, f, indent=2, ensure_ascii=False)
        
        print(f"✓ 数据已保存到 {output_path}")
        
        # 输出文件信息
        file_size = os.path.getsize(output_path)
        print(f"✓ 文件大小: {file_size / 1024 / 1024:.2f} MB")
        
        # 显示前几个域名作为示例
        print(f"✓ 示例域名 (前5个):")
        for i, domain in enumerate(domains[:5]):
            if isinstance(domain, dict):
                print(f"  {i+1}. {domain.get('domain', 'N/A')}")
            else:
                print(f"  {i+1}. {domain}")
        
    except Exception as e:
        print(f"::error::保存文件失败: {e}")
        sys.exit(1)

if __name__ == "__main__":
    fetch_top_domains()