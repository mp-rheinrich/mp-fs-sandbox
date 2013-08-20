class ceph{
  class{"ceph::package_sources":}
}

class ceph::package_sources{
  exec{"add ceph key":
    command => "wget -q -O- 'https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc' | sudo apt-key add -",
    unless  => "apt-key list |grep Ceph"
  }

  -> exec{"apt-get update":
    command => "apt-get update && touch /var/tmp/ceph-apt-sources",
    unless  => "test -e  /var/tmp/ceph-apt-sources"
  }
}