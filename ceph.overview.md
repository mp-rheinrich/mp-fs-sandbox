


Basic terms:

  - OSD - Object Storage Devise
      - store data
      - handle replication/recovery/rebalancing
      - check other OSDs with heartbeat and send this info to Ceph Monitors


  - Monitors:
    - keeps the state of Ceph Cluster using maps
      - monitors map
      - OSDs map
      - CRUSH map
    - also keep history of each state changes in the cluster, called epoch

    - MDSs - Ceph Metadata Server
      - store metadata for the Ceph FileSystem clients
      - supports the basic POSIX commands like ls and find
      - provide meta-data high-availability and scalability (multiple active MDSs)



    ## Key Features
      - CRUSH
        Controlled Replication Under Scaleable Hashing
        pseudo random algorithm
        no central lookup table
        allows high degree of scaling
        uses intelligent data replication to guarantee resiliency


      Access Data through different interfaces:
        - Object Storage (RADOSGW)- RADOW Gateway
          - restful API (like S3/OpenStack Swift)
          - sits on top of Ceph Storage Cluster
          - has own user database, Auth, ACL
          - flat namespace

        - Block Devices - RBD (RADOS Block Devices)
          - resizeable, thin-provisioned block devices
          - striped across multiple OSDs for high performance
          - also provides Image Snapshotting and Snapshot layering, cloning of images
          - supports QEMU/KVM hypervisors

        - File System - CephFS
          - POSIX-complient file system on top of Ceph Storage Cluster
          - mount in Kernel or FUSE
          - stores metadata in MDS
          - stores data in OSD



