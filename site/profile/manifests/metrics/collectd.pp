class profile::metrics::collectd {
  $collectd_dir = '/etc/collectd'
  $collectd_version = '5.1.0-1.el6.rft'

  $dependencies = [
    'perl',
    'perl-devel',
    'perl-CGI',
    'perl-Collectd',
    'perl-Config-General',
    'perl-Time-HiRes',
    'perl-URI',
    'spamassassin',
    'OpenIPMI-perl',
    'lm_sensors',
    'libstatgrab',
    'libtool-ltdl',
  ]

  # We need this repo because it has the latest version of collectd
  # other ones only have version 4 which does not support graphite
  yumrepo { 'dag_testing_packages':
    ensure   => present,
    enabled  => '1',
    gpgcheck => '0',
    baseurl  => 'ftp://fr2.rpmfind.net/linux/dag/redhat/el6/en/$basearch/testing',
  }

  # Do this yumrepo before ANY packages
  Yumrepo['dag_testing_packages'] -> Package <||>

  package { $dependencies:
    ensure => present,
    before => Package['collectd'],
  }

  class { '::collectd':
    purge_config   => true,
    package_ensure => $collectd_version,
  }

  include ::collectd::plugin::cpu
  include ::collectd::plugin::disk
  include ::collectd::plugin::java
  include ::collectd::plugin::memory
  include ::collectd::plugin::interface

  collectd::plugin::write_graphite::carbon {'my_graphite':
    graphitehost   => 'metrics.methodologies.com',
    graphiteport   => 2003,
    graphiteprefix => '',
    protocol       => 'tcp'
  }

}
