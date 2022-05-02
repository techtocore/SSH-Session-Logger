# Honeypot for SSH Session Monitoring & Logging

### Note: This is only a POC implementation and is not meant to be run on production networks

This image include a basic flask app that allows SSTI (Server Side Template Injection) and facilitates RCE (Remote Code Execution). Once a new SSH connection is established to the honeypot, all keystrokes on the remote session are logged locally.

### Usage Instructions

```
docker pull techtocore/ssh-honeypot
docker run -p 5001:5000 -p 5022:22 techtocore/ssh-honeypot
```

### Dev Instructions

```
docker build -t techtocore/ssh-honeypot .
```

The ports can be mapped as required.



## HoneyNet Gateway Installation for Ubuntu
### Install [Docker](https://docs.docker.com/v17.09/engine/installation/linux/docker-ce/ubuntu/)
```
sudo apt -y install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
apt-cache policy docker-ce
sudo apt -y install docker-ce
```

### Install supporting system tools
~~~ shell
sudo apt-get update
sudo apt-get install socat xinetd auditd netcat-openbsd
~~~

### Install the honeypot scripts 

Copy `honeypot` to `/usr/bin/honeypot` and `honeypot.clean` to
`/usr/bin/honeypot.clean` and make them executable. You may have to
customize the ports in the iptables rules, the memory limit of the
container and the network quota if you want to run anything other than
an SSH honeypot on port `22`.

### Configure crond, xinetd and auditd

#### crond

Add the following line to `/etc/crontab`. This runs the cleanup script
to check for old containers every 5 minutes.

~~~ shell
*/5 * * * * /usr/bin/honeypot.clean
~~~

#### xinetd

Create the following service file in `/etc/xinetd.d/honeypot` and add
the line `honeypot 22/tcp` to `/etc/services` to keep xinetd happy.

~~~ shell
# Container launcher for an SSH honeypot
service honeypot
{
        disable         = no
        instances       = UNLIMITED
        server          = /usr/bin/honeypot
        socket_type     = stream
        protocol        = tcp
        port            = 22
        user            = root
        wait            = no
        log_type        = SYSLOG authpriv info
        log_on_success  = HOST PID
        log_on_failure  = HOST
}
~~~

#### auditd

Enable logging the execve systemcall in auditd by adding the following audit rules:

~~~ shell
auditctl -a exit,always -F arch=b64 -S execve
auditctl -a exit,always -F arch=b32 -S execve
~~~

### Create a base image for the honeypot

A Dockerfile for a base image is included in the `alpinetrap` directory and sets to root password to `root` by default. You can create and configure your own base image without restriction. The container will spin up and be managed by xinitd normally. Any initialization is up to you.

### Final install notes

Make sure to commit the image as "`honeypot:latest`". You may also wish to create additional accounts named `user`, `guest`, `admin`, `temp`, etc., and give them weak passwords like `1234`, or `password` to let brute-force attackers crack your host easily. The IP address of the attacker's host is passed to the container in the environment variable `REMOTE_HOST`. For logging, you may want to configure an rsyslog instance to forward logs to the host machine.