GlusterFS
  - http://www.cloudcomp.ch/2013/08/distributed-file-system-series-glusterfs-introduction/

  - clustered network filesystem that uses FUSE


Concepts:
  - Volume: is a collection of one or more bricks

    Distribute Volume
      data is distributed through all the bricks
      based an algorithm, that considers the available size in each brick

    Replicate Volume
      data is duplicated over every brick in volume
      number of bricks -> multiple of the replica count

    Stripe Volume
      data is striped into a units of given size among bricks


  - Translator

    Storage Translators
      POSIX
      BDB (Berkeley DB)

    Clustering Translators
      Unify
        all subvolumes appear as single volume
      Distribute
        aggregate storage from several storage servers
      Replicate
        replicates files across subvolumes, a copy for each subvolume
      Stripe
        the content of a file is distributed across subvolumes

    Performance Translators
      Read Ahead
        prefetches data
      Write Behind
        allows write operations to return, even if operation has not completed
      Booster
        skip FUSE and access GlusterFS directly


