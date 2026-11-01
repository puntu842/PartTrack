const pool = require('../db');

// POST /usage  body: { job_id, part_id, quantity }
exports.log = async (req, res) => {
  const jobId = Number(req.body.job_id);
  const partId = Number(req.body.part_id);
  const qty = Number(req.body.quantity);
  if (![jobId, partId, qty].every(Number.isInteger) || qty <= 0) {
    return res.status(400).json({ error: 'job_id, part_id, quantity must be positive integers' });
  }
  try {
    await pool.execute('CALL LogPartUsage(?, ?, ?)', [jobId, partId, qty]);
    res.status(201).json({ ok: true });
  } catch (err) {
    if (err.sqlState === '45000') {                 // trigger: not enough stock
      return res.status(409).json({ error: err.sqlMessage });
    }
    if (err.code === 'ER_NO_REFERENCED_ROW_2') {
      return res.status(404).json({ error: 'job or part not found' });
    }
    res.status(500).json({ error: err.message });
  }
};