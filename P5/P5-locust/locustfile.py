from locust import HttpUser, TaskSet, task, between

class P5_tuusuariougr(TaskSet):
    @task
    def load_index(self):
        self.client.get("/index.php", verify=False)

class P5_usuarios(HttpUser):
    tasks = [P5_tuusuariougr]
    wait_time = between(1, 5)