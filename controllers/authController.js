const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../db');

exports.login = async (req, res) => {
  try {
    const { username, password } = req.body;
    if (!username || !password) {
      return res.status(400).json({ error: 'username and password required' });
    }
    const [rows] = await pool.execute(
      `SELECT user_id, role, password_hash, is_active
         FROM user_account WHERE username = ?`, [username]);
    const user = rows[0];
    const ok = user && user.is_active &&
               await bcrypt.compare(password, user.password_hash);
    if (!ok) return res.status(401).json({ error: 'wrong username or password' });

    const token = jwt.sign(
      { user_id: user.user_id, role: user.role },
      process.env.JWT_SECRET, { expiresIn: '8h' });
    res.json({ token, role: user.role });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};