const express = require("express");
const app = express();
const cors = require("cors");
const pool = require("./db");
//const bodyParser = require('body-parser');
//const jsonParser = bodyParser.json();
//const urlencodedParser = bodyParser.urlencodedParser({ extended: false });

//middlwware
app.use(cors());
app.use(express.json()); //req.body
//app.use(bodyParser.json());
//app.use(bodyParser.urlencoded( { extended: true }));

//ROUTES//

// //create a record

app.post("/records", async (req,res) => {
    try {
        const { location, uuid, timestamp, gender, child, pregnantWoman } = req.body;
        const newRecord = await pool.query(
            "INSERT INTO main (location, uuid, timestamp, gender, child, pregnantwoman) VALUES($1, $2, $3, $4, $5, $6) RETURNING *",
            [location, uuid, timestamp, gender, child, pregnantWoman]
        );
    
        res.json(newRecord.rows[0]);
    } catch (err) {
        console.error(err.message);
    }
})


//get all record

app.get("/records", async (req,res) => {
    try {
        const allRecords = await pool.query("SELECT * FROM main");
        res.json(allRecords.rows);
    } catch (err) {
        console.error(err.message);
    }
});


//get a record

app.get("/records/:id", async (req,res) => {
    try {
        const { id } = req.params;
        const record = await pool.query("SELECT * FROM main WHERE id = $1", [id]);
        res.json(record.rows[0]);
    } catch (err) {
        console.error(err.message);
    }
});

//count all records after date

app.get("/records/count/:date", async (req,res) => {
    try {
        const { date } = req.params;
        const record = await pool.query("SELECT COUNT(*) FROM main WHERE timestamp >= $1", [date]);
        res.json(record.rows[0]);
    } catch (err) {
        console.error(err.message);
    }
});


app.listen(5000, () => {
    console.log("server has started on port 5000")
});