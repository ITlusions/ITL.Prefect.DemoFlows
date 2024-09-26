# ITL Prefect DemoFlows

This project is just a simple demo how to build, deploy, and manage a simple Prefect flow using Kubernetes, along with automating the Docker image build and push process using GitHub Actions.

## Table of Contents

- [Overview](#overview)
- [Prefect Flow](#prefect-flow)
- [Kubernetes Job Template](#kubernetes-job-template)
- [GitHub Actions Workflow](#github-actions-workflow)
- [Configuration](#configuration)
- [Usage](#usage)

## Overview

This repository includes:

- A simple Prefect flow that prints a greeting message.
- A Kubernetes Job template for running the flow.
- A GitHub Actions workflow for building and pushing the Docker image to Docker Hub.

## Prefect Flow

The main functionality is encapsulated in the `hello_flow.py` file. Here’s the updated code:

```python
from prefect import flow, task

# Define a task
@task
def say_hello():
    print("Hello from Prefect 3!")

# Define the flow
@flow
def hello_flow():
    say_hello()

# Run the flow directly when the script is executed
if __name__ == "__main__":
    hello_flow()
```

This code with just a simple flow that calls a task to print a message when the script is executed.

## Kubernetes Job Template

The Kubernetes Job template (`job.yaml`) specifies how to execute the Prefect flow within a Kubernetes cluster. Here’s an overview of the components:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: prefect-flow-job-{{ randAlphaNum 5 | lower }}  # Unique job name
  namespace: {{ .Values.namespace }}  # Namespace from values.yaml
spec:
  ttlSecondsAfterFinished: 30  # Cleanup job after 30 seconds
  template:
    spec:
      containers:
        - name: prefect-flow-container
          image: "docker.io/nweistra/itlprefecthelloflow:{{ .Values.image.tag }}"  # Docker image
          env:
            - name: PREFECT_API_URL
              value: {{ .Values.prefect.api.url }}  # Prefect API URL
          command: ["python", "/opt/prefect/flows/hello_flow.py"]
          resources:
            limits:
              memory: "256Mi"
              cpu: "500m"
            requests:
              memory: "128Mi"
              cpu: "250m"
      restartPolicy: Never
```

### Key Features

- **Unique Job Names**: Ensures that each job instance has a unique name to avoid conflicts.
- **TTL (Time to Live)**: Automatically deletes the job 30 seconds after completion.
- **Container Specification**: Runs the flow in a container with the specified Docker image and environment variables.

## GitHub Actions Workflow

The GitHub Actions workflow (`.github/workflows/docker-build-push.yml`) automates the building and pushing of the Docker image. You need to update it according to your needs:

```yaml
name: Build and Push Docker Image

on:
  push:
    branches:
      - main  # Default branch

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Log in to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Build Docker Image
        run: |
          docker build -t nweistra/itlprefecthelloflow:1.0.0 .
          docker tag nweistra/itlprefecthelloflow:1.0.0 nweistra/itlprefecthelloflow:latest

      - name: Push Docker Image
        run: |
          docker push nweistra/itlprefecthelloflow:1.0.0
          docker push nweistra/itlprefecthelloflow:latest
```

### Workflow Steps

1. **Checkout Code**: Clones the repository to the runner.
2. **Log In to Docker Hub**: Authenticates using stored secrets.
3. **Build Docker Image**: Creates the Docker image.
4. **Push Docker Image**: Pushes the image to Docker Hub.

## Configuration

The configuration file `values.yaml` includes settings for your Kubernetes Job and Docker image:

```yaml
namespace: prefect-helloflow  # Namespace for the job

image:
  repository: "docker.io/nweistra/itlprefecthelloflow"  # Docker image repository
  name: itlprefecthelloflow  # Image name
  tag: latest  # Version tag for the image

prefect:
  api:
    url: http://prefect-server.prefect-server.svc.cluster.local:4200/api  # Prefect API URL
```

## Usage

To deploy your Prefect flow on Kubernetes:

1. **Install Helm**: Ensure Helm is installed and configured for your Kubernetes cluster.
2. **Deploy the Job**: Run the following command:

   ```bash
   helm install <release-name> . -f values.yaml
   ```

3. **Check Job Status**: Monitor the job status:

   ```bash
   kubectl get jobs -n prefect-helloflow
   ```