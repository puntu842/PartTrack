const router = require('express').Router();
const c = require('../controllers/usageController');
const { requireLogin, requireRole } = require('../middleware/auth');

router.post('/', requireLogin, requireRole('technician', 'admin'), c.log);
module.exports = router;