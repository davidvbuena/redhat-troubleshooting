guest_ip  = "192.168.8.244"
dirpath = __dir__
# host = __dir__.match(/[^\/]+.$/) ### hostname as a name of folder
host = "vm-vagrant-rhel8-caseslabs"
workpath = "C:\\genesis\\redhat\\cases\\2023"

Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox" do |v|
    v.name = host
  end  
  config.vm.box = "generic/rhel8"
  config.vm.network "private_network", ip: guest_ip
  config.vm.provision "shell", path: dirpath + "\\shell-scripts\\sh-simple-provision.sh"
  config.vm.synced_folder dirpath + "\\sync-folder", "/home/vagrant"
  config.vm.synced_folder workpath, "/home/cases"
  config.vm.network "public_network", bridge: "Intel(R) Wireless-AC 9560"
  config.vm.hostname = host
  # config.vm.provision "ansible_local" do |a|
	# a.playbook = "playbook.yaml"
	# end  
end

# puts "-------------------------------------------------"
# puts "Demo URL : http://#{guest_ip}"
# puts "-------------------------------------------------"
