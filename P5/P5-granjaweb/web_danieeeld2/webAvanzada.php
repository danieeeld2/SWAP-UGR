<?php 
$conexion = new mysqli("192.168.20.50", "wordpress", "wordpress", "wordpress");

// Verificar la conexión
if ($conexion->connect_error) {
    die("Error de conexión: " . $conexion->connect_error);
}

$salida = "";

// Verificar si la tabla existe, si no existe, crearla
$tabla = "usuarios";
$verificar_tabla = $conexion->query("SHOW TABLES LIKE '$tabla'");
if($verificar_tabla->num_rows == 0) {
    // La tabla no existe, entonces la creamos
    $crear_tabla = "CREATE TABLE $tabla (
        id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        nombre VARCHAR(30) NOT NULL,
        apellidos VARCHAR(30) NOT NULL
    )";

    if ($conexion->query($crear_tabla) === TRUE) {
        $salida = "Tabla creada exitosamente";
    } else {
        $salida = "Error al crear la tabla: " . $conexion->error;
    }
}


if(isset($_POST['nombre']) && isset($_POST['apellidos'])) {
    $nombre = $_POST['nombre'];
    $apellidos = $_POST['apellidos'];

    $sql = "INSERT INTO $tabla (nombre, apellidos) VALUES ('$nombre', '$apellidos')";
    if ($conexion->query($sql) === TRUE) {
        $salida = "Registro insertado exitosamente";
    } else {
        $salida =  "Error al insertar registro: " . $conexion->error;
    }
}

$resultado = $conexion->query("SELECT * FROM usuarios");
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            background-color: #f4f4f4;
        }

        form {
            background-color: #fff;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }

        form input[type="text"],
        form input[type="submit"] {
            width: 100%;
            padding: 10px;
            margin-bottom: 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
        }

        form input[type="submit"] {
            background-color: #4caf50;
            color: white;
            cursor: pointer;
        }

        form input[type="submit"]:hover {
            background-color: #45a049;
        }
        table {
            width: 50%;
            margin: 0 auto; 
            border-collapse: collapse;
        }

        th, td {
            padding: 8px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }

        th {
            background-color: #f2f2f2;
        }
    </style>
</head>

<body>
    <form method="post" action="">
        Nombre: <input type="text" name="nombre"><br>
        Apellidos: <input type="text" name="apellidos"><br>
        <input type="submit" value="Insertar">
    </form>

    <?php
        echo "<table>";
        echo "<tr><th>Nombre</th><th>Apellidos</th></tr>";
        
        while ($fila = $resultado->fetch_assoc()) {
            echo "<tr>";
            echo "<td>" . $fila['nombre'] . "</td>";
            echo "<td>" . $fila['apellidos'] . "</td>";
            echo "</tr>";
        }
        echo "<tr><td colspan='2'>Dirección IP del servidor: " . $_SERVER['SERVER_ADDR'] . "</td></tr>";
        if(isset($salida) && $salida != "") {
            echo "<tr><td colspan='2'>$salida</td></tr>";
        }
        echo "</table>";
    ?>

</body>

</html>

<?php
$conexion->close();
?>