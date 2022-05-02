#!/bin/bash

sudo auditctl -a exit,always -F arch=b64 -S execve
sudo auditctl -a exit,always -F arch=b32 -S execve
sudo systemctl enable acct
sudo systemctl start acct

ssh-keygen -A
/usr/sbin/sshd -D &

python3 /root/flask_app.py

