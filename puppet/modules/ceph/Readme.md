### simple Ceph module for Ubuntu


Terminology:
  - MON: Ceph Monitoring Daemon
  - MDS: Ceph Metadata Server Daemon
  - OSD: Ceph Object Storage Daemon


Installation on Ubuntu:
  - http://ceph.com/docs/next/install/debian/


### Installation + Configuration with Ceph Deploy
    ## Log in to any mds server, so you'll be able to issue commands

    ## create the configs
    $ ceph-deploy new ceph-mon0 ceph-mon1

    ## create monitor daemons
    $ ceph-deploy mon create ceph-mon0 ceph-mon1

    ## Gather keys
    $ ceph-deploy gatherkeys ceph-mon0

    ## Create OSD daemons
    ## ceph-deploy osd create HOST:DISK[:JOURNAL] [HOST:DISK[:JOURNAL] ...]
    $ ceph-deploy osd create ceph-osd0:/dev/sdb ceph-osd1:/dev/sdb


    ## Activate OSD
    ## ceph-deploy osd activate HOST:DIR[:JOURNAL] [...]
    $ ceph-deploy osd activate ceph-osd0:/dev/sdb ceph-osd1:/dev/sdb



    ## Create MDS daemons
    ## ceph-deploy mds create {host-name}[:{daemon-name}] [{host-name}[:{daemon-name}] ...]
    $ ceph-deploy mds create ceph-mds0 ceph-mds1



    ## allow all to administrate
      ceph-deploy admin ceph-osd0
      ceph-deploy admin ceph-osd1
      ceph-deploy admin ceph-mon0
      ceph-deploy admin ceph-mon1
      ceph-deploy admin ceph-mds0
      ceph-deploy admin ceph-mds1



    ## Mounting FS
      $ mkdir -p /mnt/mycephfs
      ## plaintext secret
      $ mount.ceph ceph-mon0,ceph-mon1:/ /mnt/mycephfs -o name=admin,secret=AQC3aRNSWCvNDhAAm1iHcWooMldZHVcE4VLyhg==

      ## read it from keyring
      $ mount.ceph ceph-mon0,ceph-mon1:/ /mnt/mycephfs -o name=admin,secret=`cat /etc/ceph/ceph.client.admin.keyring|grep key| awk '{print $3}'`

