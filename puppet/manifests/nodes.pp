class common{
  class{'basic':
    stage => first
  }

  # Wierd apt::ppa needs this declaration
  class { 'apt::update':}
  class { 'apt':}
  class { 'resolv':}
}

# node default{
#   #class{"glusterfs":}
# }

node "glusterserver1" {
  class{"common":}
  -> file{"/tmp/glusterserver1": ensure => present}
}

node "glusterserver2" {
  class{"common":}
  -> file{"/tmp/glusterserver2": ensure => present}
}