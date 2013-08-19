Puppet::Type.type(:glusterfs_volume).provide(:gluster) do
	attr_accessor :status
	attr_accessor :current

	def initialize(resource)
		super

		@current = volume_list(resource[:name])[0]
		self.cleanup
	end

	def cleanup
		#TODO replace-brick commit
	end

	def volume_list(name)
		begin

		# we can't create the volume object initially because it has to have all the required parameters
		volume_hashes = []
		volume_hash = nil
		Puppet.debug "Glusterfs_volume: Executing `gluster volume info #{name}`"
		%x{gluster volume info #{name} 2>/dev/null}.split(/\n/).each do |line|
			if /^Volume Name: (.+)/.match(line) then
				volume_hash = {}
				volume_hashes.push(volume_hash)
				volume_hash[:name] = $1
				volume_hash[:bricks] = []
			elsif /^Type: (\S+)/.match(line) then
				volume_hash[:types] = $1.split(/-/).map{|t| t.sub(/^Replicate$/,'replica').downcase.to_sym}
			elsif /^Status: (\S+)/.match(line) then
				volume_hash[:running] = $1 == "Started" ? true : false
			elsif /^Transport-type: (\S+)/.match(line) then
				volume_hash[:transport] = $1.split(/,/).map {|value| value.to_sym}
			elsif /^Number of Bricks: (.+) =/.match(line) or /^Number of Bricks: (\d+)/.match(line) then
				# turns
				#  ['distributed','replica','stripe'] # from hash['types']
				#  [2,3,4]
				# into
				#  { 'distributed' => 2, 'replica' => 3, 'stripe' => 4 } # merge into hash
				multipliers = $1.split(/ x /).map { |value| value.to_i }
				volume_hash.merge!(Hash[volume_hash[:types].zip(multipliers)])
			elsif /^Brick\d+: (.+)/.match(line) then
				volume_hash[:bricks].push($1)
			end
		end
		Puppet.debug "Glusterfs_volume: hashes=#{volume_hashes.inspect}"

		volume_hashes
		rescue => err
			raise(Puppet::Error, "Glusterfs_volume: #{err.message}: #{err.backtrace}")
		end
	end
	#def ==(volume)
		#self.resource[:name] == volume.resource[:name] && \
			#self.resource[:transport] == volume.resource[:transport] && \
			#( self.resource[:bricks] - volume.resource[:bricks] ).length == 0
	#end

	def self.instances
		volume_list('all')
	end

	def exists?
		!@current.nil?
	end
	def running?
		self.exists? ? @current[:running] : false
	end
	def status
		if !self.exists? then
			:absent
		elsif self.running?
			:started
		else
			:stopped
		end
	end

	def rebalancing?
		Puppet.debug "Glusterfs_volume: Executing `gluster volume rebalance #{resource[:name]} status | grep 'in progress'`"
		cmdout = %x{gluster volume rebalance #{resource[:name]} status | grep 'in progress'}
		cmdstatus = $?

		cmdstatus == 0
	end

	def stripe
		@current.nil? ? 1 : (@current[:stripe] || 1)
	end
	def stripe=(stripe_new)
		raise(Puppet::Error, "Glusterfs_volume[#{resource[:name]}]: You cannot change the stripe count of an existing volume")
	end
	def replica
		@current.nil? ? 1 : (@current[:replica] || 1)
	end
	def replica=(replica_new)
		raise(Puppet::Error, "Glusterfs_volume[#{resource[:name]}]: You cannot change the replica count of an existing volume")
	end
	def transport
		@current.nil? ? nil : @current[:transport]
	end
	def transport=(transport_new)
		Puppet.debug "Glusterfs_volume: old_transport_type=#{self.transport.class}; new_transport_type=#{transport_new.class}"
		raise(Puppet::Error, "Glusterfs_volume[#{resource[:name]}]: You cannot change the transport of an existing volume") # 3.4 feature
	end

	def create
		#TODO handle race conditions with other puppet nodes
		begin
		cmd = ['gluster', 'volume', 'create', resource[:name]]

		if resource[:stripe] > 1 then
			cmd.push('stripe', resource[:stripe])
		end

		if resource[:replica] > 1 then
			cmd.push('replica', resource[:replica])
		end

		cmd.push('transport', resource[:transport].join(','))

		cmd.concat(resource[:bricks])
		
		Puppet.debug "Glusterfs_volume: Executing `#{cmd.join(' ')}`"
		cmdout = %x{#{cmd.join(' ')} 2>&1} # we have to do an ugly shell redirect because Open3#popen3 doesnt provide exit status
		cmdstatus = $?

		if cmdstatus != 0 then
			raise(Puppet::Error, "Glusterfs_volume[#{resource[:name]}]: Error creating volume: #{cmdout.gsub(/\n/, '; ')}")
		end
		rescue => err
			raise(Puppet::Error, "Glusterfs_volume: #{err.message}: #{err.backtrace}")
		end
	end

	#def destroy
		##TODO handle race conditions with other puppet nodes
		#begin
		#stop
		#Puppet.debug "Glusterfs_volume: Executing `echo y | gluster volume delete #{resource[:name]}`"
		#cmdout = %x{echo y | gluster volume delete #{resource[:name]} 2>&1}
		#cmdstatus = $?
#
		#if cmdstatus != 0 then
			#raise(Puppet::Error, "Glusterfs_volume[#{resource[:name]}]: Error deleting volume: #{cmdout.gsub(/\n/, '; ')}")
		#end
		#rescue => err
			#raise(Puppet::Error, "Glusterfs_volume: #{err.message}: #{err.backtrace}")
		#end
	#end

	def start
		#TODO handle race conditions with other puppet nodes
		begin
		if !self.exists? then
			self.create
		end
		if self.status != 'started' then
			Puppet.debug "Glusterfs_volume: Executing `gluster volume start #{resource[:name]}`"
			cmdout = %x{gluster volume start #{resource[:name]} 2>&1}
			cmdstatus = $?

			if cmdstatus != 0 then
				raise(Puppet::Error, "Glusterfs_volume[#{resource[:name]}]: Error starting volume: #{cmdout.gsub(/\n/, '; ')}")
			end
		end
		rescue => err
			raise(Puppet::Error, "Glusterfs_volume: #{err.message}: #{err.backtrace}")
		end
	end

	def stop
		#TODO handle race conditions with other puppet nodes
		begin
		if !self.exists? then
			self.create
		end
		if self.status != 'stopped' then
			Puppet.debug "Glusterfs_volume: Executing `echo y | gluster volume stop #{resource[:name]}`"
			cmdout = %x{echo y | gluster volume stop #{resource[:name]} 2>&1}
			cmdstatus = $?

			if cmdstatus != 0 then
				raise(Puppet::Error, "Glusterfs_volume[#{resource[:name]}]: Error stopping volume: #{cmdout.gsub(/\n/, '; ')}")
			end
		end
		rescue => err
			raise(Puppet::Error, "Glusterfs_volume: #{err.message}: #{err.backtrace}")
		end
	end

	def delete
		#TODO handle race conditions with other puppet nodes
		begin
		if self.exists? then
			if self.running? then
				self.stop
			end
			Puppet.debug "Glusterfs_volume: Executing `echo y | gluster volume delete #{resource[:name]}`"
			cmdout = %x{echo y | gluster volume delete #{resource[:name]} 2>&1}
			cmdstatus = $?

			if cmdstatus != 0 then
				raise(Puppet::Error, "Glusterfs_volume[#{resource[:name]}]: Error deleting volume: #{cmdout.gsub(/\n/, '; ')}")
			end
		end
		rescue err
			raise(Puppet::Error, "Glusterfs_volume: #{err.message}: #{err.backtrace}")
		end
	end

	def bricks
		self.exists? ? @current[:bricks] : []
	end
	def bricks=(bricks_new)
		begin
		#TODO handle race conditions where another node might remove/add the brick between when we checked present bricks and when we try to do the operation

		bricks_missing = bricks_new - self.bricks
		bricks_extra = self.bricks - bricks_new

		if bricks_missing.length > 0 then
			Puppet.debug "Glusterfs_volume: Executing `gluster volume add-brick #{resource[:name]} '#{bricks_missing.join("' '")}'`"
			cmdout = %x{gluster volume add-brick #{resource[:name]} '#{bricks_missing.join("' '")}' 2>&1}
			cmdstatus = $?

			if cmdstatus != 0 then
				raise(Puppet::Error, "Glusterfs_volume[#{resource[:name]}]: Error adding bricks: #{cmdout.gsub(/\n/, '; ')}")
			end
			#TODO if resource[:rebalance_expand]
			#TODO   rebalance(resource[:volume], resource[:rebalance_expand]) # have it cancel existing rebalance and start a new one. use the resource[:rebalance_expand] to determine rebalance type (:true or "fix-layout")
		end

		if resource[:replace_bricks] == true then
			while bricks_missing.length > 0 and bricks_extra.length > 0 do
				brick_old = bricks_extra.shift
				brick_new = bricks_missing.shift
				Puppet.debug "Glusterfs_volume: Executing `gluster volume replace-brick #{resource[:name]} '#{brick_old}' '#{brick_new}' start`"
				cmdout = %x{gluster volume replace-brick #{resource[:name]} '#{brick_old}' '#{brick_new}' start}
				cmdstatus = $?

				if cmdstatus != 0 then
					raise(Puppet::Error, "Glusterfs_volume[#{resource[:name]}]: Error replacing bricks: #{cmdout.gsub(/\n/, '; ')}")
				end
			end
		end

		if resource[:remove_bricks] == :true
			if bricks_extra.length > 0 then
				#TODO don't remove bricks if a rebalance is in progress
				Puppet.debug "Glusterfs_volume: Executing `echo y | gluster volume remove-brick #{resource[:name]} '#{bricks_extra.join("' '")}'`"
				cmdout = %x{echo y | gluster volume remove-brick #{resource[:name]} '#{bricks_extra.join("' '")}' 2>&1}
				cmdstatus = $?

				if cmdstatus != 0 then
					raise(Puppet::Error, "Glusterfs_volume[#{resource[:name]}]: Error deleting bricks: #{cmdout.gsub(/\n/, '; ')}")
				end

				#TODO if resource[:rebalance_shrink]
				#TODO   rebalance(resource[:volume], resource[:rebalance_shrink]
			end
		end

		if resource[:rebalance] == :true then
			Puppet.debug "Glusterfs_volume: Executing `gluster volume rebalance #{resource[:name]} migrate-data start`"
			cmdout = %x{gluster volume rebalance #{resource[:name]} migrate-data start}
			cmdstatus = $?

			if cmdstatus != 0 then
				raise(Puppet::Error, "Glusterfs_volume[#{resource[:name]}]: Error deleting bricks: #{cmdout.gsub(/\n/, '; ')}")
			end
		else
			Puppet.debug "Glusterfs_volume: Executing `gluster volume rebalance #{resource[:name]} fix-layout start`"
			cmdout = %x{gluster volume rebalance #{resource[:name]} fix-layout start}
			cmdstatus = $?

			if cmdstatus != 0 then
				raise(Puppet::Error, "Glusterfs_volume[#{resource[:name]}]: Error deleting bricks: #{cmdout.gsub(/\n/, '; ')}")
			end
		end

		rescue => err
			raise(Puppet::Error, "Glusterfs_volume: #{err.message}: #{err.backtrace}")
		end
	end

end
