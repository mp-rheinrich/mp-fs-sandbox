This module supports 2 usage modes. Manual configuration, and exported resource collection.
In manual configuration you explicitly use the provided types to configure and build the glusterfs pool. In exported resource collection you set up a single node, and the other nodes will automatically join that node into the cluster via puppet's exported/collected resources.

# Manual configuration usage
*TODO*


# Exported resouces usage

### Class[glusterfs::server]:
	$cluster_name = 'gluster' # A tag shared by all members of this glusterfs pool. All nodes which share the same $cluster_name will use eachother as peers.

	$address = $::ipaddress # The ip address for other cluster peers to use to talk to this node.

	$firewall = false # whether to use the puppetlabs-firewall module to open up access to glusterfs from other peers.


### Glusterfs::Server::Volume[]:
	$ensure = 'running' # {'running'|'stopped'|'absent'}

	$stripe = 1 # Stripe count

	$replica = 1 # Replica count

	$transport = 'tcp' # {'tcp'|'rdma'} Transport protocol

	$rebalance = true # {true|false} Whether to automatically rebalance the volume when bricks are added/removed

	$replace_bricks = false # {true|false} Whether to automatically perform replace operations on bricks when we have bricks being both added and removed at the same time

	$remove_bricks = false # {true|false} Whether to automatically remove bricks from the volume that are not configured in puppet (eg: when nodes have been removed)

	$nonfatal_resize_mismatch = false # {true|false} Whether to consider it a warning instead of an error when the number of bricks is not a multiple of `stripe`*`replica`.


### Glusterfs::Server::Brick[]:
	$volume # The name of the `Glusterfs::Server::Volume[]` which this brick should be a member of

	$host = $ipaddress # The hostname/ip of the node serving the brick

	$path = $name # The path to the brick



## Example usage (same configuration on 4 different servers):
```
class { 'glusterfs::server':
	cluster_name => 'group 1',
	firewall => true,
}
@@glusterfs::server::brick { "$::clientcert /exports/g1v1-brick1":
	volume => 'g1v1',
	path => '/exports/g1v1-brick1',
}
glusterfs::server::volume { 'g1v1':
	replica => 2,
   stripe => 2,
	replace_bricks => true,
	nonfatal_resize_mismatch => true,
}
```
