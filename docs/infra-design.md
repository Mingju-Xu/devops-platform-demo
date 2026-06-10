<!--
Copyright (c) 2026 mingju.xu (xumj1125@live.com). All rights reserved.
Licensed under the GNU General Public License v3.0.
-->

# Infrastructure Design

This document describes the cloud (AWS) infrastructure defined by Terraform and the local simulated developer environment (Kind).

```mermaid
graph TB
  subgraph AWS["AWS Cloud (Production Infrastructure)"]
    subgraph VPC["VPC: 10.0.0.0/16"]
      direction TB
      subgraph PublicSubnets["Public Subnets (us-east-1a / us-east-1b)"]
        NAT["NAT Gateway"]
      end
      
      subgraph PrivateSubnets["Private Subnets"]
        AppPlaceholder["(EKS App Nodes Placement Area)"]
      end
      
      subgraph DBSubnets["Isolated Database Subnets"]
        RDS["RDS PostgreSQL Instance (db.t3.micro/small)"]
      end
    end
    
    S3["S3 Bucket (Artifacts Storage)"]
  end
  
  subgraph LocalDev["Local Developer Machine"]
    direction TB
    Kind["Kind Kubernetes Cluster"]
    docker["Docker Engine daemon"]
    Kind -->|Runs inside| docker
  end

  NAT -->|Route Private Outbound| RDS
  AppPlaceholder -->|5432 / Private Connection| RDS
  
  style AWS fill:#f5f5f5,stroke:#ff9900,stroke-width:2px
  style LocalDev fill:#f5f5f5,stroke:#00bfff,stroke-width:2px
  style RDS fill:#ff9900,stroke:#333,stroke-width:2px
  style S3 fill:#ff9900,stroke:#333,stroke-width:2px
```
