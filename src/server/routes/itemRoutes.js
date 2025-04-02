const express = require('express');

const createItemRoutes = (itemController) => {
  const router = express.Router();

  router.get('/', (_, res) => {
    res.status(200).json({ message: 'Welcome to the inventory API' });
  });
  router.get('/items', itemController.getItems);
  router.get('/items/:id', itemController.getItem);
  router.post('/items', itemController.addItem);
  router.put('/items/:id', itemController.updateItem);
  router.delete('/items/:id', itemController.deleteItem);

  return router;
};

module.exports = createItemRoutes;
