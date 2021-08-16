local list_of_nodes = {}
minetest.after(1, function() -- Delay until all nodes are registered (mod loading complete)
	for name, def in pairs(minetest.registered_nodes) do
		if def
		and def.groups									-- Exclude nodes without a group, which usually means indestructible ones
		and def.groups.not_in_creative_inventory ~= 1	-- Exclude technical blocks.
		and def.groups.liquid == nil					-- This probably makes liquids unobtainable, but they update too easily and create massive messes.
		and not string.match(def.name, "stair")			-- Exclude stairs because it's a bit boring just having stair variants of nodes everywhere.
		and not string.match(def.name, "slab")			--		- | | -
		and not string.match(def.name, "fence")			--		- | | -
		and not string.match(def.name, "bed")			-- Tends to create a lot of ugly half-beds
		and not string.match(def.name, "door")			-- Exclude doors, but also fence gates and whatnot... Hopefully.
		then
			table.insert(list_of_nodes, name)
		end
	end
end)

local data = {}

if minetest.get_mapgen_setting('mg_name') == "singlenode" then
	minetest.register_on_generated(function(minp, maxp, blockseed)
		local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
		local area = VoxelArea:new{MinEdge = emin, MaxEdge = emax}
		vm:get_data(data)

		for z = 0, 79 do
			for y = 0, 79 do
				for x = 0, 79 do
					local pos = {
						x = minp.x + x,
						y = minp.y + y,
						z = minp.z + z
					}

					if (pos.x % 3 == 0) and (pos.y % 4 == 0) and (pos.z % 3 == 0) then
						data[area:index(pos.x, pos.y, pos.z)] = minetest.get_content_id(list_of_nodes[math.random(#list_of_nodes)])
					end
				end
			end
		end

		vm:set_data(data)
		vm:write_to_map()
	end)
end

minetest.register_on_newplayer(function(player)
	player:set_velocity({ x = 0, y = 0, z = 0 })
	player:set_pos({ x = 0, y = 0, z = 0 })
end)