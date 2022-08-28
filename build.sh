cat >Dockerfile <<EOF
FROM ubuntu
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends libssh2-1-dev freerdp2-dev libossp-uuid-dev libtool-bin libpng-dev libjpeg-turbo8-dev libcairo2-dev  openjdk-8-jdk libssh2-1-dev freerdp2-dev sudo wget curl && export GUACAMOLE_HOME=/etc/guacamole && wget https://downloads.apache.org/tomcat/tomcat-9/v9.0.65/bin/apache-tomcat-9.0.65.tar.gz &&  mkdir /opt/tomcat && sudo tar -xzf apache-tomcat-9.0.65.tar.gz -C /opt/tomcat/ && rm apache-tomcat-9.0.65.tar.gz && mv /opt/tomcat/apache-tomcat-9.0.65 /opt/tomcat/tomcatapp && chmod +x /opt/tomcat/tomcatapp && rm -rf  /opt/tomcat/tomcatapp/webapps && mkdir -p /opt/tomcat/tomcatapp/webapps/ROOT && cd /opt/tomcat/tomcatapp/webapps/ROOT && wget https://downloads.apache.org/guacamole/1.4.0/binary/guacamole-1.4.0.war  && jar -xvf *.war  && rm *.war && mkdir -p /etc/guacamole/{extensions,lib} && cd /etc/guacamole && wget https://raw.githubusercontent.com/amitstudydude/RDP_Linux/main/guacamole.properties && wget https://raw.githubusercontent.com/amitstudydude/RDP_Linux/main/user-mapping.xml  && sed -i 's/localhost/172.17.0.1/g' /etc/guacamole/user-mapping.xml  && sed -i 's/127.0.0.1/172.17.0.1/g' /etc/guacamole/guacamole.properties  && apt clean && apt autoremove && rm -rf /var/lib/apt/lists/* 
EXPOSE 8080/tcp
CMD /opt/tomcat/tomcatapp/bin/catalina.sh run
EOF

#docker built -t guacamole .
printf "root\nroot" | passwd root &&  printf "root\nroot" | passwd runner && printf "root\nroot" | passwd runneradmin 
cd /
wget -O cli https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 && chmod +x ./cli 
./cli --url http://localhost:8080 &>> 8080 &
apt update  >>/dev/null
apt install xrdp gnome-session >>/dev/null &
docker run --name guacd -d  -p 4822:4822 guacamole/guacd
docker run --name guacamole -dit -p 8080:8080 ghcr.io/amit-study/guacamolev2
service ssh restart && sed -i '3 i PasswordAuthentication yes' /etc/ssh/sshd_config && sed -i '3 i PermitUserEnvironment yes' /etc/ssh/sshd_config && sed -i '3 i PermitRootLogin yes' /etc/ssh/sshd_config && service ssh restart
cat 8080 | sed '5!d' | sed 's:[2022]*:[&:' |  sed 's:https*:](&:' |  sed 's:trycloudflare.com*:&/#/settings/preferences):' | sed -e 's/\[[^][]*\]//g' | sed 's:(:[Click-here]&:' &>> log.txt
apt install xrdp gnome-session >>/dev/null &
while :; do cat log.txt ; sleep 3 ; done

