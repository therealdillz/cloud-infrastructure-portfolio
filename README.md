# cloud-infrastructure-portfolio
Production-grade cloud infrastructure projects demonstrating Terraform, AWS, containerisation, and observability. Built to deepen hands-on engineering skills alongside 3+ years of cloud operations experience.

# Cloud Infrastructure Portfolio
## Projects
- # AWS Multi-Environment Infrastructure

A production-style AWS networking infrastructure built with Terraform,
demonstrating reusable module design and environment separation.
Built as part of my cloud infrastructure portfolio to deepen hands-on
AWS and Terraform experience alongside 3+ years of GCP cloud operations.

## What This Builds

This project provisions a complete, highly available AWS networking
foundation across two availability zones in eu-west-2 (London):

- VPC with a defined CIDR range
- Public subnets (one per availability zone) with internet access
- Private subnets (one per availability zone) for internal resources
- Internet Gateway for public subnet internet connectivity
- NAT Gateways (one per availability zone) for private subnet
  outbound access
- Elastic IPs attached to each NAT Gateway for fixed public addressing

## Architecture

Analogies help me understand concepts, I use an estate analogy to explain this:
- The VPC is the estate grounds - everything lives inside it
- The Internet Gateway is the front gate - two way traffic for
  public resources
- Public subnets are the front of the estate - resources here get
  a visible street address
- Private subnets are the back of the estate - internal only,
  no direct internet access
- NAT Gateways are the internal security guards - private resources
  can send outbound traffic but nothing unsolicited gets in
- Elastic IPs are the fixed P.O. box numbers on the security
  guards - permanent addresses so responses know where to return to
- Availability zones are separate islands - if one goes down,
  the other keeps running

## Project Structure

aws-infrastructure/
├── modules/
│   └── networking/
│       ├── main.tf        # VPC, subnets, IGW, NAT, EIP resources
│       ├── variables.tf   # Input variable declarations
│       └── outputs.tf     # Exposed values for other modules
├── environments/
│   ├── dev/
│   │   ├── main.tf        # Calls networking module
│   │   ├── variables.tf   # Variable declarations for dev
│   │   └── terraform.tfvars # Dev environment values
│   └── prod/
│       ├── main.tf        # Calls networking module
│       ├── variables.tf   # Variable declarations for prod
│       └── terraform.tfvars # Prod environment values
└── README.md

## Key Design Decisions

**Reusable modules** - the networking module is environment agnostic.
The same blueprint deploys to dev and prod with different values,
avoiding code duplication.

**Environment separation** - dev uses 10.0.x.x and prod uses
10.1.x.x CIDR ranges. Non-overlapping ranges mean these VPCs could
be peered or connected to an on-premises network without routing
conflicts.

**High availability** - resources are spread across two availability
zones. If eu-west-2a goes offline, eu-west-2b continues serving
traffic independently.

**One NAT gateway per AZ** - rather than sharing a single NAT
gateway, each availability zone has its own. This prevents a single
NAT gateway failure from taking down outbound connectivity for
all private subnets.

## How To Use
```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

To tear down:
```bash
terraform destroy
```

Note: NAT Gateways are not free tier eligible. Always run
terraform destroy after testing to avoid unnecessary costs.

## Tech Stack

- Terraform
- AWS (VPC, EC2 networking primitives, EIP)
- eu-west-2 (London) region

## Docker Application

A simple Python Flask application containerised with Docker and pushed to AWS ECR.

### What it demonstrates
- Writing a Dockerfile from scratch
- Building a Docker image with layered caching
- Running containers locally and verifying health endpoints
- Tagging and pushing images to AWS ECR

### How to build and run locally
```bash
cd docker-app
docker build -t dillon-flask-app .
docker run -p 5001:5000 dillon-flask-app
```

Visit http://localhost:5001 for the home route.
Visit http://localhost:5001/health for the health check endpoint.

### ECR Repository
820242927995.dkr.ecr.eu-west-2.amazonaws.com/dillon-flask-app

## Kubernetes on EKS

Deployed the containerised Flask application onto AWS EKS using Kubernetes manifests.

### What it demonstrates
- Provisioning a managed EKS cluster using eksctl
- Writing Kubernetes Deployment and Service manifests
- Deploying a containerised application from ECR onto EKS
- Exposing the application publicly via an AWS Load Balancer
- Debugging real production issues including node capacity constraints,
  ECR IAM permissions, and platform architecture mismatches

### Architecture
- EKS cluster with managed t3.small worker nodes across two AZs
- Deployment managing two replicas with readiness probes
- LoadBalancer Service distributing traffic across healthy Pods
- IAM role attached to node instance roles for ECR image pull access

### Key commands
```bash
eksctl create cluster --name dillon-portfolio-cluster --region eu-west-2
kubectl apply -f kubernetes/
kubectl get pods
kubectl get service flask-app-service
eksctl delete cluster --name dillon-portfolio-cluster --region eu-west-2
```

### Issues debugged
- t3.micro nodes insufficient due to system Pod overhead - upgraded to t3.small
- ECR ImagePullBackOff - resolved by attaching AmazonEC2ContainerRegistryReadOnly
  policy to node instance IAM roles
- Platform architecture mismatch - rebuilt image with --platform linux/amd64
  for Apple Silicon compatibility with AWS x86 nodes

## Portfolio Roadmap

- [x] Multi-environment networking module (VPC, subnets, IGW, NAT, route tables)
- [x] EC2 instances with security groups
- [x] Docker containerisation and ECR
- [x] Kubernetes on EKS (Deployment, Service, Load Balancer)
- [ ] Application Load Balancer
- [ ] Prometheus and Grafana observability layer
