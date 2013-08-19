class glusterfs::server (
  $cluster_name = 'gluster', # all servers with the same $cluster_name will automatically join each other
  $address = $ipaddress, # the address other nodes will use to talk to us
  $firewall = false, # whether to configure firewall
) {
  package { 'glusterfs-server':
    ensure => installed,
  }
  service { 'glusterfs-server':
    ensure  => running,
    enable  => true,
    require => Package['glusterfs-server'],
  }

  # here we export ourself
  @@glusterfs::server::peer { $address:
    tag      => $cluster_name,
    firewall => $firewall,
  }
  # and then collect all other peers in the cluster
  Glusterfs::Server::Peer <<| tag == $cluster_name |>>
  #Glusterfs_peer <<| tag == $cluster_name |>>
}
define glusterfs::server::peer (
  $host = $name,
  $firewall = false,
) {
  if !defined(Class['glusterfs::server']) {
    fail("glusterfs::server::peer should not be referenced manually")
  }
  if $glusterfs::server::address != $host {
    if $firewall {
      firewall { "100 glusterfs peer $host":
        source => $host,
        action => 'accept',
        before => Glusterfs_peer[$host],
      }
    }
    glusterfs_peer { $host: }
  }
}

define glusterfs::server::brick (
  $volume, # name of the Glusterfs::Server::Volume this brick belongs to
  $host = $::ipaddress, # hostname/ip of the node serving the brick
  $path, # path to the brick # this is not the $name because the resource is collected, and thus the name must be unique
) {
}

define glusterfs::server::volume (
  $ensure = undef,
  $stripe = undef,
  $replica = undef,
  $transport = undef,
  $rebalance = undef,
  $replace_bricks = undef,
  $remove_bricks = undef,
  $nonfatal_resize_mismatch = undef,
) {
  # This takes advantage of puppet's parsing order.
  # By collecting the resources here, and then defining the volume in a subclass, the collected resources get added to the catalog before the 'assemble' type is called, which can then search the catalog to get the collected bricks.
  # I've tried putting the catalog search in the same defined type as the collection occurs in, but it doesn't work. I'm guessing resource collection is done per-type and after evaluation of functions.
  Glusterfs::Server::Brick <<| volume == "$name" |>>
  #TODO Test and make sure this doesn't break anything
  #Glusterfs::Server::Brick <<| volume == "$name" |>> {
    #before => Glusterfs::Server::Volume::Assemble[$name],
  #}
  glusterfs::server::volume::assemble { $name:
    ensure         => $ensure,
    stripe         => $stripe,
    replica        => $replica,
    transport      => $transport,
    rebalance      => $rebalance,
    replace_bricks => $replace_bricks,
    remove_bricks  => $remove_bricks,
  }
}
define glusterfs::server::volume::assemble (
  $ensure = undef,
  $stripe = undef,
  $replica = undef,
  $transport = undef,
  $rebalance = undef,
  $replace_bricks = undef,
  $remove_bricks = undef,
  $nonfatal_resize_mismatch = undef,
) {
  $bricks = glusterfs_volume_bricks($name)
  #$bricks_string = join($bricks, ',')
  #notify { "GLUSTERFS VOLUME ${name}: stripe=${stripe}; replica=${replica}; transport=${transport}; bricks=${bricks_string};": }
  glusterfs_volume { $name:
    ensure         => $ensure,
    stripe         => $stripe,
    replica        => $replica,
    transport      => $transport,
    rebalance      => $rebalance,
    replace_bricks => $replace_bricks,
    remove_bricks  => $remove_bricks,
    bricks         => shuffle($bricks),
  }
}
