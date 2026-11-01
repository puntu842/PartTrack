const router = require('express').Router();
const c = require('../controllers/partController');
const { requireLogin, requireRole } = require('../middleware/auth');

router.use(requireLogin);
router.get('/', requireRole('admin', 'technician'), c.list);
router.put('/:id/stock', requireRole('admin'), c.addStock);
module.exports = router;