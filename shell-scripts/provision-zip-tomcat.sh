
# Subscribe With Employe or Premmium User
sudo subscription-manager register --username "rhn-support-dbuena" --password 795NjB876
# sudo subscription-manager repos --enable ansible-automation-platform-2.2-for-rhel-7-x86_64-rpms
# subscription-manager attach --pool=8a85f9a07db4828b017dc51ae7de0901
sudo yum update -y
# sudo yum install ansible -y
sudo yum install httpd -y
sudo yum install mod_ssl openssl -y
sudo yum install openssl -y
sudo yum install apr -y

### Install Certificates
sudo openssl genrsa -out /etc/pki/tls/private/certificatejws5.key 2048
sudo openssl req -new -key /etc/pki/tls/private/certificatejws5.key -out /etc/pki/tls/certs/certificatejws5.csr -batch
sudo openssl x509 -req -days 365 -in /etc/pki/tls/certs/certificatejws5.csr -signkey /etc/pki/tls/private/certificatejws5.key -out /etc/pki/tls/certs/certificatejws5.crt

### Writing .key .crt on ssl.conf
# sudo sed 's/localhost.crt/certificatejws5.crt/g' /etc/httpd/conf.d/ssl.conf > /home/vagrant/tmpssl.conf
# sudo mv -f /home/vagrant/tmpssl.conf /etc/httpd/conf.d/ssl.conf
# sudo sed 's/localhost.key/certificatejws5.key/g' /etc/httpd/conf.d/ssl.conf > /home/vagrant/tmpssl.conf
# sudo mv -f /home/vagrant/tmpssl.conf /etc/httpd/conf.d/ssl.conf

### Increase Log to Loglevel debug
# sudo sed 's/LogLevel warn/LogLevel warn \nLogLevel debug/g' /etc/httpd/conf.d/ssl.conf > /home/vagrant/tmpssl.conf
# sudo mv -f /home/vagrant/tmpssl.conf /etc/httpd/conf.d/ssl.conf

### Install Java
sudo yum install java-1.8.0-openjdk-devel -y

### Install JbossWebServer
# sudo yum remove tomcatjss -y
sudo subscription-manager repos --enable jws-5-for-rhel-7-server-rpms
sudo subscription-manager repos --enable jb-coreservices-1-for-rhel-7-server-rpms
sudo yum groupinstall jws5 -y

sudo cp /etc/opt/rh/jws5/tomcat/server.xml /etc/opt/rh/jws5/tomcat/server.xml.backup

### Add port 9080 Connector
sudo sed 's/<Service name="Catalina">/<Service name="Catalina">\n\n\n <!-- ### custom davidbuena conf -->\n\t<Connector port="9080" protocol="HTTP\/1.1"\n\t\tconnectionTimeout="20000"\n\t\tredirectPort="9443" \/>\n<!-- ### custom davidbuena conf -->/g' /etc/opt/rh/jws5/tomcat/server.xml.backup > /etc/opt/rh/jws5/tomcat/server.xml

### Install Certificates
sudo sed 's/<Service name="Catalina">/<Service name="Catalina">\n\n\n <!-- ### custom davidbuena conf --> \n<Connector port="9443" maxThreads="200" scheme="https" secure="true" SSLEnabled="true"\n\t\tprotocol="org.apache.coyote.http11.Http11AprProtocol"\n\t\tSSLCertificateFile="\/etc\/pki\/tls\/certs\/certificatejws5.crt"\n\t\tSSLCertificateKeyFile="\/etc\/pki\/tls\/private\/certificatejws5.key"\n\t\tSSLProtocol="TLSv1.2"\/>\n<!-- ### custom davidbuena conf -->/g' /etc/opt/rh/jws5/tomcat/server.xml.backup >> /etc/opt/rh/jws5/tomcat/server.xml

### Proxy https:httpd apache -> http:jws tomcat
sudo cp /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.backup

### Proxy https:httpd apache -> http:jws tomcat
sudo sed 's/<\/VirtualHost>/\n### custom davidbuena conf \n### proxy to jws5\n\n\ProxyPreserveHost On\n\n\tProxyPassMatch\t\t\/(.*)$ http:\/\/127.0.0.1:9080\/$1\n\tProxyPassReverse\t\/(.*)$ http:\/\/127.0.0.1:9080\/$1\n\nServerName 127.0.0.1\n\n<\/VirtualHost>/g' /etc/httpd/conf.d/ssl.conf.backup > /etc/httpd/conf.d/ssl.conf

### Proxy https:apache -> https:jws tomcat
sudo sed 's/<\/VirtualHost>/\n### custom davidbuena conf \n### proxy to jws5\n\n\ProxyPreserveHost On\n\n\tProxyPassMatch\t\t\/(.*)$ http:\/\/127.0.0.1:9443\/$1\n\tProxyPassReverse\t\/(.*)$ http:\/\/127.0.0.1:9443\/$1\n\nServerName 127.0.0.1\n\n<\/VirtualHost>/g' /etc/httpd/conf.d/ssl.conf.backup > /etc/httpd/conf.d/ssl.conf

### creating rules to SSLProxyCheck
sudo sed 's/<\/VirtualHost>/<\/VirtualHost>z\n### davidbuena sslproxy confs\nSSLProxyEngine on\nSSLProxyVerify none\nSSLProxyCheckPeerCN off\nSSLProxyCheckPeerName off/g' /etc/httpd/conf.d/ssl.conf.backup > /etc/httpd/conf.d/ssl.conf

sudo systemctl start jws5-tomcat.service

### Creating Firewall Rules
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
sudo firewall-cmd --permanent --zone=public --add-port=443/tcp
sudo firewall-cmd --permanent --zone=public --add-port=8080/tcp
sudo firewall-cmd --permanent --zone=public --add-port=9080/tcp
sudo firewall-cmd --permanent --zone=public --add-port=8443/tcp
sudo firewall-cmd --permanent --zone=public --add-port=9443/tcp
sudo firewall-cmd --reload

sudo systemctl start httpd