#!/bin/bash

ssh-keygen -A

service cron start

/usr/sbin/sshd -D &

python3 /root/flask_app.py

