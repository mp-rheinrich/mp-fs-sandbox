class ceph::ceph_deploy{
  package{"ceph-deploy": ensure => installed}
  -> file{"/usr/share/pyshared/ceph_deploy/util/arg_validators.py":
    content => template("ceph/patches/arg_validators.py")
  }
}