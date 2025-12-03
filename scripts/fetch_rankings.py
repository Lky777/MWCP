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
    }
    
    print("Fetching top 100k domains...")
    response = requests.get(url, headers=headers)
    
    if response.status_code == 200:
        data = response.json()
        
        if data.get('success'):
            # 创建数据目录
            os.makedirs('source', exist_ok=True)
            
            # 保存原始 JSON
            with open('source/top100k.json', 'w') as f:
                json.dump(data, f, indent=2)

if __name__ == "__main__":
    fetch_top_domains()