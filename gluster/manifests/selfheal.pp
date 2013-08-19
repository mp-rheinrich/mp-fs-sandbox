class gluster::selfheal {
    define hourly ($mount_point,
        $bricks = "/bricks",
        $mmin = "-90",
        $max_jobs = "10") {
        $volume = $name
        file {
            "/etc/cron.hourly/${volume}-hourly-self-heal.sh" :
                content => template("gluster/hourly-self-heal.sh"),
                mode => 0755,
                require =>
                File["/var/tmp/${volume}-hourly-self-heal-find.sh"] ;

            "/var/tmp/${volume}-hourly-self-heal-find.sh" :
                content => template("gluster/hourly-self-heal-find.sh"),
                mode => 0755,
                require => Package["moreutils"] ;
        }
    }
    package {
        "moreutils" :
            ensure => present ;
    }
}
