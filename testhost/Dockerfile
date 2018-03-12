FROM  docker:dind

RUN apk --update add bash openrc openssl openssh
RUN mkdir /var/run/sshd

RUN randpwd=`openssl rand -base64 8`; echo 'root:$randpwd' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
RUN rc-update add sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

RUN addgroup -S -g 1234 test; addgroup docker; \
    adduser -S -G test -u 1234 test -s /bin/bash; addgroup test docker
RUN randpwd=`openssl rand -base64 8`; echo 'test:$randpwd' | chpasswd

ENV AUTH_KEY ""

ADD testhost-entrypoint.sh /usr/local/bin

# Ports used by ssh and ystia components
EXPOSE 22 80 8080 8088 8800 8500 

ENTRYPOINT ["testhost-entrypoint.sh"]
CMD []
