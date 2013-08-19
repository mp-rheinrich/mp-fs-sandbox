class ceph::package (
    $package_ensure = 'present'
) {

    package { 'ceph':
        ensure  => $packaget_ensure,
    }

    package { 'xfsprogs':
        ensure => $packaget_ensure,
    }

    package { 'parted':
        ensure => $packaget_ensure,
    }

    file { '/var/lib/ceph/':
        ensure => directory,
        owner  => 'root',
        group  => 0,
        mode   => '0755',
    }

    file { '/var/run/ceph':
        ensure => directory,
        owner  => 'root',
        group  => 0,
        mode   => '0755',
    }

    file { '/var/lib/ceph/mon':
        ensure  => directory,
        owner   => 'root',
        group   => 0,
        mode    => '0755',
        require => File['/var/lib/ceph']
    }

    file { '/var/lib/ceph/osd':
        ensure  => directory,
        owner   => 'root',
        group   => 0,
        mode    => '0755',
        require => File['/var/lib/ceph']
    }

    file { '/var/lib/ceph/mds':
        ensure  => directory,
        owner   => 'root',
        group   => 0,
        mode    => '0755',
        require => File['/var/lib/ceph']
    }

    file { '/var/lib/ceph/tmp':
        ensure  => directory,
        owner   => 'root',
        group   => 0,
        mode    => '0755',
        require => File['/var/lib/ceph']
    }
}
