# OpenStack Orchestration (Heat) Cookbook


# Requirements

This cookbook has been tested using Ubuntu 12.04.

Use at least Vagrant 1.2.x

    vagrant plugin install vagrant-openstack-plugin
    vagrant plugin install vagrant-berkshelf

Example `config.yml`

    os_username: your-os-username
    os_password: secrete
    os_endpoint: http://10.122.0.11:5000/v2.0/tokens
    os_keypair: devteam
    os_keystone_host: 10.122.0.11
    os_ssh_username: ubuntu
    os_image: precise-image
    os_network: new-default
    os_floating_ip: 10.122.1.32
    heat_keystone_user: heat
    heat_keystone_pass: secretheatpw
    heat_auth_encryption_key: f36c192d6a3d035fcc885d9988a64889 # hexdump -n 16 -v -e '/1 "%02x"' /dev/random
    private_key_path: ~/.ssh/mykeys/id_rsa
    use_omnibus_plugin: true
    os_user_data: |
      #!/bin/sh
      echo "nameserver 8.8.8.8" > /etc/resolv.conf


Deploy the heat using:

    vagrant up --provider=openstack

# Usage

# Attributes

# Recipes

# Author

Author:: Hendrik Volkmer (<h.volkmer@cloudbau.de>)
Author:: Stephan Renatus (<s.renatus@cloudbau.de>)
