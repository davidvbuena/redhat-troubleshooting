################## ssh root user
sudo su -
echo -e "vagrant\nvagrant" | passwd root
    sed -in 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    sed -in 's/GSSAPIAuthentication yes/#GSSAPIAuthentication yes/g' /etc/ssh/sshd_config
    sed -in 's/GSSAPICleanupCredentials no/#GSSAPICleanupCredentials no/g' /etc/ssh/sshd_config
    
	systemctl restart sshd

#exit
################## ssh root user

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

### Install Java
sudo yum install java-1.8.0-openjdk-devel -y

### Install Unzip
sudo yum install unzip -y

### Install via ZIP ###
# unzip /vagrant/jboss-eap-7.4.0.zip /opt/jboss-eap-7.4

### Optional to start automatically
#sudo chkconfig jboss-eap-rhel.sh on

### Automated Installer ###

sudo java -jar jboss-eap-7.0.0-installer.jar auto.xml -variablefile auto.xml.variables 

### Not work well
### Configuring JBoss EAP installer installation as a service on RHEL ### 

sudo cp /opt/jboss-eap-7.0/bin/init.d/jboss-eap.conf /etc/default
sudo cp /opt/jboss-eap-7.0/bin/init.d/jboss-eap-rhel.sh /etc/init.d
sudo chmod +x /etc/init.d/jboss-eap-rhel.sh
sudo restorecon /etc/init.d/jboss-eap-rhel.sh
sudo chkconfig --add jboss-eap-rhel.sh
sudo service jboss-eap-rhel start

### Start Stop Jboss
/opt/jboss-eap-7.0/bin/standalone.sh
### Stop





