<!--
Copyright (c) 2026 mingju.xu (xumj1125@live.com). All rights reserved.
Licensed under the GNU General Public License v3.0.
-->

# DevOps Platform Demo

This repository contains a DevOps platform demonstration project featuring a multi-tier containerized application, multi-environment Kubernetes manifests managed by Kustomize, infrastructure automation configured via Terraform, and GitHub Actions CI/CD workflows.

Designed and implemented for the DevOps Engineer Assessment.

---

## Key Features

- **Multi-Tier Application**: Simple Flask web service communicating with a Redis database.
- **Hybrid Infrastructure**: Terraform manifests managing VPC (public, private, and database subnets), S3 buckets, and RDS PostgreSQL, with a reference EKS module configuration. Local development uses a Kind cluster to save AWS EKS control plane costs.
- **Multi-Environment Support**: Manifest overlays for `dev`, `test`, `perf`, `staging`, and `production` environments using Kustomize.
- **GitOps Pipelines**:
  - **Application CI/CD**: Automatic Docker image builds and pushes to GitHub Container Registry (GHCR) using Docker Buildx and caching.
  - **Infrastructure Pipeline**: Continuous integration (format check, validation, and dry-run plans) and deployment. Auto-deploys to the Dev environment on merges to main, while the Production environment requires manual review and approval.
- **Secrets Management**: Sensitive parameters (e.g. database credentials) are excluded from code and tfvars, managed using GitHub Secrets and injected via `TF_VAR_` environment variables at runtime.

---

## Repository Structure

```text
devops-platform-demo/
├── .github/
│   └── workflows/
│       ├── infra.yml            # Terraform lint, plan, and apply pipeline
│       └── service.yml          # Application build and push to GHCR pipeline
├── app/                          # Flask application source
│   ├── app.py                    # Main Flask application
│   ├── requirements.txt          # Python dependencies
│   └── Dockerfile                # Multi-stage Python runner container
├── terraform/                    # Infrastructure configurations (Terraform)
│   ├── main.tf                   # VPC, RDS (PostgreSQL 16.3), and S3 resources
│   ├── variables.tf              # Terraform variables definitions
│   ├── outputs.tf                # VPC, RDS, and S3 outputs
│   ├── dev.tfvars                # Dev environment parameter values
│   └── prod.tfvars               # Prod environment parameter values
├── k8s/                          # Kubernetes Manifests
│   ├── base/                     # Deployment, service, and ingress bases
│   └── overlays/                 # Environment-specific overlays
├── docs/                         # Architecture documentation
│   ├── app-design.md             # Application data flow and layout
│   ├── infra-design.md           # Infrastructure topology
│   └── pipeline-design.md        # CI/CD pipeline logic and stages
├── scripts/                      # Local environment helper scripts
│   └── setup-kind.sh             # Kind cluster bootstrap script
└── README.md                     # This documentation
```

---

## Prerequisites

Verify the following tools are installed locally:
- Docker Engine
- Kind (Kubernetes in Docker)
- kubectl CLI
- Kustomize CLI (or use `kubectl kustomize` utility)
- Terraform CLI (v1.5.0+)
- AWS CLI (pre-configured with credentials for AWS cloud resources)

---

## Quick Start

### 1. Bootstrap the Local Cluster
Execute the helper script to verify dependencies, create the Kind cluster with mapped ingress ports, and deploy the Nginx Ingress Controller:
```bash
chmod +x scripts/setup-kind.sh
./scripts/setup-kind.sh
```

### 2. Deploy the Dev Environment
Apply the Dev overlay using Kustomize:
```bash
kubectl apply -k k8s/overlays/dev
```

Verify that the application pods are running successfully:
```bash
kubectl get pods -n dev
```

### 3. Access the Application
The Ingress is configured to route traffic for `demo.local`. Map this host to localhost in your hosts file (`/etc/hosts` on Unix/macOS or `C:\Windows\System32\drivers\etc\hosts` on Windows):
```text
127.0.0.1 demo.local
```

Access the service endpoint:
```bash
curl http://demo.local/
```
*(Alternatively, expose the port locally without hosts mapping: `kubectl port-forward svc/flask-app 5000:5000 -n dev` and open `http://localhost:5000`)*.

---

## Terraform Management

Run commands inside the `terraform` directory. Inject the sensitive database password parameter via the `TF_VAR_` environment variable prefix:

```bash
cd terraform
terraform init
export TF_VAR_db_password="YourSecurePasswordHere"
terraform plan -var-file=dev.tfvars
```

### Environment Isolation
Variables specific to each environment (such as resource sizing, tags, etc.) are managed in `dev.tfvars` and `prod.tfvars`. The sensitive password variable `db_password` is flagged as `sensitive` in `variables.tf` to prevent leaks in standard logs and output displays.

---

## CI/CD Workflows

### Application Image Pipeline (`service.yml`)
- Triggered on modifications to the `app/` directory or manual workflow dispatch.
- Performs multi-stage Docker builds and pushes images to GHCR.
- Uses GitHub Actions runner cache to speed up image rebuilds.

### Infrastructure Pipeline (`infra.yml`)
- Triggered on modifications to the `terraform/` directory or manual workflow dispatch.
- Runs static formatting checks (`terraform fmt -check`) and validation (`terraform validate`).
- Generates execution plans for both development and production environments.
- **CD Strategy**: Auto-applies changes to the Dev environment on push, and targets the Prod environment through a manual approval workflow gate.

---

## Architectural Layouts

For details on the architecture, refer to:
- [Application Data Flow](docs/app-design.md)
- [Infrastructure Topology](docs/infra-design.md)
- [Pipeline Flowchart](docs/pipeline-design.md)

---

## Known Limitations and Enhancements

1. **Local Kubernetes Deployment**: For cost-efficiency, the AWS EKS module in `main.tf` is commented out. In production environments, this can be uncommented and managed via EKS provider configurations in the pipeline.
2. **State Storage and Locking**: The Terraform configuration uses a local state file for demonstration. For team collaboration, configure an S3 remote backend with DynamoDB locking.

---

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
