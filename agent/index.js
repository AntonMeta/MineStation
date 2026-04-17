const express = require('express');
const { Rcon } = require('rcon-client');
const app = express();

app.use(express.json());

const PORT = process.env.PORT;
const rconConfig = {
    host: process.env.RCON_HOST,
    port: parseInt(process.env.RCON_PORT),
    password: process.env.RCON_PASSWORD
};

// fail-fast
if (!rconConfig.password || !rconConfig.host) {
    console.error("BŁĄD: Brak zmiennych RCON_HOST lub RCON_PASSWORD w środowisku!");
    process.exit(1);
}

async function sendMC(command) {
    let rcon;
    try {
        rcon = await Rcon.connect(rconConfig);
        const res = await rcon.send(command);
        return { success: true, response: res };
    } catch (err) {
        return { success: false, error: err.message };
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
    const result = await sendMC(cmd);
    res.json(result);
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`MineStation Agent uzbrojony na porcie ${PORT}`);
});