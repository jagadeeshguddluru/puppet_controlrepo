# == Class: profile::sunburst::windows
#
class profile::sunburst::windows (
  String $install_dir = 'C:/inetpub/sunburst',
  String $user        = 'sunburst',
  String $group       = 'sunburst-admins',
  String $password    = 'change3me',
) {
  require ::profile::windows::webserver

  user { $user:
    ensure  => present,
    comment => 'Sunburst Application Service Account',
    groups  => ['Users',$group],
    require => Group[$group],
  }

  group { $group:
    ensure => present,
  }

  exec { 'grant_SeServiceLogonRight':
    command     => "Grant-Privilege -Identity ${user} -Privilege SeServiceLogonRight",
    provider    => 'powershell',
    refreshonly => true,
    subscribe   => User[$user],
    require     => Package['carbon'],
  }

  iis_application_pool { 'sunburst':
    ensure        => present,
    state         => 'started',
    identity_type => 'SpecificUser',
    user_name     => $user,
    password      => $password,
  }

  # Create a new website
  iis_site { 'sunburst':
    ensure          => 'started',
    physicalpath    => 'C:\\inetpub\\sunburst',
    applicationpool => 'sunburst',
    require         => [Iis_application_pool['sunburst'], Dsc_windowsfeature['IIS','AspNet45']],
  }

  file { $install_dir:
    ensure => directory,
  }

  acl { $install_dir:
    inherit_parent_permissions => false,
    purge                      => true,
    owner                      => $user,
    group                      => $group,
    permissions                => [
      {
        'affects'  => 'all',
        'identity' => 'NT AUTHORITY\SYSTEM',
        'rights'   => ['full'],
      },
      {
        'affects'  => 'all',
        'identity' => 'BUILTIN\Administrators',
        'rights'   => ['full'],
      },
      {
        'affects'  => 'all',
        'identity' => "${facts['hostname'].upcase}\\${user}",
        'rights'   => ['full'],
      },
      {
        'affects'  => 'all',
        'identity' => "${facts['hostname'].upcase}\\${group}",
        'rights'   => ['read', 'execute'],
      },
    ],
    require                    => [User[$user],File[$install_dir]],
  }

  file { "${install_dir}/index.html":
    ensure => file,
    mode   => '0644',
    owner  => $user,
    group  => $group,
    source => 'puppet:///modules/profile/sunburst/index.html',
  }

  file { "${install_dir}/flare.json":
    ensure => file,
    mode   => '0644',
    owner  => $user,
    group  => $group,
    source => 'puppet:///modules/profile/sunburst/flare.json',
  }
}
