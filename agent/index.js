const express = require('express');
const { Rcon } = require('rcon-client');
const app = express();
const PORT = 3000;

const rconConfig = {
    host: process.env.RCON_HOST || 'localhost',
    port: parseInt(process.env.RCON_PORT) || 25575,
    password: process.env.RCON_PASSWORD || 'secret'
};

app.get('/status', async (req, res) => {
    try {
        const rcon = await Rcon.connect(rconConfig);
        const uptime = await rcon.send("uptime");
        const list = await rcon.send("list");
        rcon.end();
        res.json({
            serverName: "MineStation Cloud",
            status: "Połączono z RCON",
            details: list,
            ramUsage: (process.memoryUsage().heapUsed / 1024 / 1024).toFixed(2) + " MB"
        });
    } catch (e) {
        res.json({
            serverName: "MineStation - Tryb Offline",
            status: "Brak połączenia z MC (RCON)",
            details: "Serwer domowy jest nieosiągalny",
            ramUsage: (process.memoryUsage().heapUsed / 1024 / 1024).toFixed(2) + " MB"
        });
    }
});

app.get('/command/:cmd', async (req, res) => {
    try {
        const rcon = await Rcon.connect(rconConfig);
        const response = await rcon.send(req.params.cmd);
        rcon.end();
        res.json({ response });
    } catch (e) {
        res.status(500).json({ error: "Błąd RCON" });
    }
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Kontroler RCON działa na porcie ${PORT}`);
});