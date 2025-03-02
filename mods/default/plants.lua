default.register_bush=function(def)
	local mod = minetest.get_current_modname() ..":"
	local name = def.name
	local nname = mod .. def.name .. "_bush_leaves"
	local max = def.max or 5
	local min = def.min or 3
	local mapgen = def.mapgen and table.copy(def.mapgen) or {}
	def.mapgen = nil
	def.max = nil
	def.min = nil

	def.description = def.description or			name .. " bush leaves"
	def.tiles = def.tiles or				{"default_leaves.png"}
	def.paramtype = def.paramtype or			"light"
	def.walkable = def.walkable or			false
	def.waving = def.waving or				1
	def.drawtype = def.drawtype or			"allfaces_optional"
	def.sunlight_propagates = def.sunlight_propagates or	true
	def.groups = def.groups or				{leaves=1,snappy=3,flammable=2}
	def.sounds = def.sounds or 				default.node_sound_leaves_defaults()
	def.drop = def.drop or 				{max_items = 1,items = {{items = {"default:stick"}, rarity = 10},{items = {nname}}}}
	minetest.register_node(nname, def)
	table.insert(default.registered_bushies,nname.."_spawner")
	minetest.register_node(nname.."_spawner",{
		groups = {on_load=1,not_in_craftguide=1,not_in_creative_inventory=1},
		drawtype = "airlike",
		paramtype = "light",
		sunlight_propagates = true,
		walkable=false,
		pointable=false,
		buildable_to = true,
		drop = "",
		on_construct=function(pos)
			minetest.registered_nodes[nname.."_spawner"].on_load(pos)
		end,
		on_load = function(pos)
			minetest.remove_node(pos)
			local rad = math.random(min,max)
			for y=-rad,rad,1 do
			for x=-rad,rad,1 do
			for z=-rad,rad,1 do
				local p={x=pos.x+x,y=pos.y+y,z=pos.z+z}
				local cc=vector.length(vector.new({x=x,y=y,z=z}))/rad
				if cc<=1 and default.defpos(p,"buildable_to") then
					minetest.set_node(p,{name=nname})
				end
			end
			end
			end
		end
	})

	mapgen.noise_params = mapgen.noise_params or			{}
	mapgen.noise_params.offset = mapgen.noise_params.offset or	0.0001
	mapgen.noise_params.scale = mapgen.noise_params.scale or		0.00004
	mapgen.noise_params.spread = mapgen.noise_params.spread or	{x = 250, y = 250, z = 250}
	mapgen.noise_params.seed = mapgen.noise_params.seed or		2
	mapgen.noise_params.octaves = mapgen.noise_params.octaves or	3
	mapgen.noise_params.persist = mapgen.noise_params.persist or	0.66

	if mapgen.biomes and mapgen.biomes[1] == "all" then
		mapgen.biomes = default.registered_bios_list
	end

	minetest.register_decoration({
		decoration = nname.."_spawner"	,
		deco_type = mapgen.deco_type or		"simple",
		place_on = mapgen.place_on or		{"default:dirt_with_grass"},
		sidelen = mapgen.sidelen or		16,
		noise_params = mapgen.noise_params,
		biomes = mapgen.biomes or		{"grass_land"},
		y_min = mapgen.y_min or		1,
		y_max = mapgen.y_max or		31000,
		flags = mapgen.flags or			"place_center_x, place_center_z",
	})

end

