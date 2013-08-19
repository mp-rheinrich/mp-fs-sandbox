
class ceph::conf (
    $fsid = $::fsid,
    $monitor_key = $::monitor_key,
    $monitors_hostname = $::monitors_hostname,
    $monitors_addr = $::monitors_addr,
    $journal_size_mb = $::journal_size_mb,
) {

    file {'/etc/ceph/ceph.conf':
        ensure   => file,
        mode     => 600,
        content => template('ceph/ceph.conf.erb'),
        #source   => "puppet:///ceph/ceph.conf",
        require  => Package['ceph'],
    }

    file {'/etc/ceph/ceph.mon.keyring':
        ensure  => file,
        mode    => 600,
        content => template('ceph/ceph.mon.keyring.erb'),
        #source   => "puppet:///ceph/ceph.mon.keyring",
        require => Package['ceph'],
    }
}
