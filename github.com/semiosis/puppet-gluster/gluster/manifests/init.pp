class gluster {
    package {
        'glusterfs-client' :
            ensure => present,
            require => Package["nfs-common"] ;

        'nfs-common' :
            ensure => present ;
    }
    logstash::producer::logs {
        "gluster" :
            has_grok => true ;
    }
    file {
        "/etc/logrotate.d/glusterfs" :
            source => "puppet:///modules/gluster/logrotate" ;
    }
}
