# Copyright (c) 2026 mingju.xu (xumj1125@live.com). All rights reserved.
# Licensed under the GNU General Public License v3.0.

import os
import redis
from flask import Flask

app = Flask(__name__)
redis_host = os.getenv('REDIS_HOST', 'redis-service')
r = redis.Redis(host=redis_host, port=6379, decode_responses=True)

@app.route('/')
def hello():
    count = r.incr('visits')
    return f"Hello from Flask! Visited {count} times.\n"

@app.route('/health')
def health():
    try:
        r.ping()
        return {"status": "healthy", "redis": "up"}, 200
    except Exception as e:
        return {"status": "unhealthy", "redis": str(e)}, 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
