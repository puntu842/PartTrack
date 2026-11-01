const pool = require('../db');

// GET /parts  -> stock list with a reorder flag
exports.list = async (req, res) => {
  try {
    const [rows] = await pool.execute(
      `SELECT part_id, name, sku, current_stock, reorder_point,
              (current_stock <= reorder_point) AS needs_reorder
         FROM part ORDER BY name`);
    res.json(rows.map(r => ({ ...r, needs_reorder: !!r.needs_reorder })));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// PUT /parts/:id/stock  body: { "add": 20 }  -> shipment arrived
exports.addStock = async (req, res) => {
  try {
    const add = Number(req.body.add);
    if (!Number.isInteger(add) || add <= 0) {
      return res.status(400).json({ error: 'add must be a positive integer' });
    }
    const [r] = await pool.execute(
      'UPDATE part SET current_stock = current_stock + ? WHERE part_id = ?',
      [add, req.params.id]);
    if (r.affectedRows === 0) return res.status(404).json({ error: 'part not found' });
    res.json({ ok: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};