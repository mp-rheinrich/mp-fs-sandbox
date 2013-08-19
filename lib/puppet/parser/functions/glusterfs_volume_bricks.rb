module Puppet::Parser::Functions
	newfunction(:glusterfs_volume_bricks, :type => :rvalue) do |args|
		volume = args[0]
		bricks = []
		catalog.resource_keys.each do |type, name|
			if type == 'Glusterfs::Server::Brick' then
				brick = catalog.resource(type, name)
				bricks.push(brick) if volume.nil? or brick[:volume] == volume
			end
		end

		bricks.map {|brick| brick[:host] + ':' + brick[:path] }
	end
end
