const pool = require('../db');

// PUT /users/:id/deactivate  (soft delete: keeps job history intact)
exports.deactivate = async (req, res) => {
  try {
    const [r] = await pool.execute(
      `UPDATE user_account SET is_active = FALSE
        WHERE user_id = ? AND user_id <> ?`,
      [req.params.id, req.user.user_id]);          // admin can't deactivate self
    if (r.affectedRows === 0) return res.status(404).json({ error: 'user not found' });
    res.json({ ok: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};