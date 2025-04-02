const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const http = require('http');
const { WebSocketServer, WebSocket } = require('ws');
const createItemRoutes = require('./routes/itemRoutes');
const itemController = require('./controller/itemController');
const getLocalIPAddress = require('./utils/serverIp');

const app = express();
const port = 3000;

app.use(cors());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

const server = http.createServer(app);


const wss = new WebSocketServer({ server });
const clients = new Set();

wss.on('connection', (ws) => {
  clients.add(ws);

  ws.on('close', () => {
    clients.delete(ws);
  });
});

const broadcast = (data) => {
  for (const client of clients) {
    if (client.readyState === WebSocket.OPEN) {
      client.send(JSON.stringify(data));
    }
  }
};


const websocketNotifier = (type) => (req, res, next) => {
  res.on('finish', () => {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      const payload = { type, data: req.body, id: req.params?.id };
      broadcast(payload);
    }
  });
  next();
};


app.use(
  '/api',
  createItemRoutes({
    ...itemController,
    addItem: [websocketNotifier('add'), itemController.addItem],
    updateItem: [websocketNotifier('update'), itemController.updateItem],
    deleteItem: [websocketNotifier('delete'), itemController.deleteItem],
  })
);


const serverIp = getLocalIPAddress();

server.listen(port, serverIp, () => {
  console.log(`Store-Inventory server is running at http://${serverIp}:${port}`);
});
