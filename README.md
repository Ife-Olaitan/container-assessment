# MuchToDo API - Container Assessment

A RESTful API for managing tasks (todos) with user authentication, built with Go and MongoDB. This project demonstrates containerization with Docker and orchestration with Kubernetes.

## Project Overview

MuchToDo is a production-ready API featuring:
- User authentication with JWT tokens
- CRUD operations for todos
- MongoDB for data persistence
- Optional Redis caching
- Health monitoring endpoints
- Swagger API documentation

## Tech Stack

- **Backend**: Go (Golang)
- **Database**: MongoDB 8.0
- **Containerization**: Docker
- **Orchestration**: Kubernetes (KIND)
- **Ingress**: NGINX Ingress Controller

## Prerequisites

- Docker and Docker Compose
- Kubernetes cluster (KIND recommended)
- kubectl CLI tool
- Go 1.25+ (for local development)

## Project Structure

```
.
├── MuchToDo/                 # Go application source code
├── kubernetes/               # Kubernetes manifests
│   ├── backend/             # Backend deployment, service, secrets
│   ├── mongodb/             # MongoDB deployment, service, PVC
│   ├── namespace.yaml       # Namespace definition
│   ├── ingress.yaml         # Ingress configuration
│   └── kind-config.yaml     # KIND cluster configuration
├── scripts/                  # Deployment automation scripts
│   ├── docker-build.sh      # Build Docker images
│   ├── docker-run.sh        # Run with docker-compose
│   ├── k8s-deploy.sh        # Deploy to Kubernetes
│   └── k8s-cleanup.sh       # Clean up Kubernetes resources
├── docker-compose.yaml       # Docker Compose configuration
├── Dockerfile               # Multi-stage Docker build
├── .env.example             # Example environment variables
└── .env                     # Environment variables (not in version control)

```

## Quick Start

### Option 1: Docker Compose

1. **Set up environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

2. **Run with docker-compose:**
   ```bash
   ./scripts/docker-run.sh
   ```

3. **Access the API:**
   ```bash
   curl http://localhost:8080/health
   ```

### Option 2: Kubernetes (KIND)

1. **Create KIND cluster with port mappings:**
   ```bash
   kind create cluster --name muchtodo-app --config kubernetes/kind-config.yaml
   ```

2. **Deploy to Kubernetes:**
   ```bash
   ./scripts/k8s-deploy.sh
   ```

3. **Add to /etc/hosts:**
   ```bash
   echo '127.0.0.1 muchtodo.local' | sudo tee -a /etc/hosts
   ```

4. **Access the API:**
   ```bash
   curl http://muchtodo.local
   curl http://muchtodo.local/health
   ```

## Scripts Usage

### Build Docker Image
```bash
./scripts/docker-build.sh
```
Builds the Docker image (configured in the script)

### Run with Docker Compose
```bash
./scripts/docker-run.sh
```
Starts all services (backend + MongoDB) using docker-compose

### Deploy to Kubernetes
```bash
./scripts/k8s-deploy.sh
```
Deploys the entire stack to Kubernetes:
- Creates namespace
- Deploys MongoDB with persistent storage
- Deploys backend with 2 replicas
- Installs NGINX Ingress Controller (if needed)
- Configures Ingress routing

### Clean up Kubernetes
```bash
./scripts/k8s-cleanup.sh
```
Removes all deployed resources from Kubernetes

## Configuration

### Environment Variables

Copy the example environment file and customize as needed:

```bash
cp .env.example .env
```

The `.env.example` file contains all required and optional configuration variables with default values. Update the values according to your environment.

## Kubernetes Resources

### MongoDB
- **Deployment**: Single replica, standalone mode
- **Service**: ClusterIP on port 27017
- **Storage**: 5Gi PersistentVolumeClaim
- **Secrets**: Root credentials stored in Secret

### Backend
- **Deployment**: 2 replicas for high availability
- **Service**: ClusterIP on port 8080
- **Secrets**: JWT secret and .env file mounted from Secret
- **Health Probes**: Liveness and readiness probes configured

### Ingress
- **Controller**: NGINX Ingress Controller
- **Host**: muchtodo.local
- **Routing**: All paths (/) routed to backend service

## API Endpoints

