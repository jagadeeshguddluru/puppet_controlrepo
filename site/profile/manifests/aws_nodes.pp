#
class profile::aws_nodes {
  ec2_instance { 'agent-1':
    ensure            => 'running',
    availability_zone => 'ap-southeast-2c',
    block_devices     => [
      {
        'delete_on_termination' => true,
        'device_name'           => '/dev/sda1',
        'volume_size'           => 10,
      }
    ],
    ebs_optimized     => false,
    image_id          => 'ami-e0c19f83',
    instance_type     => 't2.micro',
    key_name          => 'personal_aws',
    monitoring        => false,
    region            => 'ap-southeast-2',
    #security_groups   => ['default'],
    user_data         => epp('profile/userdata.epp',{
      'master_ip'   => $::ec2_metadata['public-ipv4'],
      'master_fqdn' => $::networking['fqdn'],
      })
  }
}
