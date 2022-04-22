FROM ubuntu:latest

# Install required softwares
RUN apt update
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York
RUN apt -y install cron 
RUN apt -y install python3 python3-pip
RUN apt -y install openssh-server sudo

# Add the script to the Docker Image
ADD log.sh /root/log.sh
RUN chmod u+x /root/log.sh

# Add the cron job
RUN crontab -l | { cat; echo "* * * * * bash /root/log.sh"; } | crontab -

# Flask server setup
RUN pip3 install flask
ADD flask_app.py /root/flask_app.py

# Accept SSH connections 

RUN mkdir /var/run/sshd
RUN echo 'root:Docker!' | chpasswd
RUN echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
RUN sysctl net.ipv4.conf.all.forwarding=1
RUN iptables -P FORWARD ACCEPT

EXPOSE 22 5000

ENTRYPOINT [ "python3" ]

CMD [ "/root/flask_app.py" ]
