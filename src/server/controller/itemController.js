const sqlite3 = require('sqlite3').verbose();
const db = new sqlite3.Database('./database/database.sqlite');


db.serialize(() => {
  db.run(`CREATE TABLE IF NOT EXISTS Item (
             id INTEGER PRIMARY KEY AUTOINCREMENT,
             name TEXT NOT NULL,
             quantity INTEGER NOT NULL,
             cost INTEGER NOT NULL,
             supplier TEXT NOT NULL,
             expiration_date TEXT NOT NULL
          )`);
});


exports.getItems = (req, res) => {
  db.all('SELECT * FROM Item', [], (err, rows) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    res.status(200).json(rows);
  });
};


exports.getItem = (req, res) => {
  
  if (!validateId(req.params.id).valid) {
    return res.status(400).json({ error: validateId(req.params.id).error });
  }

  const { id } = req.params;
  db.get('SELECT * FROM Item WHERE id = ?', [id], (err, row) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    if (!row) {
      return res.status(404).json({ error: 'Item not found' });
    }
    res.status(200).json(row);
  });
}



exports.addItem = (req, res) => {

  if (!validateItem(req.body).valid) {
    return res.status(400).json({ error: validateItem(req.body).error });
  }
  
  const { name, quantity, cost, supplier, expiration_date } = req.body;

  const sql = `INSERT INTO Item (name, quantity, cost, supplier, expiration_date) VALUES (?, ?, ?, ?, ?)`;
  db.run(sql, [name, quantity, cost, supplier, expiration_date], function (err) {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    res.status(201).json({ id: this.lastID, name: name, quantity: quantity, cost: cost, supplier: supplier, expiration_date: expiration_date });
  });
};


exports.updateItem = (req, res) => {

  if (!validateItem(req.body).valid) {
    return res.status(400).json({ error: validateItem(req.body).error });
  }
  
  if (!validateId(req.params.id).valid) {
    return res.status(400).json({ error: validateId(req.params.id).error });

  }

  const { id } = req.params;
  const { name, quantity, cost, supplier, expiration_date } = req.body;

  const sql = `UPDATE Item SET name = ?, quantity = ?, cost = ?, supplier = ?, expiration_date = ? WHERE id = ?`;
  db.run(sql, [name, quantity, cost, supplier, expiration_date, id], function (err) {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    const numericId = parseInt(id);
    res.status(200).json({ id: numericId, name: name, quantity: quantity, cost: cost, supplier: supplier, expiration_date: expiration_date });
  });
};


exports.deleteItem = (req, res) => {

  if (!validateId(req.params.id).valid) {
    return res.status(400).json({ error: validateId(req.params.id).error });
  }

  const { id } = req.params;
  const sql = `DELETE FROM Item WHERE id = ?`;
  db.run(sql, id, function (err) {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    res.status(200).json({ changes: this.changes });
  });
};


validateItem = (item) => {
    const { name, quantity, cost, supplier, expiration_date } = item;
    if (!name || !quantity || !cost || !supplier || !expiration_date) {
      return {valid: false, error: 'All fields are required'};
    }

    if (typeof name !== 'string') {
      return {valid: false, error: 'Name must be a string'};
    }

    if (typeof quantity !== 'number') {
      return {valid: false, error: 'Quantity must be a number'};
    }

    if (typeof cost !== 'number') {
      return {valid: false, error: 'Cost must be a number'};
    }

    if (typeof supplier !== 'string') {
      return {valid: false, error: 'Supplier must be a string'};
    }

    if (typeof expiration_date !== 'string') {
      return {valid: false, error: 'Expiration date must be a string'};
    }

    const nameRegex = '^[a-zA-Z ,.-]+$';

    if (!name.match(nameRegex)) {
        return {valid: false, error: 'Name must contain only letters, spaces, commas, periods, and hyphens'};
    }

    if (!supplier.match(nameRegex)) {
        return {valid: false, error: 'Supplier must contain only letters, spaces, commas, periods, and hyphens'};
    }

    if (quantity <= 0 || !Number.isInteger(quantity)) {
      return {valid: false, error: 'Quantity must be greater than 0'};
    }

    if (cost <= 0 || !Number.isInteger(cost)) {
      return {valid: false, error: 'Cost must be greater than 0'};
    }

    const dateRegex = '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';

    if (!expiration_date.match(dateRegex)) {
        return {valid: false, error: 'Expiration date must be in the format YYYY-MM-DD'};
    }

    const [year, month, day] = expiration_date.split('-');

    if (month < 1 || month > 12) {
        return {valid: false, error: 'Expiration date month must be between 1 and 12'};
    }

    if (day < 1 || day > 31) {
        return {valid: false, error: 'Expiration date day must be between 1 and 31'};
    }

    if (month === 2 && day > 29) {
        return {valid: false, error: 'Expiration date day must be between 1 and 29 for February'};
    }

    if ([4, 6, 9, 11].includes(month) && day > 30) {
        return {valid: false, error: 'Expiration date day must be between 1 and 30 for this month'};
    }

    return {valid: true};
}


validateId = (id) => {
    if (!id || !Number.isInteger(parseInt(id))) {
        return {valid: false, error: 'ID must be an integer'};
    }

    if (parseInt(id) <= 0) {
        return {valid: false, error: 'ID must be greater than 0'};
    }

    return {valid: true};
}