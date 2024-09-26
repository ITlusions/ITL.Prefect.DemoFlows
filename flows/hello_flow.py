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