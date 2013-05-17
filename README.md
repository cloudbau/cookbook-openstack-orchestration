# heat-cookbook cookbook



# Requirements

Use at least vagrant 1.2.x

    vagrant plugin install vagrant-openstack-plugin
	vagrant plugin install vagrant-berkshelf

Example config.yml

    os_username: your-os-username
    os_password: secrete
    os_endpoint: http://10.122.0.11:5000/v2.0/tokens
    os_keypair: devteam
    os_keystone_host: 10.122.0.11
    heat_keystone_user: heat
    heat_keystone_pass: secretheatpw


Deploy the heat using:

	vagrant up --provider=openstack

# Usage

# Attributes

# Recipes

# Author

Author:: Hendrik Volkmer (<h.volkmer@cloudbau.de>)
