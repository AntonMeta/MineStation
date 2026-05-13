const express = require('express');
const { Rcon } = require('rcon-client');
const app = express();

app.use(express.json());

const PORT = process.env.PORT || 3000;
const API_KEY = process.env.API_KEY;

const rconConfig = {
    host: process.env.RCON_HOST,
    port: parseInt(process.env.RCON_PORT),
    password: process.env.RCON_PASSWORD,
    timeout: 5000
};

// fail-fast
if (!rconConfig.password || !rconConfig.host || !API_KEY) {
    console.error("BŁĄD: Brak zmiennych RCON_HOST, RCON_PASSWORD lub API_KEY!");
    process.exit(1);
}


app.use((req, res, next) => {
    const clientKey = req.headers['x-api-key'] || req.query.key;

    if (clientKey !== API_KEY) {
        console.warn(`Zablokowano próbę dostępu z nieznanym kluczem: ${clientKey}`);
        return res.status(401).json({ success: false, error: "Brak dostępu. Błędny klucz API." });
    }
    next();
});

async function sendMC(command) {
    let rcon;
    try {
        rcon = await Rcon.connect(rconConfig);
        const res = await rcon.send(command);
        return { success: true, response: res };
    } catch (err) {
        console.error(`RCON Błąd (${command}):`, err.message);
        return { success: false, error: "Błąd komunikacji z serwerem MC: " + err.message };
    } finally {
        if (rcon) rcon.end();
    }
}

app.get('/status', async (req, res) => {
    const mc = await sendMC("list");
    res.json({
        status: mc.success ? "ONLINE" : "OFFLINE",
        details: mc.success ? mc.response : mc.error,
        serverName: "MineStation Cloud",
        ramUsage: (process.memoryUsage().heapUsed / 1024 / 1024).toFixed(2) + " MB"
    });
});

app.post('/command', async (req, res) => {
    const { action, target, value } = req.body;
    let cmd = "";

    switch(action) {
        case "op": cmd = `op ${target}`; break;
        case "day": cmd = `time set day`; break;
        case "msg": cmd = `say ${value}`; break;
        default: cmd = target;
    }

    if (!cmd) return res.status(400).json({ success: false, error: "Brak komendy do wykonania" });

    const result = await sendMC(cmd);
    if (!result.success) return res.status(500).json(result);

    res.json(result);
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`MineStation Agent UZBROJONY i ZABEZPIECZONY na porcie ${PORT}`);
});