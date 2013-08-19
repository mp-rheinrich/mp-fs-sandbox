class resolv{
  exec{"/etc/resolv.conf":
    command => "echo 'search $::hostname' >> /etc/resolv.conf",
    unless => "cat /etc/resolv.conf|grep -v grep|grep $::hostname"
  }
}