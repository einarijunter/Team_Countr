CREATE DATABASE countr;

CREATE TABLE main ( 
    id SERIAL PRIMARY KEY,
    location VARCHAR(64),
    uuid VARCHAR(255),
    timestamp TIMESTAMP,
    gender VARCHAR(32),
    child INT,
    pregnantWoman INT
);

CREATE TABLE valid_uuids (
    uuid VARCHAR(255) PRIMARY KEY,
    date_issued DATETIME
);


INSERT INTO main (uuid, timestamp) VALUES (
    '02e4e062-384d-4549-ac35-b60e60a13496',
    '2021-10-29'
);



""" Test uuids

8d8820b1-d57a-4a40-a3a7-550b744ce940
02e4e062-384d-4549-ac35-b60e60a13496
ac6b8314-e5c3-4dc3-885f-adb773260e43
aac8ec9d-404c-4529-902a-edc858fccb6f
9362c86e-aba3-458b-abf2-89aeeb8bd4cb
5c5005a7-bb54-4df3-9596-c71748e2aa1c
f5820a37-9287-459a-88f9-203141b5e123
3d79b9f5-de65-44bc-9c4f-0e7d8f08832b
00cea726-a9c8-40a4-bddd-bdb7fd46ed76
1f2307ff-367a-43a7-9139-cb77cf1042f0
"""