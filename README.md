# proxy-docker

A proxy server converts a basic authentification proxy to non authentification proxy.
Alpine base image, using Squid.

## Features

 * Requres Docker Compose only
 * No proxy configurations are needed before launch

## Launch

1. Clone repository to your project
```Shell
git clone https://github.com/k-ishigaki/proxy-docker
```

2. Specify a proxy settings and run
```Shell
cd proxy-docker
docker load ./alpine.tar
HTTP_PROXY_FOR_PROXY=http://<proxy_user>:<proxy_password>@<proxy_host>:<proxy_port> HOST_PORT=8080 docker-compose up -d
```

3. Test the connection
```Shell
curl -x localhost:8080 https://www.google.com
```

NOTE: If you are using Docker Toolbox, Extra port forwarding setting is needed to VirtualBox.

## Exit and remove all

```Shell
docker-compose down --rmi all --volume
```