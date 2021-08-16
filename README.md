# Minetest Skygrid
Custom skygrid mapgen for Minetest.

As with all custom Lua mapgens, it overwrites the 'singlenode' mapgen. The nodes aren't randomized based on the seed, you will not get the same node results by using the same seed.

It generates a list of nodes from `minetest.registered_nodes`, so all mods and games should work with it, including its nodes into the list of potential nodes.