class profile::cd4pe (
  Enum['source', 'replica'] $ha_mode = 'source',
  String $cd4pe_version              = 'latest',
  String $artifact_dir               = '',
  String $database_dir               = '',
) {
  package { 'podman':
    ensure => present,
  }

  class { '::cd4pe':
    cd4pe_version        => $cd4pe_version,
    manage_database      => true,
    agent_service_port   => 7000,
    backend_service_port => 8000,
    web_ui_port          => 8080,
    require              => Package['podman'],
  }

  case $ha_mode {
    'source': {
      $service_ensure     = 'running'
      $service_enable     = true
      $docker_run_running = true
    }
    'replica': {
      $service_ensure     = 'stopped'
      $service_enable     = false
      $docker_run_running = false
    }
  }

  # Set the state of the service manually. This means that the replica will not
  # be running, but will be ready to go
  Docker::Run <| title == 'cd4pe' |> {
    running => $docker_run_running,
  }

  Service <| name == 'pe-postgresql' |> {
    ensure  => $service_ensure,
    enable  => $service_enable,
  }
}