default.register_blockdetails=function(def)
	local mod = minetest.get_current_modname() ..":"
	local name = def.name

	def=def or {}
	def.node=def.node or {}
	def.ddef = def.ddef or {}
	def.node.block = def.node.block or "default:sand"
	def.node.description = def.node.description or "Sand with " ..name
	def.node.drawtype = def.node.drawtype or "mesh"
	def.node.mesh = def.node.mesh or "default_blockdetails.obj"
	def.node.tiles = def.node.tiles or {"default_sand.png","default_stick.png"}
	def.node.groups = def.node.groups or {crumbly=3,sand=1,falling_node=1,not_in_creative_inventory=1,not_in_craftguide=1}
	def.node.drowning = def.node.drowning or 1
	def.paramtype2 = def.paramtype2 or "facedir"
	def.node.after_destruct = def.node.block and function(pos)
		minetest.set_node(pos,{name=def.node.block})
	end or nil

	if def.item then
		def.node.drop=mod..name
	end

	minetest.register_node(mod.."blockdetails_"..name, def.node,mod..name)

	minetest.register_decoration({
		deco_type = "simple",
		place_on = def.ddef.place_on or def.node.block and {def.node.block} or "defaut:sand",
		sidelen = 16,
		noise_params = {
			offset = 0.001,
			scale = 0.002,
			spread = {x = 200, y = 200, z = 200},
			seed = def.ddef.seed,
			octaves = 3,
			persist = 0.6
		},
		y_min = def.ddef.y_min or -50,
		y_max = def.ddef.y_max or 0,
		decoration = mod.."blockdetails_"..name,
		spawn_by = def.ddef.spawn_by,
		place_offset_y = -1,
		flags = "force_placement",
	})

	if def.item then
		if def.item.type == "node" then
			def.item.description = def.item.description or def.name.upper(string.sub(def.name,1,1)) .. string.sub(def.name,2,string.len(def.name))
			def.item.inventory_image = def.item.inventory_image or def.node.tiles[2]
			def.item.wield_image = def.item.wield_image or def.node.tiles[2]
			def.item.tiles = def.item.tiles or {def.item.inventory_image,def.item.inventory_image,"default_air.png","default_air.png","default_air.png","default_air.png"}
			def.item.groups = def.item.groups or {dig_immediate=3,flammable=2,used_by_npc=2}
			def.item.sounds = def.item.sounds or default.node_sound_wood_defaults()
			def.item.drawtype = def.item.drawtype or "nodebox"
			def.item.node_box = def.item.node_box or {type="fixed",fixed={-0.5,-0.5,-0.5,0.5,-0.49,0.5}}
			def.item.paramtype2 = def.item.paramtype2 or "wallmounted"
			def.item.paramtype = def.item.paramtype or "light"
			def.item.sunlight_propagates = def.item.sunlight_propagates==true
			def.item.after_place_node = def.item.after_place_node or function(pos, placer, itemstack)
				minetest.rotate_node(itemstack,placer,{under=pos,above=pos})
			end
			minetest.register_node(mod..name, def.item)
		else
			def.item.description = def.item.description or def.name.upper(string.sub(def.name,1,1)) .. string.sub(def.name,2,string.len(def.name))
			def.item.inventory_image = def.item.inventory_image or def.node.tiles[2]
			minetest.register_craftitem(mod..name, def.item)
		end
	end
end

