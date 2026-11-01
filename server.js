require('dotenv').config();
const express = require('express');
const app = express();

app.use(express.json());
app.use(express.static('public'));

app.use('/auth', require('./routes/auth'));
app.use('/parts', require('./routes/parts'));
app.use('/usage', require('./routes/usage'));
app.use('/users', require('./routes/users'));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`http://localhost:${PORT}`));