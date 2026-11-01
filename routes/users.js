const router = require('express').Router();
const c = require('../controllers/userController');
const { requireLogin, requireRole } = require('../middleware/auth');

router.put('/:id/deactivate', requireLogin, requireRole('admin'), c.deactivate);
module.exports = router;