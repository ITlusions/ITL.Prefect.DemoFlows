from prefect import flow, task
from prefect.deployments import Deployment
from prefect.filesystems import LocalFileSystem

# Define a task
@task
def say_hello():
    print("Hello from Prefect 3!")

# Define the flow
@flow
def hello_flow():
    say_hello()

# Register the flow with Prefect
if __name__ == "__main__":
    # Create a LocalFileSystem storage block
    local_storage = LocalFileSystem(basepath="/opt/prefect/flows")

    # Create a deployment for the flow
    deployment = Deployment.build_from_flow(
        flow=hello_flow,
        name="hello-flow-deployment",
        worker_pool="k8s-pool-01"  # Specify your worker pool name here
    )

    # Register the deployment with Prefect
    deployment.apply()
    
    # Optionally run the flow immediately after registration
    hello_flow()