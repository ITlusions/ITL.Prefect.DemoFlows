from prefect import flow, task
from prefect.deployments import run_deployment
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

    run_deployment(name="hello-flow")

    
    # Optionally run the flow immediately after registration
    hello_flow()