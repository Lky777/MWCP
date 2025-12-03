#!/usr/bin/env python3

import os
import requests

def fetch_top_domains():
    api_token = os.environ['CLOUDFLARE_API_TOKEN']
    
    url = "https://api.cloudflare.com/client/v4/radar/datasets/ranking_top_100000"
    headers = {"Authorization": f"Bearer {api_token}"}
    
    response = requests.get(url, headers=headers)
    
    if response.status_code == 200:
        os.makedirs('source', exist_ok=True)

        csv_file = 'source/top100k.csv'
        txt_file = 'source/top100k.txt'
        
        with open(csv_file, 'w', encoding='utf-8') as f:
            f.write(response.text)

        os.rename(csv_file, txt_file)
        print(f"已生成 {txt_file}")
    else:
        print(f"错误: {response.status_code}")

if __name__ == "__main__":
    fetch_top_domains()

