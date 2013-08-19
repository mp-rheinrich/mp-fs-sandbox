class ceph::yum::ceph (
    $release = 'cuttlefish'
) {

    notify {"ceph::yum::ceph": }
    yumrepo { 'ceph':
        descr    => "Ceph ${release} repository",
        baseurl  => "http://ceph.com/rpm-${release}/el6/x86_64/",
        gpgkey   => 'https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc',
        gpgcheck => 1,
        enabled  => 1,
        priority => 5,
        before   => Package['ceph'],
    }
}
