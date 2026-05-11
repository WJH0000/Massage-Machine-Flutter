// index.js
const express = require('express');
const path    = require('path');
const wifi    = require('node-wifi');

const app  = express();
const PORT = 3000;

// ←––– replace with the exact STA IP your ESP32 printed! –––→
const ESP32_IP = '10.0.0.122';

app.use(express.json());
wifi.init({ iface: null });

// 1) Scan PC adapter
app.get('/api/scan', async (req, res) => {
  try {
    const nets = await wifi.scan();
    res.json(nets);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// 2) Connect PC to Wi‑Fi
app.post('/api/connect', async (req, res) => {
  const { ssid, password } = req.body;
  try {
    await wifi.connect(password ? { ssid, password } : { ssid });
    res.json({ success: true, ssid });
  } catch (e) {
    res.status(500).json({ success: false, error: e.message });
  }
});

// 3) Proxy motor calls to ESP32
app.post('/api/motor', async (req, res) => {
  try {
    const resp = await fetch(`http://${ESP32_IP}/api/motor`, {
      method:  'POST',
      headers: { 'Content-Type':'application/json' },
      body:    JSON.stringify(req.body)
    });
    res.json(await resp.json());
  } catch (e) {
    res.status(500).json({ success:false, error:e.message });
  }
});

// 4) Serve UI
app.use(express.static(path.join(__dirname, 'public')));

app.listen(PORT, () => {
  console.log(`Server: http://localhost:${PORT}`);
});
