#!/usr/bin/env python3
"""
GitHub Action专用版 - 获取Cloudflare Top域名
简洁优化版
"""

import os
import sys
import time
import requests

def fetch_domains():
    """主获取函数"""
    # 配置
    API_TOKEN = os.getenv("CLOUDFLARE_API_TOKEN")
    OUTPUT_FILE = "source/top100k.txt"
    MAX_DOMAINS = 100000
    BATCH_SIZE = 100
    
    # 准备
    os.makedirs("source", exist_ok=True)
    domains = []
    offset = 0
    session = requests.Session()
    session.headers.update({"Authorization": f"Bearer {API_TOKEN}"})
    
    print(f"🚀 开始获取域名 (目标: {MAX_DOMAINS}个)")
    print(f"📁 输出文件: {OUTPUT_FILE}")
    start_time = time.time()
    
    try:
        while len(domains) < MAX_DOMAINS:
            # API请求
            try:
                resp = session.get(
                    "https://api.cloudflare.com/client/v4/radar/ranking/top",
                    params={"limit": BATCH_SIZE, "offset": offset, "rankingType": "POPULAR"},
                    timeout=10
                )
                
                # 速率限制
                if resp.status_code == 429:
                    print("⏳ 速率限制，等待30秒...")
                    time.sleep(30)
                    continue
                    
                data = resp.json()
                
                # 提取域名
                batch = [
                    item["domain"] for item in 
                    data.get("result", {}).get("top_0", []) 
                    if item.get("domain")
                ]
                
                if not batch:
                    print("⚠️ 没有更多数据，停止获取")
                    break
                    
                domains.extend(batch)
                offset += BATCH_SIZE
                
                # 进度显示
                if len(domains) % 5000 == 0 or len(domains) >= MAX_DOMAINS:
                    progress = min(len(domains) / MAX_DOMAINS * 100, 100)
                    elapsed = time.time() - start_time
                    print(f"📊 进度: {len(domains)}/{MAX_DOMAINS} ({progress:.1f}%) | 耗时: {elapsed:.0f}秒")
                
                # 请求间隔
                time.sleep(0.5)
                
            except Exception as e:
                print(f"❌ 请求失败: {e}，5秒后重试...")
                time.sleep(5)
                continue
                
    except KeyboardInterrupt:
        print(f"\n⏹️ 用户中断，已获取 {len(domains)} 个域名")
    
    # 保存结果
    if domains:
        with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
            f.write("\n".join(domains[:MAX_DOMAINS]))
        
        elapsed = time.time() - start_time
        print(f"\n✅ 完成！保存 {len(domains)} 个域名")
        print(f"⏱️  耗时: {elapsed:.0f}秒 ({len(domains)/elapsed:.1f} 域名/秒)")
        
        # GitHub Action输出
        if os.getenv('GITHUB_ACTIONS'):
            print(f"::set-output name=count::{len(domains)}")
            print(f"::set-output name=file::{OUTPUT_FILE}")
    else:
        print("\n❌ 未获取到域名")
        sys.exit(1)

if __name__ == "__main__":
    fetch_domains()