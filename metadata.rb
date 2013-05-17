name             "cookbook-openstack-orchestration"
maintainer       "Hendrik Volkmer"
maintainer_email "h.volkmer@cloudbau.de"
license          "Apache License, Version 2.0"
description      "Installs/Configures heat-cookbook"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"

depends "mysql"
depends "rabbitmq"