class gluster::client inherits gluster {
    define volume ($mount_point,
        $volfile_server,
        $mounted) {
        $log_path_trim = regsubst("${mount_point}", "/", "")
        $log_path = regsubst("${log_path_trim}", "/", "-", "G")
        nagios::target::nrpeservicecheck {
            "disk_${name}" :
                description => "Disk ${name}",
                command => "check_disk -u GB -w 10 -c 8 -p ${mount_point}" ;

            "log_gluster_${name}" :
                description => "GlusterLog ${name}",
                command =>
                "check_log -F /var/log/glusterfs/${log_path}.log -O /dev/null -q ' E '" ;

            "proc_gluster_${name}" :
                description => "GlusterMount ${name}",
                command =>
                "check_procs -C glusterfs -a '--volfile-id=${name}' -c 1:1" ;
        }
        file {
            "${mount_point}" :
                ensure => directory,
                replace => false ;
        }
        mount {
            "${mount_point}" :
                device => "${volfile_server}:${name}",
                options => "nobootwait,noatime,nodiratime",
                fstype => "glusterfs",
                ensure => $mounted,
                pass => 0,
                dump => 0,
                remounts => false,
                require => [Package["glusterfs-client"],
                File["${mount_point}"]] ;
        }
    }
    define nfs ($mount_point,
        $volfile_server,
        $mounted) {
        nagios::target::nrpeservicecheck {
            "disk_${name}" :
                description => "Disk ${name}",
                command => "check_disk -u GB -w 10 -c 8 -p ${mount_point}" ;
        }
        file {
            "${mount_point}" :
                ensure => directory,
                replace => false ;
        }
        mount {
            "${mount_point}" :
                device => "${volfile_server}:/${name}",
                options => "tcp,vers=3,nobootwait,noatime,nodiratime",
                fstype => "nfs",
                ensure => $mounted,
                pass => 0,
                dump => 0,
                remounts => false,
                require => [Package["nfs-common"], File["${mount_point}"]] ;
        }
    }
}
