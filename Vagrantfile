Vagrant.configure(2) do |config|
  config.vm.box = "bento/ubuntu-15.04"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
    vb.memory = 1024
  end

  (0..2).each do |i|
    config.vm.define vm_name = "%s-%02d" % ["cnvm-host", i] do |config|
      config.vm.hostname = vm_name
      config.vm.network :private_network, ip: "172.17.8.#{i+100}"
      config.vm.provision "shell", inline: [
        "cp /vagrant/.vagrant/machines/#{vm_name}/virtualbox/private_key /home/vagrant/.ssh/id_rsa",
        "chmod 0600 /home/vagrant/.ssh/id_rsa",
        "ln /home/vagrant/.ssh/authorized_keys /home/vagrant/.ssh/id_rsa.pub",
        "chown vagrant. -R /home/vagrant/.ssh",
        "cat /home/vagrant/.ssh/authorized_keys > /vagrant/.vagrant/machines/#{vm_name}/authorized_keys",
        "mkdir /root/.ssh",
        "chmod 0700 /root/.ssh",
        "(test $HOSTNAME = cnvm-host-00 && cp /home/vagrant/.ssh/authorized_keys /root/.ssh/authorized_keys || cp /vagrant/.vagrant/machines/cnvm-host-00/authorized_keys /root/.ssh/authorized_keys)",
        "chown root. /root/.ssh/authorized_keys",
        "chmod 0600 /root/.ssh/authorized_keys",
      ].join('&&')
    end
  end
  config.vm.provision "docker", images: %w(weaveworks/weave:1.1.1 weaveworks/weaveexec:1.1.1  gonkulatorlabs/cnvm)
end
