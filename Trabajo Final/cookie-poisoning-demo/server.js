const express = require('express');
const cookieParser = require('cookie-parser');
const app = express();

app.use(cookieParser());
app.use(express.json());

const PORT = 3000;

// Middleware para verificar autenticación
function checkAuth(req, res, next) {
    const userCookie = req.cookies.user;
    if (userCookie) {
        const user = JSON.parse(userCookie);
        req.user = user;
        next();
    } else {
        res.status(401).send('No estás autenticado');
    }
}

// Ruta de login
app.post('/login', (req, res) => {
    const { username, role } = req.body;
    if (username && role) {
        const user = { username, role };
        res.cookie('user', JSON.stringify(user), { httpOnly: true });
        res.send('Inicio de sesión exitoso');
    } else {
        res.status(400).send('Faltan parámetros');
    }
});

// Ruta protegida
app.get('/admin', checkAuth, (req, res) => {
    if (req.user.role === 'admin') {
        res.send(`Bienvenido, admin ${req.user.username}`);
    } else {
        res.status(403).send('Acceso denegado');
    }
});

// Ruta pública
app.get('/', (req, res) => {
    res.send('Página pública');
});

app.listen(PORT, () => {
    console.log(`Servidor escuchando en http://localhost:${PORT}`);
});
