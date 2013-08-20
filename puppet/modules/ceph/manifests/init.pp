class ceph{
  class{"ceph::package_sources":}
  -> class{"ceph::ssh_test_keys":}
}

class ceph::package_sources{
  exec{"add ceph key":
    command => "wget -q -O- 'https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc' | sudo apt-key add -",
    unless  => "apt-key list |grep Ceph"
  }

  -> exec{"add ceph source":
    command => "echo deb http://ceph.com/debian-dumpling/ $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/ceph.list",
    unless  => "test -e /etc/apt/sources.list.d/ceph.list"
  }

  -> exec{"apt-get update":
    command => "apt-get update && touch /var/tmp/ceph-apt-sources",
    unless  => "test -e  /var/tmp/ceph-apt-sources"
  }
}



class ceph::ssh_test_keys{
  file{"/root/.ssh": ensure => directory}
  -> file{"/root/.ssh/id_rsa":
    content => template("ceph/keys/id_rsa"),
    mode    => 0600,
  }

  -> file{"/root/.ssh/id_rsa.pub":
    content => template("ceph/keys/id_rsa.pub"),
    mode    => 0600,
  }
  -> file{"/root/.ssh/authorized_keys":
    content => template("ceph/keys/id_rsa.pub"),
    mode    => 0600,
  }

  -> file{"/root/.ssh/config":
    content => template("ceph/keys/config"),
    mode    => 0600,
  }

  ## /etc/ssh/sshd_config
  -> exec{"allow root and passwordless ssh":
    command => "sed 's/\PermitEmptyPasswords\s\+no/PermitEmptyPasswords yes/g' /etc/ssh/sshd_config|tee /etc/ssh/sshd_config && /etc/init.d/ssh restart",
    unless  => "grep -E  PermitEmptyPasswords\\s\+yes  /etc/ssh/sshd_config"
  }
}