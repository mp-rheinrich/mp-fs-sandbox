
require 'facter'
require 'timeout'

timeout = 3

Facter.add(:ceph_admin_key, :timeout => timeout) do
    setcode do
        Facter::Util::Resolution.exec("timeout #{timeout} ceph auth get-key client.admin \
                                      --name mon. \
                                      --keyring /etc/ceph/ceph.mon.keyring")
    end
end


begin
    Timeout::timeout(timeout) {
        ceph_osds = Hash.new
        ceph_osd_dump = Facter::Util::Resolution.exec("timeout #{timeout} \
        ceph osd dump \
        --name client.admin \
        --keyring /etc/ceph/ceph.client.admin.keyring")
        ceph_osd_dump and ceph_osd_dump.each_line do |line|
            if line =~ /^osd\.(\d+).* ([a-f0-9\-]+)$/
                ceph_osds[$2] = $1
            end
        end

        blkid = Facter::Util::Resolution.exec("blkid")
        blkid and blkid.each_line do |line|
            if line =~ /^\/dev\/(.+):.*UUID="([a-fA-F0-9\-]+)"/
                device = $1
                uuid = $2

                Facter.add("blkid_uuid_#{device}") do
                    setcode do
                        uuid
                    end
                end

                Facter.add("ceph_osd_id_#{device}") do
                    setcode do
                        ceph_osds[uuid]
                    end
                end
            end
        end
    }

rescue Timeout::Error
    Facter.warnonce('ceph command timeout in ceph_admin_key fact')
end



