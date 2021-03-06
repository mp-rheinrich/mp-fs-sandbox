class common{
  class{'basic':
    stage => first
  }

  # Wierd apt::ppa needs this declaration
  class { 'apt::update':}
  class { 'apt':}
  class { 'resolv':}
}

node "glusterserver1" {
  class{"common":}
  -> file{"/tmp/glusterserver1": ensure => present}
  -> class{"glusterfs":}
}

node "glusterserver2" {
  class{"common":}
  -> file{"/tmp/glusterserver2": ensure => present}
  -> class{"glusterfs":}
}

node /ceph-mon/ {
  class{"common":}
  include ceph
}

node /ceph-osd/ {
  class{"common":}
  include ceph
}

node /ceph-mds/{
  class{"common":}
  include ceph
}