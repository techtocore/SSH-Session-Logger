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
