FROM ubuntu:16.04

RUN apt-get update && \
    apt-get install -y \
            sudo \
            openssh-server \
            openssl
RUN mkdir /var/run/sshd


RUN randpwd=`openssl rand -base64 8`; echo "root:$randpwd" | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

RUN addgroup --gid 1234 test; addgroup docker; \
    adduser --ingroup test --disabled-password --gecos "" --uid 1234 test --shell /bin/bash; adduser test docker
RUN randpwd=`openssl rand -base64 8`; echo 'test:$randpwd' | chpasswd

RUN echo "test ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
ENV AUTH_KEY ""

ADD testhost-entrypoint.sh /usr/local/bin

# Ports used by ssh and ystia components
EXPOSE 22 80 8080 8088 8800 8500 

ENTRYPOINT ["testhost-entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