### Health Check
```bash
GET /health
Response: {"cache":"disabled","database":"ok"}
```

### Root
```bash
GET /
Response: {"message":"Welcome to MuchToDo API"}
```

### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login user

### Todos (requires authentication)
- `GET /todos` - List all todos
- `POST /todos` - Create todo
- `GET /todos/:id` - Get todo by ID
- `PUT /todos/:id` - Update todo
- `DELETE /todos/:id` - Delete todo

### API Documentation
Access Swagger documentation at `/swagger/index.html` (if available)

## Accessing the API

### Docker Compose
```bash
# API root
curl http://localhost:8080

# Health check
curl http://localhost:8080/health
```

### Kubernetes (with port mappings)
```bash
# Via Ingress
curl http://muchtodo.local
curl http://muchtodo.local/health

# Direct to backend (for testing)
kubectl port-forward -n muchtodo svc/backend-service 8080:8080
curl http://localhost:8080/health
```

### Kubernetes (without port mappings)
```bash
# Port-forward to Ingress
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80
curl http://localhost:8080 -H "Host: muchtodo.local"

# Or direct to backend
kubectl port-forward -n muchtodo svc/backend-service 8080:8080
curl http://localhost:8080
```

## Troubleshooting

### Docker Compose Issues

**MongoDB not starting:**
```bash
docker-compose logs mongodb
docker-compose down -v  # Remove volumes and restart
```

**Port already in use:**
```bash
lsof -ti :8080 | xargs kill -9
```

### Kubernetes Issues

**Pods not starting:**
```bash
kubectl get pods -n muchtodo
kubectl describe pod <pod-name> -n muchtodo
kubectl logs <pod-name> -n muchtodo
```

**MongoDB connection issues:**
```bash
# Check MongoDB is running
kubectl get pods -n muchtodo -l app=mongodb

# Test connection from backend pod
kubectl exec -it <backend-pod> -n muchtodo -- curl mongodb:27017
```

**Ingress not working:**
```bash
# Check Ingress controller is running
kubectl get pods -n ingress-nginx

# Check Ingress resource
kubectl get ingress -n muchtodo
kubectl describe ingress muchtodo-ingress -n muchtodo
```

## Development

### Local Development
```bash
cd MuchToDo
go mod download
go run cmd/api/main.go
```

### Building and Pushing Your Own Docker Image

If you want to use your own Docker image:

1. **Choose your image name** (e.g., `your-username/your-app:your-tag`)

2. **Update the image name in these three files:**
   - `scripts/docker-build.sh`
   - `kubernetes/backend/backend-deployment.yaml`
   - `docker-compose.yaml`

3. **Build and push your image:**
   ```bash
   # Build using the script
   ./scripts/docker-build.sh

   # Login to your registry
   docker login

   # Push your image
   docker push your-username/your-app:your-tag
   ```

**Tip:** You can use different container registries by updating the image path format:
- Docker Hub: `username/image-name:tag`
- AWS ECR: `account-id.dkr.ecr.region.amazonaws.com/image-name:tag`
- Google GCR: `gcr.io/project-id/image-name:tag`
- GitHub: `ghcr.io/username/image-name:tag`
- Azure ACR: `registry-name.azurecr.io/image-name:tag`

## Architecture Decisions

### Why standalone MongoDB?
- Simplified setup for development/assessment
- No replica set complexity (keyFile, init scripts)
- Sufficient for single-node KIND clusters
- Easy to upgrade to replica sets in production

### Why mount .env from Secret?
- The Go app uses Viper to read .env file directly
- More flexible than individual environment variables
- Easy to update configuration without code changes

### Why NGINX Ingress?
- Most popular Kubernetes Ingress controller
- Well-documented and widely supported
- Native support for KIND clusters

## Production Considerations

For production deployment, consider:
- Use MongoDB replica sets for high availability
- Enable TLS/HTTPS on Ingress
- Use managed Kubernetes (EKS, GKE, AKS)
- Store secrets in external secret managers (Vault, AWS Secrets Manager)
- Enable Redis caching for better performance
- Set up monitoring and logging (Prometheus, Grafana)
- Implement resource quotas and limits
- Use HPA (Horizontal Pod Autoscaler) for backend