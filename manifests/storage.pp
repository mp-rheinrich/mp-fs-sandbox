
define ceph::storage (){
    include 'ceph::yum::ceph'
    include 'ceph::package'
    include 'ceph::conf'

    $local_pool_prefix = $::local_pool_prefix
    $local_pool_name = "${local_pool_prefix}${hostname}"
    $pg_num = $::pg_num

    $ceph_admin_key_fact = "ceph_admin_key"
    $key = inline_template('<%= scope.lookupvar(ceph_admin_key_fact) or "undefined" %>')
    if $key != "undefined" {
        exec { "ceph-key-client.admin" :
            command => "ceph-authtool /etc/ceph/ceph.client.admin.keyring \
            --create-keyring --name=client.admin \
            --add-key='${key}'",
            creates => '/etc/ceph/ceph.client.admin.keyring',
            require => Package['ceph'],
        }

        $array_device = split($blockdevices, ',')
        ceph::storage::osd { $array_device: }

        exec { "ceph-create-local-poll" :
            command => "ceph osd pool create $local_pool_name $pg_num $pg_num",
            unless  => "rados lspools | grep -sqw ${local_pool_name}",  # Why need add -w option? You need to think. Because hostnames are like.
            require => Exec['ceph-key-client.admin'],
        }
    }
}
