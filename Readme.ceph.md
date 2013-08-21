### Terminology
  - http://ceph.com/docs/next/glossary/


### Ceph innovations:
- CRUSH data placement algorithm
  - infrastructre aware and quickly adjusts to failures
  - data location is computed rather than looked up
  - enables clients to communicate directly with servers that store their data
  - enables clients to perform  parallel IO for greatly enhanced throughput
- Reliable Autonomic Distributed Object Storage
   - storage devises assume complete responsibility for data integrity
   - they operate independently, in parallel, without central choreography
   - very efficient, very fast, very scalable
CephFS Distributed MetaData Server
  - Highly scaleable to large number of active/active  metadata servers and high throughput
  - Highly reliable and available, with POSIX semantics and consistency guarantees
  - Has both a FUSE client and a client fully integrated into the LINUX kernel

Advanced Virtual Block Device
  - Enterprise storage capabilities from utility server hardware
  - Thin provisioned, Allocate-On-Write Snapshots, LUN cloning
  - in the Linux kernel and integrated with OpenStack components


### Tutorials:
  - http://pve.proxmox.com/wiki/Storage:_Ceph
  - Ceph Deploy:
    - [Installing ceph with ceph-deploy](http://dachary.org/?p=1971)
    - [deploying-ceph-with-ceph-deploy](http://ceph.com/howto/deploying-ceph-with-ceph-deploy/)
  - [RADOS object store and Ceph FS](http://www.admin-magazine.com/HPC/Articles/The-RADOS-Object-Store-and-Ceph-Filesystem/(language)/eng-US), [Part2](http://www.admin-magazine.com/HPC/Articles/RADOS-and-Ceph-Part-2), [Part3](http://www.admin-magazine.com/HPC/Articles/CephX-Encryption)
  - [Crash Course in Ceph](http://www.anchor.com.au/blog/2012/09/a-crash-course-in-ceph/)
  - [Deploying Ceph on EC2 with Juju](http://wiki.ceph.com/02Guides/Deploying_Ceph_with_Juju), [Juju charms](https://jujucharms.com/precise/ceph-14/#bws-readme)
  - [Operational FAQ](http://wiki.ceph.com/03FAQs/02Operations_FAQ)



### Videos:
  - [Linux - Ceph object storage block storage file system replication mass](http://www.youtube.com/watch?feature=player_detailpage&v=C3lxGuAWEWU&t=2385) -> with actual real expanations and a small workshop, starts at about 38 min.
  - [[Linux.conf.au 2013] - grand distributed storage debate glusterfs and Ceph](http://www.youtube.com/watch?v=JfRqpdgoiRQ)
  - [[Linux.conf.au 2013] - Ceph: Managing A Distributed Storage System At Scale](http://www.youtube.com/watch?v=90nvIlBqwXg)
  - [Scaling Storage to the Cloud and Beyond with Ceph, 2012.10](http://vimeo.com/50620695)
  - http://www.shainmiley.com/wordpress/2013/06/05/ceph-overview-with-videos/
  - [FLOSS Weekly 250: Ceph](http://www.podcast.tv/video-episodes/floss-weekly-250-ceph-22584995.html)
  - [Petabyte-Storage mit Ceph - Martin Gerhard Loschwitz](http://www.youtube.com/watch?v=E4yWs0EjkeQ), [Slides](http://www.heinlein-support.de/sites/default/files/slac-2013_storage-mit-ceph_vortrag.pdf)
  - [Ceph at Media Entertainment and Scientific Storage Meetup](http://www.youtube.com/watch?v=BBOBHMvKfyc), [Slides](http://www.slideshare.net/openstack/storing-vms-with-cinder-and-ceph-rbdpdf)

  --> big block devises: [](http://www.youtube.com/watch?feature=player_detailpage&v=BBOBHMvKfyc&t=1193)
    -> even without virtualization, use RBD as BIG DISK
    -> thin-provisioned, instantly available, 10 TB disk (e.g)
  - MDS want to have plenty of RAM


## Case Studies
  ###### With hardware specs and clear illustrations
  - [DreamObjects Case Study Webinar](http://www.youtube.com/watch?v=G4twIKkhWF0)
  - [Slides for DreamObjects](http://www.slideshare.net/Inktank_Ceph/20121102-dreamobjects)
  - [GoPC - upgrading Zimbra email storage to Ceph](http://www.graemespeak.com/2013/05/05/supercomputing-infrastructure-to-support-gopc-rainmaker-cloud/)


  - [CEPH STORAGE FOR DELL OPENSTACK VIRTUAL INFRASTRUCTURES](http://objects.dreamhost.com/inktank-dell/Ceph%20Storage%20for%20Dell%20OpenStack%20Virtual%20Infrastructures%20v0.7.pdf)
    - 5.1 Balance Hardware  Capabilities  (CPU, Memory, Disk, Network)

  - [Press](http://wiki.ceph.com/05Community/Press)


### Slides:
  - [The End of RAID as You Know It with Ceph Replication](http://public.brighttalk.com/resource/core/11549/raid_replication_webinar_slides_17677.pdf)
  - [Block Storage For VMs With Ceph](http://de.slideshare.net/xen_com_mgr/block-storage-for-vms-with-ceph)
  - [Ceph Intro and Architectural Overview by Ross Turk, 2013/05](http://www.slideshare.net/buildacloud/ceph-intro-and-architectural-overview-by-ross-turk)


## Further links for ceph administration:
  - http://docs.flexiant.com/display/DOCS/Integrating+Ceph+with+Flexiant+Cloud+Orchestrator


### recursive accounting
  - near real-time
  - snapshot arbitrary directories


### how do i deploy and manage this stuff?
  - allow mixed-version clusters
  - protocol feature bits, safe data type encoding


### Development
  - automatic build system, for all branches in git
  - easy to test new code, push hot-fixes



### Configuration
  --- MINIMIZE!
  - managed by PAXOS
  - cluster state is managed centrally by monitors
  - local data paths, logging and tuning options


### configuration options:
  - puppet/chef/juju
  - global synced config file (describes our complete cluster)


### provisioning:
  embrace dynamic nature of the cluster
  - disks, hosts, racks may come online at any time
  - anything may fail at any time

  identify minimal amount of central coordination
    - monitor cluster membership/quorum

  simple scriptable sequences
  provide hooks for external tools to do the rest


### Ceph deploy
  - new tool for standing up and managing clusters
  - ceph-deploy new monhost1 monhost2 monhost3
  - ceph-deploy mon monhost1
  - ceph-deploy mon monhost2
  - ceph-deploy mon monhost3
  - ceph-deploy osd host2:sdb:sdi
  - ceph-deploy osd host2:sdc:sdi
  - ceph -w
  - ceph-deploy osd host3:sdb:sdj



### Ceph disk management
  - label disks
    - GPT partition type (fixed uuid)
  - udev
    - generate event when disk is added, on boot
  - `ceph-disk-activate /dev/sdb`
    - instantiate a new Ceph OSD, as needed
    - (re)mount the disk in appropriate location (/var/lib/ceph/osd/NNN)
    - optionally adjust cluster metadata about disk location (h5ost, rack)
  - upstart, sysvinit, systemd, etc...
    - start the daemon
    - daemon joins the cluster, brings itself online

  --> NO MANUAL PER NODE CONFIGURATION!


## CEPH FS:
  - NEARLY awesome... (NOT ready for production.. )


## WHY:
  - limited options for scalable open source storage
  - proprietary solutions
    - expensive
    - don't scale well
    - marry hardware and software

## Recommendations:
  - run Ceph on top of raw disks! (no RAID!)
  - http://www.youtube.com/watch?feature=player_detailpage&v=JfRqpdgoiRQ&t=2055
  - disk: for data, SSD for journal.
     ->
    DIRTY LITTLE SECRET:
      - a single bug inside your software could erase your whole data set
  - http://ceph.com/docs/master/rados/configuration/filesystem-recommendations/

## ROADMAP:
  - http://www.inktank.com/about-inktank/roadmap/
  - http://ceph.com/docs/master/release-notes/


### Commercial Support

    - http://www.inktank.com/what-is-ceph/
    - http://www.inktank.com/webinars/
    - http://www.inktank.com/resources/
    - http://www.inktank.com/resource/type/videos/
    - http://www.inktank.com/wp-content/uploads/2013/07/Ceph_Overview_V5.2_interactive.pdf



### a summary for Ceph:
Ceph: Managing a Distributed Storage System at Scale, Sage Weil, Inktank
Summarized by David Klann (dklann@linux.com)
  Sage Weil wrote the Ceph distributed storage system and
  described it in this invited talk. Sage presented an articulate
  overview of Ceph and answered questions as if he wrote the
  software (see previous sentence).
  Weil began his talk with a very brief historical roundup of storage systems he called “the old reality”: directly attached storage,
  raw disks, RAID, network storage, and SAN. He quickly moved
  on to discuss new user demands including “cloud” storage and
  “big data” requirements. Requirements that include diverse use
  cases such as object storage, block device access, shared file systems, and structured data requirements. Scalability is also on
  the requirements list, including scale to exabytes on heterogeneous hardware with reliability and fault tolerance, and a “mish
  mash” of all the above technologies. And with all this comes a
  cost. Cost in terms of both time and dollars. Weil proceeded to
  describe these costs and then to describe Ceph itself.
  Ceph is a unified storage system that incorporates object, block,
  and file storage. On the Ceph architecture slide, Weil showed
  the distributed object store base he calls RADOS, for Reliable
  Autonomic Distributed Object Store. Above RADOS live the API
  libraries and other interfaces to the object store: LIBRADOS
  (with the expected array of language support); RADOSGW, a
  REST interface compatible with Amazon’s S3 and OpenStack’s
  Swift; RBD (RADOS block device), the distributed block device;
  and Ceph FS, a POSIX-compliant distributed file system with
  Linux, a kernel client as well as a user-space file system (with
  FUSE). Weil emphasized the distributed nature of the Ceph
  system noting that Ceph scales from a few to tens of thousands
  of machines and to exabytes of storage. Weil noted that Ceph is
  also fault tolerant, self-managing, and self-healing. He pointed
  out that the collection of Ceph tools is an “evolution of the UNIX
  philosophy” in that each tool (control command and daemon) is
  designed to perform one task and to do it well.
  Weil moved on to describe Ceph cluster deployment and management. He noted that the Ceph developers are working closely
  with the major Linux distributions to package the tool set for
  easy deployment. Ceph supports clusters with mixed versions of
  the code by checking program version numbers in regular internode communication. This facilitates rolling upgrades of individual cluster participants. The protocol also includes “feature
  bits,” which enable integration of bleeding edge cluster nodes for
  the purpose of testing new functionality.
  The Ceph configuration philosophy is to minimize local configuration. Options may be specified in configuration files and on the
  command line of the various tools.




Loud thinking...
  - because the CephFS implementation is not ready for prouduction, we should use Block Storage
    - By striping images across the cluster, Ceph improves read access performance for large block device images. - See more at: http://ceph.com/ceph-storage/block-storage/#sthash.kwkwlGt0.dpuf
    - bringing Ceph’s virtually unlimited storage to KVMs running on your Ceph clients. - See more at: http://ceph.com/ceph-storage/block-storage/#sthash.kwkwlGt0.dpuf
