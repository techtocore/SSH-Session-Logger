from flask import Flask, request
from jinja2 import Environment
import os

cmd = 'service cron start && /usr/sbin/sshd -d &'
os.system(cmd)

app = Flask(__name__)
Jinja2 = Environment()

@app.route("/")
def page():

    name = request.values.get('name', "")
    
    # SSTI VULNERABILITY
    # The vulnerability is introduced concatenating the
    # user-provided `name` variable to the template string.
    output = Jinja2.from_string('Your name is: ' + name + '!').render()

    return output

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')