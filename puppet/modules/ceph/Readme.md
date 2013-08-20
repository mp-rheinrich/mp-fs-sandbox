### simple Ceph module for Ubuntu


Terminology:
  - MON: Ceph Monitoring Daemon
  - MDS: Ceph Metadata Server Daemon
  - OSD: Ceph Object Storage Daemon


Installation on Ubuntu:
  - http://ceph.com/docs/next/install/debian/





### Installation + Configuration with Ceph Deploy


    ## Log in to any mds server, so you'll be able to issue commands
    ## create monitor daemons
    $ ceph-deploy mon create ceph-mon0 ceph-mon1


    ## Create OSD daemons
    ## ceph-deploy osd create HOST:DISK[:JOURNAL] [HOST:DISK[:JOURNAL] ...]
    $ ceph-deploy osd create ceph-osd0:/dev/sdb ceph-osd1:/dev/sdb


    ## Gather keys
    $ ceph-deploy gatherkeys ceph-mon0


    ## Activate OSD
    ## ceph-deploy osd activate HOST:DIR[:JOURNAL] [...]
    $ ceph-deploy osd activate ceph-osd0:/dev/sdb ceph-osd1:/dev/sdb