default.register_pebble=function(def)
	local mod = minetest.get_current_modname() ..":"
	local ddef = table.copy(def.decoration or {})
	local name = def.name
	local block = def.block

	def.decoration =			nil
	def.name =			nil
	def.block =			nil
	def.groups =			def.groups or			{}
	def.groups.dig_immediate =		def.groups.dig_immediate or		3
	def.description =			def.description or			string.gsub(name,"_"," ")
	def.tiles =			def.tiles or			{"default_stone.png"}
	def.sounds =			def.sounds or			default.node_sound_stone_defaults()
	def.drawtype =			def.drawtype or			"mesh"
	def.mesh =			def.mesh or			"default_pebble.obj"
	def.visual_scale =			0.3
	def.paramtype =			"light"
	def.paramtype2 =			"facedir"
	def.sunlight_propagates =		def.sunlight_propagates or		true
	def.collision_box = 			def.collision_box or {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.-0.25, 0.3}
	}
	def.selection_box = 		def.selection_box or {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.-0.25, 0.3}
	}

	minetest.register_node(mod.."pebble_" ..name, def)

	minetest.register_decoration({
		deco_type = "simple",
		place_on = ddef.place_on or {"group:soil","default:stone"},
		sidelen = 16,
		noise_params = {
			offset = ddef.offset or 0.002,
			scale = ddef.scale or 0.004,
			spread = ddef.spread or {x = 100, y = 100, z = 100},
			seed = ddef.seed,
			octaves = 3,
			persist = 0.6
		},
		y_min = ddef.y_min or -31000,
		y_max = ddef.y_max or 31000,
		decoration = mod.."pebble_" ..name,
		spawn_by = ddef.spawn_by,
		flags = ddef.flags or nil,
	})

	if block then
		local bdef = table.copy(def)

		bdef.mesh="default_blockpebble.obj"
		bdef.tiles[2] = bdef.tiles[2] or "default_sand.png"
		bdef.sunlight_propagates = false
		bdef.visual_scale = 1
		bdef.drop = mod.."pebble_" ..name
		bdef.groups.not_in_creative_inventory=1
		bdef.groups.not_in_craftguide=1

		bdef.collision_box = {
			type = "fixed",
			fixed = {{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},{-0.3, 0.5, -0.3, 0.3, 0.8, 0.3}}
		}
		bdef.selection_box = {
			type = "fixed",
			fixed = {{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},{-0.3, 0.5, -0.3, 0.3, 0.8, 0.3}}
		}
		bdef.after_destruct=function(pos)
			minetest.set_node(pos,{name=block})
		end
		minetest.register_node(mod.."pebbleblock_" ..name, bdef)
		minetest.register_decoration({
			deco_type = "simple",
			place_on = ddef.place_on or {block},
			sidelen = 16,
			noise_params = {
				offset = 0.002,
				scale = 0.004,
				spread = {x = 100, y = 100, z = 100},
				seed = ddef.seed,
				octaves = 3,
				persist = 0.6
			},
			y_min = ddef.y_min or -50,
			y_max = ddef.y_max or 0,
			decoration = mod.."pebbleblock_" ..name,
			spawn_by = ddef.spawn_by,
			place_offset_y = -1,
			flags = "force_placement",
		})
	end
end

default.register_plant=function(def)
	local mod = minetest.get_current_modname() ..":"
	local name = def.name.upper(string.sub(def.name,1,1)) .. string.sub(def.name,2,string.len(def.name))

	def = def or {}
	def.description = def.description or			string.gsub(name,"_"," ")
	def.drawtype = def.drawtype or			"plantlike"
	def.tiles = def.tiles or				{"default_leaves.png"}
	def.waving = def.waving or				1
	def.groups = def.groups or				{}
	def.groups.plant = def.groups.plant or			1
	def.groups.attached_node = def.groups.attached_node or	1
	def.groups.snappy = def.groups.snappy or		3

	def.groups.flammable = def.groups.flammable or		1

	def.sounds = def.sounds or 				default.node_sound_leaves_defaults()
	def.sunlight_propagates = def.sunlight_propagates or	true
	def.buildable_to = type(def.buildable_to) == "nil"
	def.floodable = def.floodable == true or def.floodable == nil
	def.paramtype = def.paramtype or			"light"
	def.walkable = def.walkable or			false
	def.selection_box = def.selection_box or		{type="fixed",fixed={-0.25,-0.5,-0.25,0.25,0.25,0.25}}
	def.dye_colors = def.dye_colors or			{palette=90}
	table.insert(default.registered_plants,mod .. def.name)
	minetest.register_node(mod .. def.name, def)

	if def.decoration == false then
		return
	end

	local ddef = table.copy(def.decoration or {})
	def.decoration = nil

	ddef.decoration = def.name
	ddef.deco_type = ddef.deco_type or			"simple"
	ddef.place_on = ddef.place_on or 			{"group:spreading_dirt_type"}
	ddef.sidelen = ddef.sidelen or				16
	ddef.biomes = ddef.biomes or				{"grass_land"}
	ddef.y_min = ddef.y_min or				1
	ddef.y_max = ddef.y_max or				31000
	ddef.height = ddef.height or				1
	ddef.height_max = ddef.height_max or			1
