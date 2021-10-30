import sys
import requests
import psycopg2


conn = psycopg2.connect(
    host="",
    database="countr",
    user="postgres",
    password="")

api_url = 'http://localhost:5000/records/'

r = requests.get(api_url).json()
##print(r[0])

# import Python's JSON lib
import json

# import the new JSON method from psycopg2
from psycopg2.extras import Json

# use JSON loads to create a list of records
record_list = json.loads(str(r).replace("'",'"'))


# create a nested list of the records' values
values = [list(x.values()) for x in record_list]

# get the column names
columns = [list(x.keys()) for x in record_list][0]

# value string for the SQL string
values_str = ""

# enumerate over the records' values
for i, record in enumerate(values):

    # declare empty list for values
    val_list = []
   
    # append each value to a new list of values
    for v, val in enumerate(record):
        if type(val) == str:
            val = str(Json(val)).replace('"', '')
        val_list += [ str(val) ]

    # put parenthesis around each record string
    values_str += "(" + ', '.join( val_list ) + "),\n"

# remove the last comma and end SQL with a semicolon
values_str = values_str[:-2] + " ON CONFLICT DO NOTHING;"

# concatenate the SQL string
table_name = "main"
sql_string = "INSERT INTO %s (%s)\nVALUES %s" % (
    table_name,
    ', '.join(columns),
    values_str
)

cur = conn.cursor()
print ("\ncreated cursor object:", cur)

if cur != None:

    try:
        cur.execute( sql_string )
        conn.commit()

        print ('\nfinished INSERT INTO execution')

    except (Exception, Error) as error:
        print("\nexecute_sql() error:", error)
        conn.rollback()

    # close the cursor and connection
    cur.close()
    conn.close()
