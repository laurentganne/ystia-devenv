# Test host

Provides containers with ssh server, to be used in a development environment in a Hosts Pool managed by the [Ystia orchestrator](https://github.com/ystia/yorc), to deploy [Ystia Forge components](https://github.com/alien4cloud/csar-public-library/tree/develop/org/ystia).

For example, to have a container that you can to access through ssh and on which you need to define a HTTP proxy, create a file `devenv.sh` with this content:
```bash
HTTP_PROXY=http://1.2.3.4:8080
HTTPS_PROXY=http://1.2.3.4:8080
```

Then run this command to create the container:
```bash
docker run -p 8701:22 \
           -e "AUTH_KEY=$(cat $HOME/testhost_secrets/authorized_keys)" \
           --env-file devenv.sh \
           --rm -d --name host1 --hostname host1 laurentg/ystiahost
```
It is then possible to login on the container using this command :
```bash
ssh -i $HOME/testhost_secrets/id_rsa test@localhost -p 8701
```

Or you can create a docker network :
```bash
docker network create --driver=bridge --subnet=192.168.2.0/24 dockernet0
```
and then assign IP addresses to each test host on this subnet :
```bash
docker run -p 8701:22 \
           -e "AUTH_KEY=$(cat $HOME/testhost_secrets/authorized_keys)" \
           --env-file devenv.sh \
           --net dockernet0 --ip 192.168.2.11 \
           --rm -d --name host1 --hostname host1 laurentg/ystiahost
```
So that within each of this ystia host container, you could connect doing :
```bash
ssh -i /path_to_secrets/id_rsa test@host1
```

