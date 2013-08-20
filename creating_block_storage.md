
## calculate the number of placement groups
http://ceph.com/docs/next/rados/operations/placement-groups/
                (OSDs * 100)
  Total PGs = ------------
                Replicas

    in our case: (2 * 100)/3 = 67 -> use 70


First create a pool:
http://ceph.com/docs/next/rados/operations/pools/


   $ ceph osd pool create first-pool 70





http://ceph.com/docs/next/rbd/rados-rbd-cmds/


  $ rbd create first-block --size 4096 --pool first-pool



  $ rbd ls first-pool
  > first-block


  $ rbd --image first-block info









  rbd create foo --size 1024
  rbd create foo --size 1024 --pool first-pool


  rbd --image foo info

  rbd --image foo -p first-pool info



  rbd resize --image foo --size 2048