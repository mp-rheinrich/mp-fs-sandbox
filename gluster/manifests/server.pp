class gluster::server inherits gluster {
    $blockdevprefix = "s"#   usually "s" but on EC2 it's "xv" as in /dev/xvde1
    nagios::target::nrpeservicecheck {
        "glusterd" :
            description => "Gluster Daemon",
            command => "check_procs -C glusterd -c 1:1" ;

        "glusterd_log" :
            description => "Gluster Daemon Log",
            command =>
            "check_log -F /var/log/glusterfs/etc-glusterfs-glusterd.vol.log -O /dev/null -q ' E '" ;
    }
    service {
        "glusterd" :
            enable => true,
            ensure => running,
            require => Package["glusterd"] ;
    }
    package {
        'glusterd' :
            ensure => present ;
    }
    file {
        "/bricks" :
            ensure => directory ;
    }
    define brick ($device,
        $type = 'ebs',
        $nag = true) {
        $nrpe_name = regsubst("${name}", "/", "_", 'G')
        $log_name = regsubst("${name}", "/bricks/", "")
        nagios::target::nrpeservicecheck {
            "disk${nrpe_name}" :
                description => "Disk ${name}",
                command => "check_disk -w 25% -c 15% -p ${name}" ;
        }
        if $nag {
            nagios::target::nrpeservicecheck {
                "proc${nrpe_name}" :
                    description => "Export ${name}",
                    command =>
                    "check_procs -C glusterfsd -a '--brick-name ${name}' -c 1:1" ;

                "log${nrpe_name}" :
                    description => "Log ${name}",
                    command =>
                    "check_log -F /var/log/glusterfs/bricks/bricks-${log_name}.log -O /dev/null -q '( E ).+^(result out of range)'" ;
            }
        }
        file {
            "${name}" :
                ensure => directory,
                require => File["/bricks"] ;
        }
        $mount_options = $type ? {
            "ephemeral" => "acl,noatime,nodiratime,bootwait",
            default => "acl,noatime,nodiratime"#ebs

        }
        mount {
            "${name}" :
                ensure => present,
                device => "/dev/${blockdevprefix}d${device}",
                options => $mount_options,
                fstype => "auto",
                dump => 0,
                pass => 2,
                remounts => true,
                require => File["${name}"]
        }
    }
}
