# -*- mode: ruby -*-
# # vi: set ft=ruby :
#dcmove repo test 2
require 'fileutils'

Vagrant.require_version ">= 1.7.0"

CONFIG = File.join(File.dirname(__FILE__), "config.rb")

#what provider are we executing for?
provider_is_aws  = (!ARGV.nil? && ARGV.join('').include?('provider=aws'))
provider_is_vmware = (!ARGV.nil? && ARGV.join('').include?('provider=vmware'))
provider_is_virtualbox = (!ARGV.nil? && ARGV.join('').include?('provider=virtualbox'))
provider_is_google = (!ARGV.nil? && ARGV.join('').include?('provider=google'))
provider_is_digital_ocean = (!ARGV.nil? && ARGV.join('').include?('provider=digital_ocean'))
provider_is_azure = (!ARGV.nil? && ARGV.join('').include?('provider=azure'))

#complain about missing plugins depending on provider
if provider_is_aws
	 unless Vagrant.has_plugin?("vagrant-aws") 
	  # great plugin routine from https://github.com/WhoopInc/s3auth
  	  # Attempt to install ourself. Bail out on failure so we don't get stuck in an
	  # infinite loop.
	    puts "Did not detect vagrant-aws plugin..."
	    system('vagrant plugin install vagrant-aws') || exit!

	   # Relaunch Vagrant so the plugin is detected. Exit with the same status code.
	   exit system('vagrant', *ARGV)
	   exit
	end
end

if provider_is_vmware
unless Vagrant.has_plugin?("vagrant-vmware-fusion") or Vagrant.has_plugin?("vagrant-vmware-workstation")
            puts "Did not detect vagrant-vmware-fusion or vagrant-vmware-workstation plugin..."
            puts "Install the appropriate plugin (fusion for mac, workstationf or windows) and re-run your comand"
           exit
        end

end

if provider_is_google
	 unless Vagrant.has_plugin?("vagrant-google") 
            puts "Did not detect vagrant-google plugin..."
            system('vagrant plugin install vagrant-google') || exit!
           # Relaunch Vagrant so the plugin is detected. Exit with the same status code.
           exit system('vagrant', *ARGV)
           exit
	end
end

if provider_is_digital_ocean
	 unless Vagrant.has_plugin?("vagrant-digitalocean") 
            puts "Did not detect vagrant-digitalocean plugin..."
            system('vagrant plugin install vagrant-digitalocean') || exit!
           # Relaunch Vagrant so the plugin is detected. Exit with the same status code.
           exit system('vagrant', *ARGV)
           exit
	end
end

if provider_is_azure
	 unless Vagrant.has_plugin?("vagrant-azure") 
            puts "Did not detect vagrant-azure plugin..."
            system('vagrant plugin install vagrant-azure') || exit!

           # Relaunch Vagrant so the plugin is detected. Exit with the same status code.
           exit system('vagrant', *ARGV)
           exit

	end
end


#azure ssh port increment var 
ssh_port = 9000
  
# Defaults Attempt to apply the deprecated environment variable NUM_INSTANCES to
# $num_instances while allowing config.rb to override it
if ENV["NUM_INSTANCES"].to_i > 0 && ENV["NUM_INSTANCES"]
  $num_instances = ENV["NUM_INSTANCES"].to_i
end

if File.exist?(CONFIG)
  require CONFIG
end

Vagrant.configure("2") do |config|

config.vm.box = "boxcutter/ubuntu1504"
config.vm.box_url = "https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1504.json"
config.vm.boot_timeout = 1000

  config.vm.provider :vmware_fusion do |vb, override|
  override.vm.box_url = "https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1504.json"
  end
  
	
 ["google"].each do |google|
	config.vm.provider google do |z, override|
        override.vm.box = "gce"
	override.vm.box_url = "https://github.com/mitchellh/vagrant-google/raw/master/google.box"
	override.vm.box_version = ""
	end
     end
     
     ["digital_ocean"].each do |digital_ocean|
	 
   config.vm.provider digital_ocean do |z, override|
        override.vm.box = "digital_ocean"
	override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"
	override.vm.box_version = ""
	end
     end

    
     ["azure"].each do |azure|
	config.vm.provider azure do |q, override|
        override.vm.box = "azure"
	override.vm.box_url = "https://github.com/msopentech/vagrant-azure/raw/master/dummy.box"
	override.vm.box_version = ""
	end
     end

 ["aws"].each do |aws|
     config.vm.provider aws do |x, override|
     override.vm.box = "dummy"
     override.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
     override.vm.box_version = ""
    end
  end

  # plugin conflict
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end

