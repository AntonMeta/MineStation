const express = require('express');
const app = express();
const PORT = 3000;

app.get('/status', (req, res) => {
    res.json({
        serverName: "Samsung A52 - MineDroid",
        status: "Online",
        players: 0,
        ramUsage: "1.2GB / 6GB"
    });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Agent nasłuchuje na porcie ${PORT}`);
});