--	ddef.spawn_by = ddef.spawn_by or			"default:dirt_with_grass"
--	ddef.num_spawn_by = ddef.num_spawn_by or		1

	ddef.noise_params = ddef.noise_params or		{}
	ddef.noise_params.offset = ddef.noise_params.offset or	0.006	
	ddef.noise_params.scale = ddef.noise_params.scale or	 0.007	
	ddef.noise_params.spread = ddef.noise_params.spread or	{x = 150, y = 150, z = 150}	
	ddef.noise_params.seed = ddef.noise_params.seed or	2	
	ddef.noise_params.octaves = ddef.noise_params.octaves or	3	
	ddef.noise_params.persist = ddef.noise_params.persist or	0.2	

	if ddef.biomes and ddef.biomes[1] == "all" then
		ddef.biomes = default.registered_bios_list
	end
	minetest.register_decoration(ddef)
end

default.register_tree=function(def)

	if type(def.name) ~= "string" then
		error("name (string) required!")
	elseif def.sapling_place_schematic and type(def.sapling_place_schematic) ~= "function" then
		error("sapling_place_schematic (function) required!")
	elseif def.schematic and type(def.schematic) ~= "string" then
		error("schematic (string) required!")
	elseif def.schematics and type(def.schematics) ~= "table" then
		error("schematics (stable) required!")
	elseif def.schematic ~= false and not (def.schematic or def.schematics or def.schematic_spawner) then
		error("schematic (string) or schematics (table) or schematic_spawner (bool) required!")
	end

	local mod = minetest.get_current_modname() ..":"
	local name = def.name.upper(string.sub(def.name,1,1)) .. string.sub(def.name,2,string.len(def.name))
	local schematic = def.sapling_place_schematic
	local fruit_name

	if def.fruit then
		fruit_name = def.fruit.name or mod .. def.name
	end

-- tree

	def.tree = def.tree or					{}
	def.tree.tree = def.name
	def.tree.description = def.tree.description or			name .. " tree"
	def.tree.tiles = def.tree.tiles or				{"default_wood.png","default_wood.png","default_tree.png"}
	def.tree.paramtype2 = def.tree.paramtype2 or			"facedir"
	def.tree.on_place = def.tree.on_place or 			minetest.rotate_node
	def.tree.groups = def.tree.groups or				{tree=1,choppy=2,flammable=1}
	def.tree.sounds = def.tree.sounds or 				default.node_sound_wood_defaults()
	def.tree.on_construct = def.tree.on_construct or 			function(pos, placer)
									minetest.get_meta(pos):set_int("placed",1)
								end
	minetest.register_node(mod .. def.name .. "_tree", def.tree)

-- wood

	def.wood = def.wood or					{}
	def.wood.description = def.wood.description or			name .. " wood"
	def.wood.tiles = def.wood.tiles or				{"default_wood.png"}
	def.wood.groups = def.wood.groups or				{wood=1,choppy=3,flammable=2}
	def.wood.sounds = def.wood.sounds or 				default.node_sound_wood_defaults()
	def.wood.palette = "default_palette.png"
	def.wood.paramtype2 = "color"
	def.wood.on_punch=default.dye_coloring
	minetest.register_node(mod .. def.name .. "_wood", def.wood)
	minetest.register_craft({
		output=mod .. def.name .. "_wood 4",
		recipe={{mod .. def.name .. "_tree"}},
	})

