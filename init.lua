
if core.get_mapgen_setting('mg_name') ~= "singlenode" then
	error("Skygrid mod enabled, but not singlenode mapgen. Please disable this mod.")
end

local interval_x = core.settings:get("skygrid_interval_x") or 3
local interval_y = core.settings:get("skygrid_interval_y") or 4
local interval_z = core.settings:get("skygrid_interval_z") or 3

local list_of_nodes = {}
core.register_on_mods_loaded(function() -- Delay until all nodes are registered (mod loading complete)
	for name, def in pairs(core.registered_nodes) do
		if def
		and def.groups									-- Exclude nodes without a group, which usually means indestructible ones
		and def.groups.not_in_creative_inventory ~= 1	-- Exclude technical blocks.
		and def.groups.liquid == nil					-- This probably makes liquids unobtainable, but they update too easily and create massive messes.
		and not string.match(def.name, "stair")			-- Exclude stairs because it's a bit boring just having stair variants of nodes everywhere.
		and not string.match(def.name, "slab")			--		Same thing.
		and not string.match(def.name, "fence")			--		Same thing.
		and not string.match(def.name, "bed")			-- Tends to create a lot of ugly half-beds
		and not string.match(def.name, "door")			-- Exclude doors, but also fence gates and whatnot... Hopefully.
		then
			table.insert(list_of_nodes, name)
		end
	end
end)

-- Graciously borrowed from NodeCore
-- https://gitlab.com/sztest/nodecore/-/blob/master/mods/nc_api/util_misc.lua#L106-120
function seeded_rng(seed)
	seed = math.floor((seed - math.floor(seed)) * 2 ^ 32 - 2 ^ 31)
	local pcg = PcgRandom(seed)
	return function(a, b)
		if b then
			return pcg:next(a, b)
		elseif a then
			return pcg:next(1, a)
		end
		return (pcg:next() + 2 ^ 31) / 2 ^ 32
	end
end

local mapperlin
core.after(0, function()
	mapperlin = core.get_perlin(0, 1, 0, 1)
end)

local data = {}

core.register_on_generated(function(minp, maxp, blockseed)
	local t0 = os.clock()
	local vm, emin, emax = core.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge = emin, MaxEdge = emax}
	vm:get_data(data)

	local rng = seeded_rng(mapperlin:get_3d(minp))

	for z = minp.z, maxp.z do
		for y = minp.y, maxp.y do
			for x = minp.x, maxp.x do
				if (x % interval_x == 0) and (y % interval_y == 0) and (z % interval_z == 0) then
					data[area:index(x, y, z)] = core.get_content_id(list_of_nodes[rng(1, #list_of_nodes)])
				end
			end
		end
	end

	vm:set_data(data)
	vm:write_to_map()
end)

core.register_on_newplayer(function(player)
	player:set_velocity({ x = 0, y = 0, z = 0 })
	player:set_pos({ x = 0, y = 0.5, z = 0 })
end)
