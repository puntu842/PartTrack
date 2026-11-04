require('dotenv').config();
const express = require('express');
const cors = require('cors');
const app = express();
const cors = require('cors');

app.use(cors({
    origin: ['http://localhost:5173'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    methods: ['GET', 'POST', 'PUT', 'DELETE']
}));

app.use(cors({ origin: 'http://localhost:5173' }));
app.use(express.json());
app.use(express.static('public'));

app.use('/auth', require('./routes/auth'));
app.use('/parts', require('./routes/parts'));
app.use('/usage', require('./routes/usage'));
app.use('/users', require('./routes/users'));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`http://localhost:${PORT}`));