FROM ubuntu:latest

# Install required softwares
RUN apt update
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York
RUN apt -y install cron 
RUN apt -y install python3 python3-pip
RUN apt -y install openssh-server sudo
RUN apt -y install strace vim

# Add the script to the Docker Image
ADD log.sh /root/log.sh
RUN chmod u+x /root/log.sh

# Add the cron job
RUN crontab -l | { cat; echo "* * * * * bash /root/log.sh"; } | crontab -

# Flask server setup
RUN pip3 install flask
ADD flask_app.py /root/flask_app.py

# Accept SSH connections 

RUN echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config \
 && sed -i -e 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
 && sed -i -e 's/#PermitUserEnvironment no/PermitUserEnvironment yes/' /etc/ssh/sshd_config \
 && mkdir -p /root/.ssh \
 && chmod 700 /root/.ssh \
 && mkdir -p /run/sshd \
 && echo 'root:root' | chpasswd
RUN sysctl net.ipv4.conf.all.forwarding=1

EXPOSE 22 5000

ENTRYPOINT ["/entrypoint.sh"]
ADD entrypoint.sh /entrypoint.sh

RUN chmod 555 /entrypoint.sh
