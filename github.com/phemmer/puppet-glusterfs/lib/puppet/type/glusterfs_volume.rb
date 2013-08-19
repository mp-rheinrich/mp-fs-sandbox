require 'set'
Puppet::Type.newtype(:glusterfs_volume) do
	desc <<-EOT
		Creates a volume
	EOT

	autorequire(:service) do
		"glusterfs-server"
	end
	#autorequire(:glusterfs_peer) do
		#[]
	#end

	#ensurable

	newparam(:name, :namevar => true) do
		desc "Name of the volume"
	end

	# stripe replica and transport are properties instead of params so that we can spit out a warning if they change. Though I suppose we could do this as a param with #validate as well, maybe. Can you reference `provider` in the #validate block of a param or is the #validate evaluated at catalog compile time?
	newproperty(:stripe) do
		desc "Stripe count"
		defaultto 1

		munge do |value|
			value.to_i
		end

		validate do |value|
			if value.to_i.to_s != value.to_s then
				raise(ArgumentError, "Invalid value for 'stripe' parameter: #{value} is not an integer")
			end
		end
	end

	newproperty(:replica) do
		desc "Replica count"
		defaultto 1

		munge do |value|
			value.to_i
		end

		validate do |value|
			if value.to_i.to_s != value.to_s then
				raise(ArgumentError, "Invalid value for 'replica' parameter: #{value} is not an integer")
			end
		end
	end

	newproperty(:transport, :array_matching => :all) do
		desc "Transport protocol"
		newvalues(:tcp, :rdma)
		defaultto :tcp

		munge do |value|
			value.to_sym
		end

		#validate do |value|
		#end
	end

	newproperty(:bricks, :array_matching => :all) do
		desc "Bricks in the volume"

		def should
			@should.uniq
		end
		def insync?(current)
			# this really is a set, not an array, but if we convert it to a set with #should, then puppet prints out a object reference instead of a human parsable value :-(
			(current - @should).length == 0 and (@should - current).length == 0
		end
	end

	ensurable do
		desc "Ensure stopped or running"

		newvalue(:started) do
			provider.start
		end
		newvalue(:stopped) do
			provider.stop
		end
		newvalue(:absent) do
			provider.delete
		end

		aliasvalue(:false, :absent)
		aliasvalue(:true, :started)
		aliasvalue(:removed, :absent)
		aliasvalue(:running, :started)
		aliasvalue(:present, :started)

		def retrieve
			provider.status
		end
	end

	newparam(:remove_bricks, :boolean => true) do
		desc "Whether to remove bricks from the volume that are not in the 'bricks' property. IMPORTANT while this will keep the resource from inadvertenly removing bricks, doing so will also prevent a rebalance from occuring and thus re-protecting data at the configured replica count."

		newvalues(:true, :false)
		defaultto(:false)
	end

	newparam(:replace_bricks, :boolean => true) do
		desc "Whether to perform replace operations on bricks when one brick needs to be added and another brick removed. This requires that any new brick being added have the capacity to take the data from any brick being removed."
		
		newvalues(:true, :false)
		defaultto(:false)
	end

	newparam(:rebalance) do
		desc "Whether to automatically rebalance the volume when bricks are added or removed"

		newvalues(:true, :false, :expand, :shrink)
		aliasvalue(:add, :expand)
		aliasvalue(:delete, :shrink)
		aliasvalue(:remove, :shrink)
		
		defaultto(:true)
	end

	newparam(:nonfatal_resize_mismatch) do
		desc "Whether to consider it a warning instead of an error when the resource is given a number of bricks that is not a multiple of the stripe and replica count."

		newvalues(:true, :false)
		defaultto(:false)
	end

	#validate do
	#end
end
