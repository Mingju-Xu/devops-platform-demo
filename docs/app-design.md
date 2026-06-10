<!--
Copyright (c) 2026 mingju.xu (xumj1125@live.com). All rights reserved.
Licensed under the GNU General Public License v3.0.
-->

# Application Design

This document details the multi-tier application architecture and traffic routing structure.

```mermaid
graph TD
  User("User / Client") -->|HTTP Request| Ingress["Ingress: demo.local"]
  Ingress -->|Forward Port 5000| FlaskSvc["Flask Service (flask-app)"]
  FlaskSvc -->|Load Balance| FlaskPod["Flask App Pods (app)"]
  FlaskPod -->|Read/Write Visits| RedisSvc["Redis Service (redis-service)"]
  RedisSvc -->|Internal Port 6379| RedisPod["Redis Database Pod (redis)"]
  
  style Ingress fill:#f9f,stroke:#333,stroke-width:2px
  style FlaskSvc fill:#bbf,stroke:#333,stroke-width:2px
  style RedisSvc fill:#dfd,stroke:#333,stroke-width:2px
```
