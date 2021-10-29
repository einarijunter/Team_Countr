const Pool = require("pg").Pool;

const pool = new Pool({
    user: "pi",
    password: "countr",
    host: "localhost",
    port: 5432,
    database: "countr"
});

module.exports = pool;