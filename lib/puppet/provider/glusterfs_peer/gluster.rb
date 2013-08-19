require 'puppet/parser/functions'
Puppet::Type.type(:glusterfs_peer).provide(:gluster) do
	def self.instances
		# method A
		# %x{gluster peer status}.split(/\n/).grep(/^Hostname: /).map{|line| /^Hostname: (\S+)/.match(line)[1]}

		# method B
		peers = []
		Puppet.debug "Glusterfs_peer: Executing `gluster peer status`"
		%x{gluster peer status}.split(/\n/).each do |line|
			if /^Hostname: (\S+)/.match(line) then
				peers.push($1)
			end
		end
		peers
	end
	def exists?
		is_local = resource.exported?
		is_present = is_local || self.class.instances.include?(resource[:host])
		if is_local then
			Puppet.debug "Glusterfs_peer[#{resource[:host]}] is local"
		elsif is_present
			Puppet.debug "Glusterfs_peer[#{resource[:host]}] is present"
		else
			Puppet.debug "Glusterfs_peer[#{resource[:host]}] is missing"
		end
		is_present
	end
	def create
		if !self.exists? then
			Puppet.debug "Glusterfs_peer: Executing `gluster peer probe #{resource[:host]}`"
			system("gluster", "peer", "probe", resource[:host])
		end
	end
	def destroy
		if self.exists? then
			Puppet.debug "Glusterfs_peer: Executing `gluster peer detach #{resource[:host]}`"
			system("gluster", "peer", "detach", resource[:host])
		end
	end
end
