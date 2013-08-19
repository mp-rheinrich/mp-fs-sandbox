class glusterfs{
  include glusterfs::packages
}


class glusterfs::packages{
  apt::ppa { 'ppa:semiosis/ubuntu-glusterfs-3.4': }
}


# class glusterfs::server{

# }


# class glusterfs::client{

# }


