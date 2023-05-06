## root user via ssh
sudo su -
echo -e "vagrant\nvagrant" | passwd root
    sed -in 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    sed -in 's/GSSAPIAuthentication yes/#GSSAPIAuthentication yes/g' /etc/ssh/sshd_config
    sed -in 's/GSSAPICleanupCredentials no/#GSSAPICleanupCredentials no/g' /etc/ssh/sshd_config

systemctl restart sshd

### Subscribe RHEL Enterprise
sudo subscription-manager register --username "rhn-support-dbuena" --password 795NjB876

### Install Apache HTTPD via repo
sudo yum update -y

### Install Extended Packeges
sudo yum install mod_ssl openssl apr unzip java-1.8.0-openjdk-devel -y

### Extract JBCS via zip ###
sudo unzip /home/vagrant/jbcs-httpd24-httpd-2.4.51-RHEL8-x86_64.zip -d /opt/rh/

### Apache User Group ###
sudo groupadd -g 48 -r apache
sudo /usr/sbin/useradd -c "Apache" -u 48 -g apache -s /sbin/nologin -r apache
sudo chown -R apache:apache *

### Disable SSL ###
sudo mv /opt/rh/jbcs-httpd24-2.4/httpd/conf.d/ssl.conf /opt/rh/jbcs-httpd24-2.4/httpd/conf.d/ssl.conf.disabled

### Home dir for httpd ###
cd /opt/rh/jbcs-httpd24-2.4/httpd/
/opt/rh/jbcs-httpd24-2.4/httpd/.postinstall

### Start JBCS ### 
cd /opt/rh/jbcs-httpd24-2.4/httpd/sbin/
sudo apachectl start

### Firewall Rules ###
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
sudo firewall-cmd --permanent --zone=public --add-port=443/tcp
sudo firewall-cmd --permanent --zone=public --add-port=8080/tcp
sudo firewall-cmd --permanent --zone=public --add-port=9080/tcp
sudo firewall-cmd --permanent --zone=public --add-port=8443/tcp
sudo firewall-cmd --permanent --zone=public --add-port=9443/tcp
sudo firewall-cmd --reload

### Config Listen on httpd ###
sudo mv httpd.conf httpd.conf.backup
sudo sed 's/Listen 127.0.0.1:80/#Listen 127.0.0.1:80\nListen 0.0.0.0:80/g' httpd.conf.backup > httpd.conf

### Backup default mod_cluster ###
#sudo echo -e $'# mod_proxy_balancer should be disabled when mod_cluster is used\nLoadModule proxy_cluster_module modules/mod_proxy_cluster.so\nLoadModule cluster_slotmem_module modules/mod_cluster_slotmem.so\nLoadModule manager_module modules/mod_manager.so\nLoadModule advertise_module modules/mod_advertise.so\n\nMemManagerFile /opt/jbcs-httpd24-2.4/httpd/cache/mod_cluster\n\n<IfModule manager_module>\n    Listen 6666\n    <VirtualHost *:6666>\n        <Directory />\n            Require ip 127.0.0.1\n        </Directory>\n        ServerAdvertise on\n        EnableMCPMReceive\n        <Location /mod_cluster_manager>\n            SetHandler mod_cluster-manager\n            Require ip 127.0.0.1\n     </Location>\n    </VirtualHost>\n</IfModule>' >> /opt/rh/jbcs-httpd24-2.4/httpd/conf.d/mod_cluster.conf

###  Config /opt/jbcs-httpd24-2.4/httpd/conf.d/mod_cluster.conf from bellow ###
sudo echo -e $'# mod_proxy_balancer should be disabled when mod_cluster is used\nLoadModule proxy_cluster_module modules/mod_proxy_cluster.so\nLoadModule cluster_slotmem_module modules/mod_cluster_slotmem.so\nLoadModule manager_module modules/mod_manager.so\nLoadModule advertise_module modules/mod_advertise.so\n\nMemManagerFile /opt/jbcs-httpd24-2.4/httpd/cache/mod_cluster\n\n<IfModule manager_module>\n  Listen 0.0.0.0:10001\n  ManagerBalancerName marlo-sso-demo-cluster\n  <VirtualHost 0.0.0.0:10001>\n    <Location />\n     Require all granted\n    </Location>\n    KeepAliveTimeout 300\n    MaxKeepAliveRequests 0\n    AdvertiseFrequency 5\n    EnableMCPMReceive On\n    <Location /mod_cluster_manager>\n      SetHandler mod_cluster-manager\n      Require all granted\n   </Location>\n  </VirtualHost>\n</IfModule> \n'

### Stop and Start Apache ###
cd /opt/rh/jbcs-httpd24-2.4/httpd/sbin/
sudo apachectl stop
sudo apachectl start

### Installing JBoss EAP | Automated Installer ###
# sudo java -jar jboss-eap-7.0.0-installer.jar auto.xml -variablefile auto.xml.variables 
### Start Stop Jboss
# nohup /opt/jboss-eap-7.0/bin/standalone.sh > jbosseap-ins1.log & 

sudo unzip /home/vagrant/jboss-eap-7.0.0.zip -d /opt/rh/
/opt/rh/jboss-eap-7.0/bin/add-user.sh -u admin -p admin
nohup /opt/rh/jboss-eap-7.0/bin/standalone.sh -b 0.0.0.0 -bmanagement 0.0.0.0 > jbosseap-ins1.log &

### Connect JBoss CLI and Apply patch ###
/opt/rh/jboss-eap-7.0/bin//jboss-cli.sh --connect
patch apply /home/vagrant/jboss-eap-7.0.3-patch.zip
### If was management domain ###
#patch apply /path/to/downloaded-patch.zip --host=my-host
shutdown --restart=true

