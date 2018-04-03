# Test host

Provides containers with ssh server, to be used in a development environment in a Hosts Pool managed by the [Ystia orchestrator](https://github.com/ystia/yorc), to deploy [Ystia Forge components](https://github.com/alien4cloud/csar-public-library/tree/develop/org/ystia).

For example, running this command:
```bash
docker run -p 8701:22 \
           -e "AUTH_KEY=$(cat $HOME/testhost_secrets/authorized_keys)" \
           --rm -d --name host1 --hostname host1 laurentg/ystiahost
```
It is then possible to login on the container using this command :
```bash
ssh -i $HOME/testhost_secrets/id_rsa test@localhost -p 8701
```

