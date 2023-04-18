FROM ubuntu:16.04

RUN apt-get update && apt-get install -y openssh-server

# configure sftp user
RUN useradd -rm -d /home/kenny -s /bin/bash -G sudo -u 10001 kenny 
RUN echo "kenny:kenny" | chpasswd 

# necessary sshd file
RUN mkdir /var/run/sshd

# SSH login fix (Keeping Session Alive). If not, user will be kick off after ssh
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]

#setup directory for sftp
RUN mkdir -p /var/sftp/uploads
RUN chown root:root /var/sftp
RUN chmod 755 /var/sftp
RUN chown kenny:kenny /var/sftp/uploads


# update to only allow sftp and not ssh tunneling to limit the non-necessary activity 
RUN echo '\n\
Match User kenny  \n\
ForceCommand internal-sftp \n\ 
PasswordAuthentication yes \n\ 
ChrootDirectory /var/sftp \n\ 
PermitTunnel no  \n\ 
AllowAgentForwarding no \n\ 
AllowTcpForwarding no \n\ 
X11Forwarding no ' >> /etc/ssh/sshd_config 
