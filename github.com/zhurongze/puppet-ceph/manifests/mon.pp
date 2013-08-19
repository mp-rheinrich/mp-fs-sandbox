
define ceph::mon(
    $monitor_addr = $ipaddress
){
    include 'ceph::yum::ceph'
    include 'ceph::package'
    include 'ceph::conf'

    notify { "I'm in ceph::mon = ${name}": }

    $mon_data_dir = "/var/lib/ceph/mon/ceph-${name}"

    file {"${mon_data_dir}":
        ensure  => 'directory',
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => Package['ceph'],
    }

    exec {'ceph-mon-mkfs':
        command => "ceph-mon --mkfs -i ${name} \
        --keyring /etc/ceph/ceph.mon.keyring \
        -c /etc/ceph/ceph.conf",
        creates => "${mon_data_dir}/keyring",
        require => [
            Package['ceph'],
            File["${mon_data_dir}"],
            File['/etc/ceph/ceph.mon.keyring'],
            File['/etc/ceph/ceph.conf'],
        ]
    }

    file {"${mon_data_dir}/sysvinit": 
        ensure  => present,
        mode    => 0755,
        content => "Superman",
        require => Exec['ceph-mon-mkfs'],
    }

    service {"ceph-mon.${name}":
        ensure  => running,
        start   => "service ceph start mon.${name}",
        stop    => "service ceph stop mon.${name}",
        status  => "service ceph status mon.${name}",
        require => [
            Exec['ceph-mon-mkfs'],
            File["${mon_data_dir}/sysvinit"],
        ]
    }
}
