CREATE DATABASE countr;

CREATE TABLE main ( 
    id SERIAL PRIMARY KEY,
    uuid VARCHAR(255),
    timestamp DATETIME
);

CREATE TABLE valid_uuids (
    uuid VARCHAR(255) PRIMARY KEY,
    date_issued DATETIME
);