#Name the hosts 

  (0..$num_instances-1).each do |i|
   #config.vm.define vm_name = "cnvm-%02d" % i do |config|
   config.vm.define vm_name = "%s-%02d" % ["cnvm-host", i] do |config|
   config.vm.hostname = vm_name
        ips = %x[echo #{vm_name} >> thehosts]
        ips = %x[sort -u thehosts > therunninghosts]
            config.vm.provision "shell", inline: [
            "hostname #{vm_name}",
            "echo #{vm_name} > /etc/hostname",
            "ssh-keygen -f id_rsa -t rsa -N ''",
             "mkdir -p /root/.ssh && cat id_rsa.pub >> /root/.ssh/authorized_keys && cp id_rsa* /root/.ssh",
             "chown $SUDO_USER id_rsa*",
             "sudo apt-get update -y",
             "sudo apt-get install docker.io -y",
             "sudo usermod -aG docker $SUDO_USER",
             "sudo service docker start",
             "sudo apt-get install linux-image-extra-$(uname -r) -y"
            ].join('&&')
      ssh_port = (ssh_port + 1)
  end

      if $enable_serial_logging
        logdir = File.join(File.dirname(__FILE__), "log")
        FileUtils.mkdir_p(logdir)

        serialFile = File.join(logdir, "%s-serial.txt" % vm_name)
        FileUtils.touch(serialFile)

        config.vm.provider :vmware_fusion do |v, override|
          v.vmx["serial0.present"] = "TRUE"
          v.vmx["serial0.fileType"] = "file"
          v.vmx["serial0.fileName"] = serialFile
          v.vmx["serial0.tryNoRxLoss"] = "FALSE"
        end

        config.vm.provider :virtualbox do |vb, override|
          vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
          vb.customize ["modifyvm", :id, "--uartmode1", serialFile]
        end
      end

      if $expose_docker_tcp
        config.vm.network "forwarded_port", guest: 2375, host: ($expose_docker_tcp + i - 1), auto_correct: true
      end

      config.vm.provider :vmware_fusion do |vb|
        vb.gui = $vb_gui
      end

      config.vm.provider :virtualbox do |vb|
        vb.gui = $vb_gui
        vb.memory = $vb_memory
        vb.cpus = $vb_cpus
      end

      ip = "172.17.8.#{i+100}"
      config.vm.network :private_network, ip: ip

      #disable synced folders
      config.vm.synced_folder '.', '/vagrant', disabled: true

##do the azure setup
     ["azure"].each do |azure|
	   config.vm.provider azure do |a, override|
	     a.mgmt_certificate = ENV['AZURE_MGMT_CERT']
	     a.mgmt_endpoint = ENV['AZURE_MGMT_ENDPOINT']
	     a.subscription_id = ENV['AZURE_SUB_ID']
	     a.storage_acct_name = ENV['AZURE_STORAGE_ACCT']
	     a.vm_image = ENV['AZURE_VM_IMAGE']
       a.vm_size = ENV['AZURE_VM_SIZE']
       a.vm_user = 'azureuser' # defaults to 'vagrant' if not provided
       a.vm_name = vm_name
       a.deployment_name = 'gonk'
       a.vm_location = 'West US'
       override.ssh.username = 'azureuser' 
	     override.ssh.private_key_path = ENV['AZURE_SSH_PRIV_KEY']
	     a.private_key_file = ENV['AZURE_PRIV_KEY']
       a.ssh_port = ssh_port
       	end
      end

 ##do the digital_ocean setup
     ["digital_ocean"].each do |digital_ocean|
	config.vm.provider digital_ocean do |d, override|
   		d.token = ENV['DO_TOKEN']
    		d.image = ENV['DO_IMAGE']
	    	d.region = ENV['DO_REGION']
    		d.size = ENV['DO_SIZE']
		d.root_username = 'root'
		d.private_networking = true 
		override.ssh.username = 'root'
		override.ssh.private_key_path = ENV['DO_OVERRIDE_KEY']
		d.setup = false
		end
	    end
     
     ##do the google setup
     ["google"].each do |google|
	     config.vm.provider google do |g, override|
		    g.google_project_id = ENV['GC_PROJECT']
		    g.google_client_email = ENV['GC_CLIENT_EMAIL']
		    g.google_key_location = ENV['GC_KEY_LOCATION']
		    g.machine_type = ENV['GC_MACHINETYPE']
		    g.image = ENV['GC_IMAGE']
		    override.ssh.username = "ubuntu"
		    override.ssh.private_key_path = ENV['GC_OVERRIDE_KEY']
		    end
	    end

     ##do the aws setup
     ["aws"].each do |aws|
        config.vm.provider aws do |a, override|
                a.access_key_id = ENV['AWS_KEY']
                a.secret_access_key = ENV['AWS_SECRET']
                a.keypair_name = ENV['AWS_KEYNAME']
		            a.region = ENV['AWS_REGION'] 
		            a.instance_type = ENV['AWS_INSTANCE']
		            a.security_groups =  ENV['AWS_SECURITYGROUP']
		            a.ami = ENV['AWS_AMI']
                override.ssh.private_key_path = ENV['AWS_KEYPATH']
                override.ssh.username = "ubuntu"
              end
      end

   
    end


end