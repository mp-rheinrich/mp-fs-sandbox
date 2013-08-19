
define ceph::storage::osd(){
    include 'ceph::package'
    include 'ceph::conf'

    $part_name = "${name}${::partition_number}"
    $part_full_name = "/dev/${part_name}"

    exec {"mkfs_${part_name}":
        command => "mkfs.xfs -f -d agcount=${::processorcount} -l \
        size=1024m -n size=64k ${part_full_name}",
        unless => "xfs_admin -l ${part_full_name}",
        onlyif => "ls ${part_full_name}",
    }

    $blkid_uuid_fact = "blkid_uuid_${part_name}"
    notify { "BLKID FACT ${part_name}: ${blkid_uuid_fact}": }
    $blkid = inline_template('<%= scope.lookupvar(blkid_uuid_fact) or "undefined" %>')
    notify { "BLKID ${part_name}: ${blkid}": }

     if $blkid != 'undefined' {
        exec { "ceph_osd_create_${part_name}":
            command => "ceph osd create ${blkid}",
            unless  => "ceph osd dump | grep -sq ${blkid}",
            require => Exec['ceph-key-client.admin']
        }

        $osd_id_fact = "ceph_osd_id_${part_name}"
        notify { "OSD ID FACT ${part_name}: ${osd_id_fact}": }
        $osd_id = inline_template('<%= scope.lookupvar(osd_id_fact) or "undefined" %>')
        notify { "OSD ID ${part_name}: ${osd_id}": }

        if $osd_id != 'undefined' {
            file { "/var/lib/ceph/osd/ceph-${osd_id}": 
                ensure => directory,
            }

            mount { "/var/lib/ceph/osd/ceph-${osd_id}":
                ensure  => mounted,
                device  => "${part_full_name}",
                atboot  => true,
                fstype  => 'xfs',
                options => 'rw,noatime,inode64',
                pass    => 2,
                require => [
                    Exec["mkfs_${part_name}"],
                    File["/var/lib/ceph/osd/ceph-${osd_id}"],
                ],
            }

            exec { "ceph-osd-mkfs-${osd_id}": 
                command => "ceph-osd -c /etc/ceph/ceph.conf -i ${osd_id} \
                --mkfs  --mkkey  --osd-uuid ${blkid}",
                creates => "/var/lib/ceph/osd/ceph-${osd_id}/keyring",
                require => [
                    Mount["/var/lib/ceph/osd/ceph-${osd_id}"],
                    File['/etc/ceph/ceph.conf'],
                ],
            }

            exec { "ceph-osd-register-${osd_id}":
                command => "ceph auth add osd.${osd_id} \
                osd 'allow *' mon 'allow rwx' \
                -i /var/lib/ceph/osd/ceph-${osd_id}/keyring",
                unless  => "ls /var/lib/ceph/osd/ceph-${osd_id}/sysvinit",
                require => Exec["ceph-osd-mkfs-${osd_id}"],
            }

            file { "/var/lib/ceph/osd/ceph-${osd_id}/sysvinit": 
                ensure  => present,
                mode    => 0755,
                content => "Superwoman",
                require => Exec["ceph-osd-register-${osd_id}"],
            }

            service { "ceph-osd.${osd_id}":
                ensure  => running,
                start   => "service ceph start osd.${osd_id}",
                stop    => "service ceph stop osd.${osd_id}",
                status  => "service ceph status osd.${osd_id}",
                require => [
                    Exec["ceph-osd-register-${osd_id}"],
                    File["/var/lib/ceph/osd/ceph-${osd_id}/sysvinit"],
                ]
            }

        }
     }


}
