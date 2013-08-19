# node default{
#   class{"glusterfs":}
# }


node "server1" {
  file{"/tmp/server1":}
}


node "server2" {
  file{"/tmp/server2":}
}