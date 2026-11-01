require('dotenv').config();
const bcrypt = require('bcryptjs');
const pool = require('../db');

(async () => {
  const hash = await bcrypt.hash('test1234', 10);
  await pool.execute(
    `INSERT INTO user_account (username, first_name, last_name, role, password_hash)
     VALUES ('tech1', 'Tom', 'Tech', 'technician', ?)`, [hash]);
  console.log('tech1 created (password: test1234)');
  process.exit();
})();