$fsid = '27d28faa-48ae-4356-a8e3-19d5b81e179e'
$monitor_key = 'AQD7kyJQQGoOBhAAqrPAqSopSwPrrfMMomzVdw=='
$journal_size_mb = 4096
$local_pool_prefix = "__"
$pg_num = 192

$partition_number = 3
$monitors_hostname = 'client,client3,client4'
$monitors_addr = '10.122.5.19,10.122.20.163,10.121.4.95'

Exec {
      path => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin'
}

include 'ceph::yum::ceph'
include 'ceph::package'
include 'ceph::conf'

$array_monitor = split($monitors_hostname, ',')


if $hostname in $array_monitor {
    ceph::mon {"${hostname}": }
}
ceph::storage {"${hostname}": }
