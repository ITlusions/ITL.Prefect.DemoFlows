# Use Python 3.9 slim image as the base image
FROM python:3.9-slim

# Set environment variables for Prefect
ENV PREFECT_API_URL=http://prefect-server.prefect-server.svc.cluster.local:4200/api
ENV PREFECT_ORION_UI_URL=http://prefect-server.prefect-server.svc.cluster.local:4200

# Install system dependencies (if needed)
RUN apt-get update && apt-get install -y \
    build-essential \
    nano \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Prefect 3.x
RUN pip install --no-cache-dir prefect

# Copy your local flow code into the container (assuming your flow is in the "flows" directory)
COPY ./flows /opt/prefect/flows/

# Set the working directory in the container
WORKDIR /opt/prefect/flows/

# Optionally, install any additional Python dependencies your flow requires
# For example, if your flow needs requests, pandas, etc.
# You can use a requirements.txt file if you have one
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Set the default command to run your flow
# Replace "hello_flow.py" with the name of your Python flow script
