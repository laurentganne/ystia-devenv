# Test host

Provides containers with ssh server and docker-in-docker capabilities, to be used in a development environment in a Hosts Pool  managed by the [Ystia orchestrator](https://github.com/ystia/yorc).

For example, running this command (--privileged is required by docker-in-docker) :
```bash
docker run --privileged -p 8701:22 \
           -e "AUTH_KEY=$(cat $HOME/testhost_secrets/authorized_keys)" \
           --rm -d --name host1 --hostname host1 laurentg/testhost
```
It is then possible to login on the container using this command :
```bash
ssh -i $HOME/testhost_secrets/id_rsa test@localhost -p 8701
```

