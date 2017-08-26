class profile::eyeunify::core (
  String $source = 'https://eyeunify.org/wp_root/wp-content/uploads/2016/11/eyeUNIFYcore_1_2_8953ad59.zip',
) {
  include ::profile::eyeunify::base
  include ::profile::eyeunify::core::database_connection

  # Create users
  file { 'unify_users_file':
    ensure  => file,
    path    => "${wildfly::dirname}/${wildfly::mode}/configuration/unify-default-users.properties",
    owner   => $wildfly::user,
    group   => $wildfly::group,
    mode    => '0644',
    require => Class['::wildfly::install'],
  }

  wildfly::config::user { 'admin':
    password  => 'admin',
    file_name => 'unify-default-users.properties',
    require   => File['unify_users_file'],
  }

  wildfly::config::user_roles { 'admin':
    roles => 'administrator,operator',
  }

  wildfly::config::user { 'guest':
    password  => 'guest',
    file_name => 'unify-default-users.properties',
    require   => File['unify_users_file'],
  }

  wildfly::config::user_roles { 'guest':
    roles => 'administrator,operator',
  }

  # Actually deploy the core
  archive { 'eyeunify_core.zip':
    path         => '/tmp/eyeunify_core.zip',
    source       => $source,
    extract      => true,
    extract_path => '/tmp',
    creates      => '/tmp/gpl.txt',
    cleanup      => true,
    user         => $wildfly::user,
    group        => $wildfly::user,
    require      => Package['unzip'],
  }

  wildfly::deployment { 'eyeunify_core.war':
    source  => 'file://tmp/eyeUNIFYctrl_1_2_74261798.war',
    require => Archive['eyeunify_core.zip'],
  }
}
