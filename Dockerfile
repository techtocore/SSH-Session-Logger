FROM ubuntu:latest

# Add the script to the Docker Image
ADD log.sh /root/log.sh

# Give execution rights on the cron scripts
RUN chmod 0644 /root/log.sh

#Install Cron
RUN apt update
RUN apt -y install cron

# Add the cron job
RUN crontab -l | { cat; echo "* * * * * bash /root/log.sh"; } | crontab -

RUN sysctl --write net.ipv4.ip_forward=1

# Flask server setup
RUN apt -y install python3 python3-pip
RUN pip3 install flask
ADD flask_app.py /root/flask_app.py

ENTRYPOINT [ "python3" ]

CMD [ "/root/flask_app.py" ]
