from locust import HttpUser, TaskSet, task, between
import mysql.connector
import random

class P5_danieeeld2(TaskSet):
    @task
    def load_index(self):
        self.client.get("/index.php", verify=False)

    @task
    def load_web(self):
        self.client.get("/webAvanzada.php", verify=False)

    @task
    def insert_user(self):
        # Configurar la conexión a la base de datos MySQL
        self.conn = mysql.connector.connect(
            host="192.168.20.50",
            user="wordpress",
            password="wordpress",
            database="wordpress"
        )
        self.cursor = self.conn.cursor()
        # Inserción de un usuario en la base de datos
        nombre = f"Nombre{random.randint(1, 1000)}"
        apellidos = f"Apellido{random.randint(1, 1000)}"
        query = "INSERT INTO usuarios (nombre, apellidos) VALUES (%s, %s)"
        self.cursor.execute(query, (nombre, apellidos))
        self.conn.commit()
        # Cerrar la conexión a la base de datos al finalizar
        self.cursor.close()
        self.conn.close()

    @task
    def select_users(self):
        # Configurar la conexión a la base de datos MySQL
        self.conn = mysql.connector.connect(
            host="192.168.20.50",
            user="wordpress",
            password="wordpress",
            database="wordpress"
        )
        self.cursor = self.conn.cursor()
        # Obtención de tuplas de la base de datos
        self.cursor.execute("SELECT nombre, apellidos FROM usuarios LIMIT 10")
        rows = self.cursor.fetchall()
        for row in rows:
            print(f"Nombre: {row[0]}, Apellidos: {row[1]}")
        # Cerrar la conexión a la base de datos al finalizar
        self.cursor.close()
        self.conn.close()

class P5_usuarios(HttpUser):
    tasks = [P5_danieeeld2]
    wait_time = between(1, 5)