-- stair
	def.stair = def.stair or {}
	def.stair.groups =  def.stair.groups or {wood=1,stair=1,choppy=3,flammable=2}

	minetest.register_node(mod .. def.name .. "_stair",{
		description = def.wood.description  .. " stair",
		tiles = def.wood.tiles,
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		groups = def.stair.groups,
		sounds = def.wood.sounds,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0},
				{-0.5, -0.5, 0, 0.5, 0.5, 0.5}
			}
		},
		on_place = minetest.rotate_node,

	})
	minetest.register_craft({
		output=mod .. def.name .. "_stair 3",
		recipe={
			{"",mod .. def.name .. "_wood"},
			{mod .. def.name .. "_wood",mod .. def.name .. "_wood"}
		},
	})


-- leaves

	def.leaves = def.leaves or					{}
	def.leaves.description = def.leaves.description or			name .. " leaves"
	def.leaves.tiles = def.leaves.tiles or				{"default_leaves.png"}
	def.leaves.paramtype = def.leaves.paramtype or			"light"
	def.leaves.waving = def.leaves.waving or			1
	def.leaves.drawtype = def.leaves.drawtype or			"allfaces_optional"
	def.leaves.sunlight_propagates = def.leaves.sunlight_propagates or	true
	def.leaves.groups = def.leaves.groups or			{leaves=1,snappy=3,leafdecay=5,flammable=2}
	def.leaves.sounds = def.leaves.sounds or 			default.node_sound_leaves_defaults()
	def.leaves.drop = def.leaves.drop or 				{max_items = 1,items = {{items = {mod .. def.name .. "_sapling"}, rarity = 25},{items = {"default:stick"}, rarity = 10},{items = {mod .. def.name .. "_leaves"}}}}
	minetest.register_node(mod .. def.name .. "_leaves", def.leaves)

