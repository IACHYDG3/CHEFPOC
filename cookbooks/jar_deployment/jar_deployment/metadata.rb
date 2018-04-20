name 'jar_deployment'
maintainer 'robertnorthard'
maintainer_email 'robertnorthard@googlemail.com'
license 'All rights reserved'
description 'Installs/Configures jar_deployment'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.2.0'

source_url 'https://github.com/RobertNorthard/cookbook-jar_deployment'
issues_url 'https://github.com/RobertNorthard/cookbook-jar_deployment/issues'

supports 'centos', '>= 6.6'

depends 'java', '~> 1.29'
