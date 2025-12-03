#!/usr/bin/env python3

import os
import sys
import requests
import json
from datetime import datetime, timedelta

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
    headers = {"Authorization": f"Bearer {api_token}"}
    
    # 使用最近7天的数据
    end_date = datetime.now().strftime("%Y-%m-%d")
    start_date = (datetime.now() - timedelta(days=7)).strftime("%Y-%m-%d")
    date_range = [start_date, end_date]
    
    # 分页获取数据
    domains = []
    offset = 0
    batch_size = 1000
    limit = 100000
    
    print(f"开始获取 Cloudflare Radar 热门域名数据")
    print(f"日期范围: {start_date} 至 {end_date}")
    print(f"目标数量: {limit} 个域名")
    print(f"输出目录: source/")
    
    while len(domains) < limit:
        try:
            params = {
                "limit": batch_size,
                "offset": offset,
                "rankingType": "POPULAR",
                "format": "JSON",
                "date": date_range
            }
            
            response = requests.get(url, headers=headers, params=params, timeout=60)
            response.raise_for_status()
            data = response.json()
            
            if not data.get("success"):
                print(f"::error::API 错误: {data.get('errors', ['未知错误'])}")
                sys.exit(1)
            
            batch = data["result"]["top_0"]
            if not batch:
                break
            
            domains.extend(batch)
            offset += batch_size
            
            # 显示进度
            if len(domains) % 10000 == 0:
                print(f"进度: {len(domains)}/100000")
            
            # 数据不足时退出
            if len(batch) < batch_size:
                break
            
        except requests.exceptions.RequestException as e:
            print(f"::error::网络请求失败: {e}")
            sys.exit(1)
        except Exception as e:
            print(f"::error::处理数据失败: {e}")
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
            "date_range": date_range
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