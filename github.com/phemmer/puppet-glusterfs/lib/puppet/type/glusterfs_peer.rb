Puppet::Type.newtype(:glusterfs_peer) do
	desc <<-EOT
		Creates a connection to a remote GlusterFS node
	EOT

	autorequire(:class) do
		['glusterfs::server']
	end

	ensurable do
		newvalue(:present) do
			provider.create
		end
		newvalue(:absent) do
			provider.destroy
		end
		defaultto :present
	end

	newparam(:host, :namevar => true) do
		desc "Peer host address (hostname or ip) to connect to"
	end

	#validate do
	#end
end
