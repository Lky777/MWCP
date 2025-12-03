#!/usr/bin/env python3

import os
import sys
import requests
import json
from datetime import datetime

def fetch_top_domains():
    """
    获取 Top 100K 热门域名数据
    保存到 source/top100k.json
    """
    
    # 从 GitHub Secrets 获取 API Token
    api_token = os.getenv("CLOUDFLARE_API_TOKEN")
    if not api_token:
        print("::error::请设置 CLOUDFLARE_API_TOKEN secrets")
        sys.exit(1)
    
    # API 配置
    url = "https://api.cloudflare.com/client/v4/radar/ranking/top"
    headers = {
        "Authorization": f"Bearer {api_token}",
        "Content-Type": "application/json"
    }
    
    # 分页获取数据
    domains = []
    offset = 0
    batch_size = 100
    limit = 100000
    
    print(f"开始获取 Cloudflare Radar 热门域名数据")
    print(f"目标数量: {limit} 个域名")
    print(f"输出目录: source/")
    
    while len(domains) < limit:
        try:
            params = {
                "limit": batch_size,
                "offset": offset,
                "rankingType": "POPULAR",
                "format": "json"
            }
            
            print(f"请求参数: {params}")
            
            response = requests.get(url, headers=headers, params=params, timeout=60)
            
            # 输出详细的错误信息
            if response.status_code != 200:
                print(f"HTTP 状态码: {response.status_code}")
                print(f"响应内容: {response.text}")
                response.raise_for_status()
                
            data = response.json()
            
            if not data.get("success"):
                print(f"::error::API 错误: {data.get('errors', ['未知错误'])}")
                sys.exit(1)
            
            # 检查响应结构
            print(f"响应数据结构: {list(data.keys())}")
            if "result" in data and "top_0" in data["result"]:
                batch = data["result"]["top_0"]
            else:
                print(f"::warning::未找到预期的数据结构")
                print(f"完整响应: {json.dumps(data, indent=2)}")
                # 尝试其他可能的键
                if "result" in data:
                    batch = data["result"]
                else:
                    batch = []
            
            if not batch:
                print("没有更多数据")
                break
            
            print(f"获取到 {len(batch)} 个域名")
            domains.extend(batch)
            offset += batch_size
            
            # 显示进度
            if len(domains) % 1000 == 0:
                print(f"进度: {len(domains)}/100000")
            
            # 数据不足时退出
            if len(batch) < batch_size:
                print(f"批次数据不足 {batch_size}，可能已到末尾")
                break
            
        except requests.exceptions.RequestException as e:
            print(f"::error::网络请求失败: {e}")
            sys.exit(1)
        except Exception as e:
            print(f"::error::处理数据失败: {e}")
            import traceback
            traceback.print_exc()
            sys.exit(1)
    
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
            "source": "Cloudflare Radar Latest"
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
        
        # GitHub Actions 输出统计信息
        print(f"::set-output name=total_domains::{len(domains)}")
        print(f"::set-output name=fetch_date::{datetime.now().isoformat()}")
        print(f"::set-output name=output_path::{output_path}")
        print(f"::set-output name=file_size::{file_size}")
        
    except Exception as e:
        print(f"::error::保存文件失败: {e}")
        sys.exit(1)

if __name__ == "__main__":
    fetch_top_domains()