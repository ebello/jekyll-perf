# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "ubuntu/trusty32"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network "forwarded_port", guest: 3000, host: 3001
  config.vm.network "forwarded_port", guest: 4000, host: 4001

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  # config.ssh.forward_agent = true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  $script = <<SCRIPT
sudo apt-get update
sudo apt-get -y install curl unzip git-core build-essential autoconf automake libtool gettext rake default-jre bundler imagemagick optipng s3cmd xsltproc bison openssl ssh libreadline6 libreadline6-dev zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev libc6-dev ncurses-dev ruby
 
mkdir -p ~/Library/Google/compiler-latest
 
curl -o /tmp/compiler-latest.zip http://dl.google.com/closure-compiler/compiler-latest.zip
unzip /tmp/compiler-latest.zip compiler.jar -d ~/Library/Google/compiler-latest
rm -f /tmp/compiler-latest.zip
 
curl -o ~/Library/Google/compiler-latest/htmlcompressor-1.5.3.jar https://htmlcompressor.googlecode.com/files/htmlcompressor-1.5.3.jar

cd /vagrant

sudo gem install therubyracer thor
bundle install --gemfile=_Gemfile
 
SCRIPT
 
  config.vm.provision "shell", inline: $script, privileged: false
  
end