#!/usr/bin/env python3

import os
import sys
import time
import json
import requests

def fetch_domains():
    API_TOKEN = os.getenv("CLOUDFLARE_API_TOKEN")
    OUTPUT_FILE = "source/top100k.txt"
    MAX_DOMAINS = 100000
    BATCH_SIZE = 100

    os.makedirs("source", exist_ok=True)
    domains = []
    offset = 0
    session = requests.Session()
    session.headers.update({
        "Authorization": f"Bearer {API_TOKEN}",
        "Content-Type": "application/json"
    })
    
    print(f"🚀 开始获取域名 (目标: {MAX_DOMAINS}个)")
    print(f"📁 输出文件: {OUTPUT_FILE}")
    start_time = time.time()
    
    try:
        while len(domains) < MAX_DOMAINS:
            # API请求
            try:
                print(f"📡 请求第 {offset+1}-{offset+BATCH_SIZE} 个域名...")
                
                resp = session.get(
                    "https://api.cloudflare.com/client/v4/radar/ranking/top",
                    params={
                        "limit": BATCH_SIZE,
                        "offset": offset,
                        "rankingType": "POPULAR"
                    },
                    timeout=15
                )
                
                # 检查响应状态
                if resp.status_code == 429:
                    print("⏳ 速率限制，等待30秒...")
                    time.sleep(30)
                    continue
                
                if resp.status_code != 200:
                    print(f"❌ API返回错误状态码: {resp.status_code}")
                    print(f"响应内容: {resp.text[:200]}")
                    time.sleep(5)
                    continue
                
                data = resp.json()
                
                # 检查API响应是否成功
                if not data.get("success", False):
                    print(f"❌ API返回失败: {data.get('errors', '未知错误')}")
                    break
                
                # 动态获取数据键名（因为可能是top_0, top_1等）
                result_data = data.get("result", {})
                
                # 查找包含数据的键
                top_key = None
                for key in result_data.keys():
                    if key.startswith("top_"):
                        top_key = key
                        break
                
                if not top_key:
                    print("⚠️ 未找到数据键，停止获取")
                    break
                
                # 提取域名
                batch = [
                    item["domain"] for item in result_data.get(top_key, [])
                    if item.get("domain")
                ]
                
                if not batch:
                    print("⚠️ 没有更多数据，停止获取")
                    break
                
                domains.extend(batch)
                offset += len(batch)  # 根据实际获取数量增加偏移量
                
                print(f"✅ 获取到 {len(batch)} 个域名，累计 {len(domains)} 个")
                
                # 进度显示
                if len(domains) % 5000 == 0 or len(domains) >= MAX_DOMAINS:
                    progress = min(len(domains) / MAX_DOMAINS * 100, 100)
                    elapsed = time.time() - start_time
                    speed = len(domains) / elapsed if elapsed > 0 else 0
                    print(f"📊 进度: {len(domains)}/{MAX_DOMAINS} ({progress:.1f}%) | "
                          f"速度: {speed:.1f} 域名/秒 | 耗时: {elapsed:.0f}秒")
                
                # 请求间隔
                time.sleep(1)  # 适当增加间隔避免速率限制
                
            except requests.exceptions.RequestException as e:
                print(f"❌ 网络请求失败: {e}，5秒后重试...")
                time.sleep(5)
                continue
            except Exception as e:
                print(f"❌ 处理失败: {e}，5秒后重试...")
                time.sleep(5)
                continue
                
    except KeyboardInterrupt:
        print(f"\n⏹️ 用户中断，已获取 {len(domains)} 个域名")
    
    # 保存结果
    if domains:
        # 修复：先计算要保存的域名列表
        domains_to_save = domains[:MAX_DOMAINS]
        
        with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
            f.write("\n".join(domains_to_save))
        
        elapsed = time.time() - start_time
        print(f"\n🎉 完成！")
        print(f"📊 统计:")
        print(f"  获取总数: {len(domains)}")
        print(f"  保存数量: {len(domains_to_save)}")
        print(f"  保存到: {OUTPUT_FILE}")
        print(f"  总耗时: {elapsed:.0f}秒 ({len(domains)/elapsed:.1f} 域名/秒)")
        
        if os.getenv('GITHUB_ACTIONS'):
            print(f"count={len(domains_to_save)}")
            print(f"file={OUTPUT_FILE}")

            with open(os.getenv('GITHUB_OUTPUT'), 'a') as f:
                f.write(f"count={len(domains_to_save)}\n")
                f.write(f"file={OUTPUT_FILE}\n")
    else:
        print("\n❌ 未获取到任何域名")
        sys.exit(1)

if __name__ == "__main__":
    fetch_domains()
