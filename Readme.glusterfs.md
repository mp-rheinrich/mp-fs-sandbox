## Glusterfs


## GLUSTER TERMS:
  - DAS - direct attached storage
  - JBOD - just a bunch of disks


## Basic Info
  - https://github.com/gluster/glusterfs


### Some links:

  - http://techcrunch.com/2012/06/28/anatomy-of-an-open-source-acquisition-from-glusterfs-to-red-hat-storage/
  - http://www.xsanity.com/forum/viewtopic.php?p=62373
  - http://blog.rimuhosting.com/2011/07/01/storage-clustering-part-2-glusterfs/
  - http://gluster.org/community/documentation//index.php/GlusterFS_cookbook
  - http://gluster.org/community/documentation/index.php/GlusterFS_Concepts
  - http://blip.tv/cloudstack/distributed-petabyte-scale-cloud-storage-with-gluster-5996312


    Presentations:
      - http://www.gluster.org/community/documentation/index.php/Presentations
      - [GlusterFS for Systemadmins (Dustin Black)](http://www.gluster.org/community/documentation/images/9/9e/Gluster_for_Sysadmins_Dustin_Black.pdf)
      - [Performance_in_a_Gluster_System](https://s3.amazonaws.com/aws001/guided_trek/Performance_in_a_Gluster_Systemv6F.pdf)
      - http://de.slideshare.net/Gluster/red-hat-storage-introduction-to-glusterfs
      - [Petascale Cloud Storage with GlusterFS](http://de.slideshare.net/xen_com_mgr/8-abp-seamlessscaleoutstorageforxenandopenstac)#
      - [Gluster for Geeks: Performance Tuning Tips & Tricks](http://de.slideshare.net/Gluster/gluster-for-geeks-performance-tuning-tips-tricks)


### Rather detailed critical reviews:
    - http://sysconfig.org.uk/2011/07/glusterfs-a-workhorse-that-needs-to-be-tamed/
    - http://www.gluster.org/community/documentation/index.php/Basic_Gluster_Troubleshooting




### Why GlusterFS would be most secure bet for Video Hosting?

  - Brightcove:
    - Media Serving
      massive video in multiple locations
      HD formats
      1 PB total capacity
      centralized management, one administrator to manage day-to-day operations
      higher reliability



### Pitfalls:
  Split-Brain Syndrome:
  client writes to multiple copies of files
  no automatic fix
    - admin has to remove the "BAD" copy
    trigger auto-healing after it
  can be avoided:
    Quorum Enforcement


### Measuring Pitfalls:
  http://www.gluster.org/2013/07/performance-measurement-pitfalls/


## VIDEOS:
  - [Demystifying Gluster - GlusterFS For SysAdmins](http://www.youtube.com/watch?v=HkBndZOcEA0)