-- sapling


	def.sapling = def.sapling or					{}

	if def.test then
		def.sapling.after_place_node=function(pos)
			minetest.get_node_timer(pos):start(1)
		end
	end

	def.sapling.description = def.sapling.description or		name .. "tree sapling"
	def.sapling.tiles = def.sapling.tiles or				{"default_stick.png"}
	def.sapling.inventory_image = def.sapling.inventory_image or	def.sapling.tiles[1]
	def.sapling.paramtype = def.sapling.paramtype or			"light"
	def.sapling.drawtype = def.sapling.drawtype or			"plantlike"
	def.sapling.sunlight_propagates = def.sapling.sunlight_propagates or	true
	def.sapling.groups = def.sapling.groups or			{sapling=1,dig_immediate=3,snappy=3,flammable=3,store=200}
	def.sapling.sounds = def.sapling.sounds or 			default.node_sound_leaves_defaults()
	def.sapling.attached_node = def.sapling.attached_node or		1
	def.sapling.walkable = def.sapling.walkable or			false
	def.sapling.after_place_node = def.sapling.after_place_node or function(pos, placer)
		if minetest.get_item_group(minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name,"soil") > 0 then
			local meta = minetest.get_meta(pos)
			meta:set_int("date",default.date("get"))
			meta:set_int("growtime",math.random(10,60))
			minetest.get_node_timer(pos):start(10)
		end
	end
	def.sapling.on_timer = def.sapling.on_timer or function (pos, elapsed)
		if minetest.get_item_group(minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name,"soil") > 0 and (minetest.get_node_light(pos,0.5) or 0) >= 13 then
			local meta = minetest.get_meta(pos)
			if default.date("m",meta:get_int("date")) >= meta:get_int("growtime") then
				local applm = math.random(5,20)
				minetest.remove_node(pos)
				schematic(pos)
				if fruit_name then
					for z=-3,3 do
					for x=-3,3 do
					for y=4,10 do
						local pos2 = {x=pos.x+x,y=pos.y+y,z=pos.z+z}
						if math.random(1,applm) == 1 and minetest.get_node(pos2).name == mod .. def.name .. "_leaves" then
							local meta = minetest.get_meta(pos2)
							minetest.set_node(pos2,{name="default:fruit_spawner"})
							meta:set_string("fruit",fruit_name)
							meta:set_int("date",default.date("get"))
							meta:set_int("growtime",math.random(1,30))
							minetest.get_node_timer(pos2):start(10)
						end
					end
					end
					end
				end
			end
			return true
		end
	end
	minetest.register_node(mod .. def.name .. "_sapling", def.sapling)
	table.insert(default.registered_trees,mod .. def.name .. "_sapling")
	if def.fruit then
		minetest.register_ore({
			ore_type = "scatter",
			ore = fruit_name,
			wherein= mod .. def.name .. "_leaves",
			clust_scarcity = 4 * 4 * 4,
			clust_num_ores = 2,
			clust_size = 3,
			y_min= 0,
			y_max= 200,
		})

		local fts = 0
		for _,i in pairs(def.fruit) do
			fts = fts + 1
			if fts > 1 then
				break
			end
		end

		if fts > 1 then
			default.register_eatable("node",fruit_name,(def.fruit.hp or 1),(def.fruit.gaps or 4),{
				wet = def.fruit.wet or 0,
				description = def.fruit.description or 			fruit_name,
				inventory_image = def.fruit.inventory_image or 		"default_apple.png",
				tiles = def.fruit.tiles or				{"default_apple.png"},
				dye_colors =  def.fruit.dye_colors,
				groups = def.fruit.groups or				{dig_immediate=3,leafdecay=5,snappy=3,flammable=3,attached_node=1},
				sounds = def.fruit.sounds or				default.node_sound_leaves_defaults(),
				drawtype = def.fruit.drawtype or			"plantlike",
				paramtype = def.fruit.paramtype or			"light",
				sunlight_propagates = def.fruit.sunlight_propagates or	true,
				walkable =def.fruit.walkable or				false,
				visual_scale = def.fruit.visual_scale or			0.5,
				selection_box = def.fruit.selection_box or		{type = "fixed",fixed={-0.1, -0.5, -0.1, 0.1, -0.1, 0.1}},
				after_place_node = def.fruit.after_place_node or		function(pos, placer)
											minetest.set_node(pos,{name=fruit_name,param2=1})
										end,
				after_dig_node = def.fruit.after_dig_node or		function(pos, oldnode, oldmetadata, digger)
											if oldnode.param2 == 0 then
												local meta = minetest.get_meta(pos)
												minetest.set_node(pos,{name="default:fruit_spawner"})
												meta:set_int("date",default.date("get"))
												meta:set_string("fruit",fruit_name)
												meta:set_int("growtime",math.random(1,30))
												minetest.get_node_timer(pos):start(10)
											end
										end,
			})
		end
	end

	if def.mapgen == nil or def.mapgen ~= false then
		def.mapgen = def.mapgen or						{}
		def.mapgen.noise_params = def.mapgen.noise_params or			{}
		def.mapgen.noise_params.offset = def.mapgen.noise_params.offset or	0.006
		def.mapgen.noise_params.scale = def.mapgen.noise_params.scale or		0.002
		def.mapgen.noise_params.spread = def.mapgen.noise_params.spread or	{x = 250, y = 250, z = 250}
		def.mapgen.noise_params.seed = def.mapgen.noise_params.seed or		2
		def.mapgen.noise_params.octaves = def.mapgen.noise_params.octaves or	3
		def.mapgen.noise_params.persist = def.mapgen.noise_params.persist or	0.66

		if def.mapgen.biomes and def.mapgen.biomes[1] == "all" then
			def.mapgen.biomes = default.registered_bios_list
		end
	end
	if def.schematic_spawner then
		minetest.register_node(mod .. def.name .. "_decoration_spawner", {
			tiles={"default_wood.png"},
			groups={decoration_spawner=1,not_in_creative_inventory=1},
			on_decoration_spawn = schematic
		})
		minetest.register_decoration({
			decoration = name .. "_decoration_spawner"	,
			deco_type = def.mapgen.deco_type or		"simple",
			place_on = def.mapgen.place_on or		{"default:dirt_with_grass"},
			sidelen = def.mapgen.sidelen or			16,
			noise_params = def.mapgen.noise_params	,
			biomes = def.mapgen.biomes or		{"grass_land"},
			y_min = def.mapgen.y_min or		1,
			y_max = def.mapgen.y_max or		31000,
			flags = def.mapgen.flags or			"place_center_x, place_center_z",
		})
	elseif def.schematic then
		minetest.register_decoration({
			deco_type = def.mapgen.deco_type or		"schematic",
			place_on = def.mapgen.place_on or		{"default:dirt_with_grass"},
			sidelen = def.mapgen.sidelen or			16,
			noise_params = def.mapgen.noise_params	,
			biomes = def.mapgen.biomes or		{"grass_land"},
			y_min = def.mapgen.y_min or		1,
			y_max = def.mapgen.y_max or		31000,
			schematic = def.schematic			,
			flags = def.mapgen.flags or			"place_center_x, place_center_z",
		})
	elseif def.schematics then
		for i,v in pairs(def.schematics) do
			minetest.register_decoration({
				deco_type = def.mapgen.deco_type or		"schematic",
				place_on = def.mapgen.place_on or		{"default:dirt_with_grass"},
				sidelen = def.mapgen.sidelen or			16,
				noise_params = def.mapgen.noise_params	,
				biomes = def.mapgen.biomes or		{"grass_land"},
				y_min = def.mapgen.y_min or		1,
				y_max = def.mapgen.y_max or		31000,
				schematic = v			,
				flags = def.mapgen.flags or			"place_center_x, place_center_z",
				rotation = "random",
			})
		end
	end

	if def.door then
		default.register_door({
			name=def.name .. "_wood_door",
			description = name .. " wood door",
			texture=def.wood.tiles[1],
			burnable = true,
			groups = type(def.door) == "table" and def.door.groups or nil,
			craft={
				{mod .. def.name .. "_wood",mod .. def.name .. "_wood",""},
				{mod .. def.name .. "_wood",mod .. def.name .. "_wood",""},
				{mod .. def.name .. "_wood",mod .. def.name .. "_wood",""},
			}
		})
	end
	if def.chair then
		default.register_chair({
			name = def.name .. "_wood",
			description = def.name .. " wood chair",
			burnable = true,
			groups = type(def.chair) == "table" and def.chair.groups or nil,
			texture =def.wood.tiles[1],
			craft={{"group:stick","",""},{mod .. def.name .. "_wood","",""},{"group:stick","",""}}
		})
	end
	if def.fence then
		default.register_fence({
			name = def.name .. "_wood",
			texture = def.wood.tiles[1],
			groups = type(def.fence) == "table" and def.fence.groups or nil,
			craft={
				{"group:stick","group:stick","group:stick"},
				{"group:stick",mod .. def.name .. "_wood","group:stick"}
			}
		})
	end
end

minetest.register_node("default:fruit_spawner", {
	groups = {not_in_creative_inventory=1},
	drop = "",
	drawtype = "airlike",
	paramtype = "light",
	pointable = false,
	sunlight_propagates = true,
	walkable = false,
	on_timer = function (pos, elapsed)
		local meta = minetest.get_meta(pos)
		if default.date("m",meta:get_int("date")) > meta:get_int("growtime") then
			if minetest.find_node_near(pos,1,"group:leaves") then
				minetest.set_node(pos,{name=meta:get_string("fruit"),param2=0})
			else
				minetest.remove_node(pos)
			end
		end
		return true
	end
})

minetest.register_lbm({
	name="default:decoration_spawner",
	nodenames={"group:decoration_spawner"},
	run_at_every_load =true,
	action=function(pos,node)
		minetest.registered_nodes[node.name].on_decoration_spawn(pos)
	end

})