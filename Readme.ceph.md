### Terminology
  - http://ceph.com/docs/next/glossary/



### Tutorials:
  - http://pve.proxmox.com/wiki/Storage:_Ceph
  - Ceph Deploy:  [Installing ceph with ceph-deploy](http://dachary.org/?p=1971)
  - [RADOS object store and Ceph FS](http://www.admin-magazine.com/HPC/Articles/RADOS-and-Ceph-Part-2)


### Videos:

  - [[Linux.conf.au 2013] - grand distributed storage debate glusterfs and Ceph](http://www.youtube.com/watch?v=JfRqpdgoiRQ)
  - [[Linux.conf.au 2013] - Ceph: Managing A Distributed Storage System At Scale](http://www.youtube.com/watch?v=90nvIlBqwXg)


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


CRUSH algorithm:
  -

## Recommendations:
  - run Ceph on top of raw disks! (no RAID!)
  - http://www.youtube.com/watch?feature=player_detailpage&v=JfRqpdgoiRQ&t=2055
  - disk: for data, SSD for journal.
     ->
    DIRTY LITTLE SECRET:
      - a single bug inside your software could erase your whole data set

## ROADMAP:
  - http://www.inktank.com/about-inktank/roadmap/
  - http://ceph.com/docs/master/release-notes/


### Commercial Support

    - http://www.inktank.com/what-is-ceph/
    - http://www.inktank.com/webinars/
    - http://www.inktank.com/resources/
    - http://www.inktank.com/resource/type/videos/
    - http://www.inktank.com/wp-content/uploads/2013/07/Ceph_Overview_V5.2_interactive.pdf



### Slides:
  - [The End of RAID as You Know It with Ceph Replication](http://public.brighttalk.com/resource/core/11549/raid_replication_webinar_slides_17677.pdf)



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


