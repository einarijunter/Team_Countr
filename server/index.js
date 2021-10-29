const express = require("express");
const app = express();
const cors = require("cors");
const pool = require("./db");

//middlwware
app.use(cors());
app.use(express.json()); //req.body

//ROUTES//

// //create a record

// app.post("/records", async (req,res) => {
//     try {
//         const { description } = req.body;
//         const newTodo = await pool.query(
//             "INSERT INTO main (uuid, timestamp) VALUES($1, $2) RETURNING *",
//             [description,]
//         );
    
//         res.json(newTodo.rows[0]);
//     } catch (err) {
//         console.error(err.message);
//     }
// })

//get all record

app.get("/records", async (req,res) => {
    try {
        const allRecords = await pool.query("SELECT * FROM main");
        res.json(allRecords.rows);
    } catch (err) {
        console.error(err.message);
    }
});


//get a todo

app.get("/records/:id", async (req,res) => {
    try {
        const { id } = req.params;
        const record = await pool.query("SELECT * FROM main WHERE id = $1", [id]);
        res.json(record.rows[0]);
    } catch (err) {
        console.error(err.message);
    }
});

//count records


app.listen(5000, () => {
    console.log("server has started on port 5000")
});