from ntpath import join
import os
from flask_mysqldb import MySQL
from flask import Flask, render_template
from flask import request
import datetime
import pytz

# creates a Flask application named app 
app = Flask(__name__)

app.config['MYSQL_HOST'] = 'mysql'
app.config['MYSQL_PORT'] = 3306
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'root1234'
app.config['MYSQL_DB'] = 'mysql'
 
mysql = MySQL(app)

host = os.uname()[1]

def createTable():
    cursor = mysql.connection.cursor()
    cursor.execute(''' CREATE TABLE IF NOT EXISTS chat1 (
                        room VARCHAR(20),
                        times VARCHAR(50),
                        username VARCHAR(30),
                        message VARCHAR(50)
                       ) ''')
    mysql.connection.commit()

def convertTuple(tup):
        # initialize an empty string
    string_converted = ''
    for item in tup:
        string_converted = string_converted + str(item) + " "
    return string_converted

# a route where we display the template
@app.route("/", methods=['GET'])
def index():
    return render_template('index.html')

@app.route("/chat/<room>")
def main(room):
    return render_template('index.html')

@app.route("/<room>")
def main2(room):
    return render_template('index.html')


@app.route("/api/chat/<room>", methods=['POST', 'GET'])
def chat(room):
    dbs = None
    createTable()
    if request.method == 'POST':
        tz_hcm = pytz.timezone('Asia/Ho_Chi_Minh')
        start_utc = datetime.datetime.now(tz_hcm)
        time_now = start_utc.strftime("%Y-%m-%d %X")
        username = request.form['username']
        messages = request.form['msg']
        cursor = mysql.connection.cursor()
        cursor.execute(''' INSERT INTO chat1(room, times, username, message) VALUES (%s,%s,%s,%s)''', (room,time_now,username,messages))
        mysql.connection.commit()
        cursor.close()
        return ''
    else:
        cursor = mysql.connection.cursor()
        cursor.execute(''' SELECT * FROM chat1 WHERE room=%s ''', (room,))
        dbs = cursor.fetchall()
        cursor.close()
        str_result = 'Load balancing server: ' + host + "\n\n"
        for line in dbs:
            str_result = str_result + convertTuple(line) + '\n'
        return str_result
    



# run the application
if __name__ == "__main__":
    app.run('0.0.0.0', debug=True)
