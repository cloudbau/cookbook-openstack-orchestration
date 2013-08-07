name             "openstack-orchestration"
maintainer       "Hendrik Volkmer"
maintainer_email "h.volkmer@cloudbau.de"
license          "Apache License, Version 2.0"
description      "Installs/Configures Heat"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.2.0"

supports "ubuntu", ">= 12.04"

depends "mysql"
depends "rabbitmq"
depends "service_factory", "= 0.1.2"
depends "apt", "~> 1.4.4"
depends "python"
