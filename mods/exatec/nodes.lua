minetest.register_node("exatec:tube", {
	description = "Tube",
	tiles = {"exatec_glass.png"},
	drawtype="nodebox",
	paramtype = "light",
	sunlight_propagates=true,
	groups = {chappy=3,dig_immediate = 2,exatec_tube=1},
	node_box = {
		type = "connected",
		connect_left={-0.5, -0.25, -0.25, 0.25, 0.25, 0.25},
		connect_right={-0.25, -0.25, -0.25, 0.5, 0.25, 0.25},
		connect_front={-0.25, -0.25, -0.5, 0.25, 0.25, 0.25},
		connect_back={-0.25, -0.25, -0.25, 0.25, 0.25, 0.5},
		connect_bottom={-0.25, -0.5, -0.25, 0.25, 0.25, 0.25},
		connect_top={-0.25, -0.25, -0.25, 0.25, 0.5, 0.25},
		fixed = {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25},
	},
	connects_to={"group:exatec_tube","group:exatec_tube_connected"},
	exatec={
		test_input=function(pos,stack,opos)
			return true
		end,
		on_input=function(pos,stack,opos)
			minetest.add_entity(pos,"exatec:tubeitem"):get_luaentity():new_item(stack,opos)
		end
	},
})

minetest.register_node("exatec:tube_detector", {
	description = "Detector tube",
	tiles = {"exatec_glass.png^[colorize:#ffff00cc"},
	drawtype="nodebox",
	paramtype = "light",
	sunlight_propagates=true,
	groups = {chappy=3,dig_immediate = 2,exatec_tube=1,exatec_wire=1,exatec_wire_connected=1},
	node_box = {
		type = "connected",
		connect_left={-0.5, -0.25, -0.25, 0.25, 0.25, 0.25},
		connect_right={-0.25, -0.25, -0.25, 0.5, 0.25, 0.25},
		connect_front={-0.25, -0.25, -0.5, 0.25, 0.25, 0.25},
		connect_back={-0.25, -0.25, -0.25, 0.25, 0.25, 0.5},
		connect_bottom={-0.25, -0.5, -0.25, 0.25, 0.25, 0.25},
		connect_top={-0.25, -0.25, -0.25, 0.25, 0.5, 0.25},
		fixed = {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25},
	},
	connects_to={"group:exatec_tube","group:exatec_tube_connected","group:exatec_wire",},
	exatec={
		test_input=function(pos,stack,opos)
			return true
		end,
		on_input=function(pos,stack,opos)
			minetest.add_entity(pos,"exatec:tubeitem"):get_luaentity():new_item(stack,opos)
		end,
		on_tube=function(pos,stack,opos)
			exatec.send(pos)
		end,
	},
})

minetest.register_node("exatec:tube_gate", {
	description = "Gate tube",
	tiles = {"exatec_glass.png^[colorize:#00ff00cc"},
	drawtype="nodebox",
	paramtype = "light",
	sunlight_propagates=true,
	groups = {chappy=3,dig_immediate = 2,exatec_tube=1,exatec_wire_connected=1},
	node_box = {
		type = "connected",
		connect_left={-0.5, -0.25, -0.25, 0.25, 0.25, 0.25},
		connect_right={-0.25, -0.25, -0.25, 0.5, 0.25, 0.25},
		connect_front={-0.25, -0.25, -0.5, 0.25, 0.25, 0.25},
		connect_back={-0.25, -0.25, -0.25, 0.25, 0.25, 0.5},
		connect_bottom={-0.25, -0.5, -0.25, 0.25, 0.25, 0.25},
		connect_top={-0.25, -0.25, -0.25, 0.25, 0.5, 0.25},
		fixed = {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25},
	},
	connects_to={"group:exatec_tube","group:exatec_tube_connected","group:exatec_wire"},
	on_construct=function(pos)
		minetest.get_meta(pos):set_string("infotext","Storage: closed")
	end,
	exatec={
		test_input=function(pos,stack,opos)
			return minetest.get_meta(pos):get_int("open") == 1
		end,
		on_input=function(pos,stack,opos)
			minetest.add_entity(pos,"exatec:tubeitem"):get_luaentity():new_item(stack,opos)
		end,
		on_wire = function(pos)
			local m = minetest.get_meta(pos)
			local open = m:get_int("open") == 1 and 0 or 1
			m:set_int("open",open)
			m:set_string("infotext","Storage: " .. (open == 1 and "open" or "closed"))
		end,
	},
})

minetest.register_node("exatec:wire", {
	description = "Wire",
	tiles = {{name="default_cloud.png"}},
	wield_image="exatec_wire.png",
	inventory_image="exatec_wire.png",
	drop="exatec:wire",
	drawtype="nodebox",
	paramtype = "light",
	paramtype2="colorwallmounted",
	palette="default_palette.png",
	sunlight_propagates=true,
	walkable=false,
	node_box = {
		type = "connected",
		connect_back={-0.05,-0.5,0, 0.05,-0.45,0.5},
		connect_front={-0.05,-0.5,-0.5, 0.05,-0.45,0},
		connect_left={-0.5,-0.5,-0.05, 0.05,-0.45,0.05},
		connect_right={0,-0.5,-0.05, 0.5,-0.45,0.05},
		connect_top = {-0.05, -0.5, -0.05, 0.05, 0.5, 0.05},
		fixed = {-0.05, -0.5, -0.05, 0.05, -0.45, 0.05},
	},
	selection_box={type="fixed",fixed={-0.5,-0.5,-0.5,0.5,0.5,-0.4}},
	connects_to={"group:exatec_wire","group:exatec_wire_connected"},
	groups = {dig_immediate = 3,exatec_wire=1},
	after_place_node = function(pos, placer)
		minetest.set_node(pos,{name="exatec:wire",param2=98})
	end,
	on_timer = function (pos, elapsed)
		minetest.swap_node(pos,{name="exatec:wire",param2=98})
	end,
})

minetest.register_node("exatec:button", {
	description = "Button",
	tiles={"default_wood.png",},
	drawtype = "nodebox",
	node_box = {type = "fixed",fixed={-0.2, -0.5, -0.2, 0.2, -0.3, 0.2}},
	paramtype = "light",
	paramtype2 = "facedir",
	on_place = minetest.rotate_node,
	sounds = default.node_sound_wood_defaults(),
	groups = {chappy=3,dig_immediate = 2,exatec_wire_connected=1},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		exatec.send(pos)
	end,
})

minetest.register_node("exatec:autosender", {
	description = "Auto sender",
	tiles={"default_ironblock.png^materials_gear_metal.png"},
	paramtype2 = "facedir",
	sounds = default.node_sound_wood_defaults(),
	groups = {choppy=3,oddly_breakable_by_hand=3,exatec_wire_connected=1},
	exatec={
	},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local t = minetest.get_node_timer(pos)
		local m = minetest.get_meta(pos)
		if t:is_started() then
			t:stop()
			m:set_string("infotext","OFF")
		else
			t:start(1)
			m:set_string("infotext","ON")
		end
	end,
	on_timer = function (pos, elapsed)
		exatec.send(pos)
		return true
	end
})

minetest.register_node("exatec:autocrafter", {
	description = "Autocrafter",
	tiles={"default_ironblock.png^default_craftgreed.png"},
	groups = {choppy=3,oddly_breakable_by_hand=3,exatec_tube_connected=1,exatec_wire_connected=1},
	sounds = default.node_sound_wood_defaults(),
	on_construct=function(pos)
		local m = minetest.get_meta(pos)
		local item = m:get_string("item")
		if m:get_string("item") == "" then
			local inv = m:get_inventory()
			inv:set_size("input", 16)
			inv:set_size("output", 16)
			inv:set_size("craft", 9)
		end
		m:set_string("formspec",
			"size[8,11]" 
			.."listcolors[#77777777;#777777aa;#000000ff]"
			.."list[context;craft;2,0;3,3;]" 
			.."box[6,1;1,1;#666666]"
			..(item ~="" and "item_image[6,1;1,1;"..item.."]" or "")
			.."list[context;input;-0.2,3;4,4;]" 
			.."list[context;output;4.2,3;4,4;]" 
			.."label[0,2.5;Input]" 
			.."label[7,2.5;Output]" 
			.."list[current_player;main;0,7.1;8,4;]" 
			.."listring[current_player;main]" 
			.."listring[current_name;input]" 
			.."listring[current_name;output]" 
			.."listring[current_player;main]"

			.."listring[current_player;craft]"
			.."listring[current_player;main]"
		)
	end,
	exatec={
		input_list="input",
		output_list="output",
		on_wire = function(pos)
			local m = minetest.get_meta(pos)
			local inv = m:get_inventory()
			if m:get_string("item") ~= "" then
				local craft = minetest.get_craft_recipe(m:get_string("item"))
				if not (craft.items and craft.type == "normal") or not inv:room_for_item("output",ItemStack(m:get_string("item").." " .. m:get_string("count"))) then
					return
				end
				local list = {}
				for i,v in pairs(craft.items) do
					list[v] = (list[v] and list[v]+1) or 1
				end
				for i,v in pairs(list) do
					if i:sub(1,6) == "group:" then
						local it = 0
						local n = i:sub(7,-1)
						for i2,v2 in pairs(inv:get_list("input")) do
							if minetest.get_item_group(v2:get_name(),n) > 0 then
								it = it + v2:get_count()
								if it >= v then
									break
								end
							end
						end
						if it < v then
							return
						end
					elseif not inv:contains_item("input",ItemStack(i .." " .. v)) then
						return
					end
				end
				for i,v in pairs(list) do
					if i:sub(1,6) == "group:" then
						for i2,v2 in pairs(inv:get_list("input")) do
							if minetest.get_item_group(v2:get_name(),i:sub(7,-1)) > 0 then
								inv:remove_item("input",v2:get_name() .. " " .. v)
								break
							end
						end
					else
						inv:remove_item("input",ItemStack(i .." " .. v))
					end
				end
				inv:add_item("output",ItemStack(m:get_string("item").." " .. m:get_string("count")))
				return true
			end
		end,
	},
	set_craft_item=function(pos)
		local m = minetest.get_meta(pos)
		local inv = m:get_inventory()
		local craft = minetest.get_craft_result({method = "normal",width = 3, items = inv:get_list("craft")})
		m:set_string("item",craft.item:get_name())
		m:set_int("count",craft.item:get_count())
		minetest.registered_nodes["exatec:autocrafter"].on_construct(pos)
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		if listname == "craft" then
			minetest.registered_nodes["exatec:autocrafter"].set_craft_item(pos)
		end
		minetest.get_node_timer(pos):start(1)
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if to_list == "craft" or from_list == "craft" then
			minetest.registered_nodes["exatec:autocrafter"].set_craft_item(pos)
		end
		minetest.get_node_timer(pos):start(1)
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname == "craft" then
			minetest.registered_nodes["exatec:autocrafter"].set_craft_item(pos)
		end
		minetest.get_node_timer(pos):start(1)
	end,
	can_dig = function(pos, player)
		local inv = minetest.get_meta(pos):get_inventory()
		return inv:is_empty("input") and inv:is_empty("output") and inv:is_empty("craft")
	end,
})

minetest.register_node("exatec:extraction", {
	description = "Extraction",
	tiles={
		"default_ironblock.png",
		"default_ironblock.png",
		"default_ironblock.png^default_crafting_arrowright.png",
		"default_ironblock.png^default_crafting_arrowleft.png",
		"default_ironblock.png",
		"default_ironblock.png^materials_fanblade_metal.png^default_chest_top.png",
	},
	paramtype2 = "facedir",
	sounds = default.node_sound_wood_defaults(),
	groups = {choppy=3,oddly_breakable_by_hand=3,exatec_tube_connected=1,exatec_tube=1,exatec_wire_connected=1},
	exatec={
		on_wire = function(pos)
			local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
			local b = {x=pos.x-d.x,y=pos.y-d.y,z=pos.z-d.z}
			local b1 = exatec.def(b)
			if b1.output_list then
				local f = {x=pos.x+d.x,y=pos.y+d.y,z=pos.z+d.z}
				local f1 = exatec.def(f)
				for i,v in pairs(minetest.get_meta(b):get_inventory():get_list(b1.output_list)) do
					if v:get_name() ~= "" then
						local stack = ItemStack(v:get_name() .." " .. 1)
						if exatec.test_input(f,stack,pos) and exatec.test_output(b,stack,pos) then
							exatec.input(f,stack,pos)
							exatec.output(b,stack,pos)
							return true
						end
					end
				end
			end
		end,
		test_input=function(pos,stack,opos)
			local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
			local f = {x=pos.x+d.x,y=pos.y+d.y,z=pos.z+d.z}
			return exatec.test_input(f,stack,pos)
		end,
		on_input=function(pos,stack,opos)
			local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
			local f = {x=pos.x+d.x,y=pos.y+d.y,z=pos.z+d.z}
			if exatec.test_input(f,stack,pos) then
				exatec.input(f,stack,pos)
			end
		end,
	},
})

minetest.register_node("exatec:dump", {
	description = "Dump",
	tiles={
		"default_ironblock.png",
		"default_ironblock.png",
		"default_ironblock.png^default_crafting_arrowright.png",
		"default_ironblock.png^default_crafting_arrowleft.png",
		"default_ironblock.png",
		"default_ironblock.png^materials_fanblade_plastic.png^default_chest_top.png",
	},
	paramtype2 = "facedir",
	sounds = default.node_sound_wood_defaults(),
	groups = {choppy=3,oddly_breakable_by_hand=3,exatec_tube_connected=1,exatec_tube=1,exatec_wire_connected=1},
	exatec={
		on_wire = function(pos)
			local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
			local b = {x=pos.x-d.x,y=pos.y-d.y,z=pos.z-d.z}
			local b1 = exatec.def(b)
			if b1.output_list then
				local f = {x=pos.x+d.x,y=pos.y+d.y,z=pos.z+d.z}
				for i,v in pairs(minetest.get_meta(b):get_inventory():get_list(b1.output_list)) do
					if v:get_name() ~= "" then
						local stack = ItemStack(v:get_name() .." " .. 1)
						if exatec.test_output(b,stack,pos) then
							exatec.output(b,stack,pos)
							minetest.add_item(f,stack)
							return true
						end
					end
				end
			end
		end,
		test_input=function(pos,stack,opos)
			local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
			local f = {x=pos.x+d.x,y=pos.y+d.y,z=pos.z+d.z}
			return not exatec.getnodedefpos(f).walkable
		end,
		on_input=function(pos,stack,opos)
			local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
			local f = {x=pos.x+d.x,y=pos.y+d.y,z=pos.z+d.z}
			if not exatec.getnodedefpos(f).walkable then
				minetest.add_item(f,stack)
			end
		end,
	},
})

minetest.register_node("exatec:counter", {
	description = "Counter (click to change count)",
	tiles = {"default_ironblock.png^materials_gear_metal.png","default_ironblock.png"},
	groups = {chappy=3,dig_immediate = 2,exatec_wire_connected=1},
	sounds = default.node_sound_wood_defaults(),
	paramtype = "light",
	sunlight_propagates = true,
	drawtype="nodebox",
	node_box = {
	type="fixed",
	fixed={-0.5,-0.5,-0.5,0.5,-0.4,0.5}},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		if minetest.is_protected(pos, player:get_player_name())==false then
			local meta = minetest.get_meta(pos)
			local times=meta:get_int("times")+1
			if times >= 10 then
				times=1
			end
			meta:set_int("times",times)
			meta:set_string("infotext","Counter: "..times.." count: "..meta:get_int("count"))
		end
	end,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("times",1)
		meta:set_string("infotext","Counter: 0 count: 0")
	end,
	exatec={
		on_wire = function(pos)
			local meta = minetest.get_meta(pos)
			local c = meta:get_int("count")+1
			local times = meta:get_int("times")
			if c >= times then
				exatec.send(pos,true)
				c = 0
			end
			meta:set_int("count",c)
			meta:set_string("infotext","Counter: "..times.." count: "..c)
		end
	}
})
minetest.register_node("exatec:delayer", {
	description = "Delayer (Click to change time)",
	tiles = {"default_ironblock.png^clock.png^default_chest_top.png","default_ironblock.png","default_ironblock.png","default_ironblock.png","default_ironblock.png","default_ironblock.png"},
	groups = {dig_immediate = 2,exatec_wire_connected=1},
	sounds = default.node_sound_wood_defaults(),
	paramtype = "light",
	sunlight_propagates = true,
	drawtype="nodebox",
	node_box = {type="fixed",fixed={-0.5,-0.5,-0.5,0.5,-0.4,0.5}},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		if minetest.is_protected(pos, player:get_player_name())==false then
			local meta = minetest.get_meta(pos)
			local time=meta:get_int("time")
			time = time < 10 and time or 0
			meta:set_int("time",time+1)
			meta:set_string("infotext","Delayer (" .. (time+1) ..")")
		end
	end,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("time",1)
		meta:set_string("infotext","Delayer (1)")
	end,
	on_timer = function (pos, elapsed)
		minetest.get_meta(pos):set_int("case",0)
		exatec.send(pos,true)
	end,
	exatec={
		on_wire = function(pos)
			local meta = minetest.get_meta(pos)
			if meta:get_int("case") == 0 then
				meta:set_int("case",1)
				minetest.get_node_timer(pos):start(meta:get_int("time"))
			end
		end
	}
})

minetest.register_node("exatec:toggleable_storage", {
	description = "Toggleable storage",
	tiles={"default_wood.png^default_chest_top.png"},
	groups = {choppy=3,oddly_breakable_by_hand=3,exatec_tube_connected=1,exatec_wire_connected=1},
	sounds = default.node_sound_wood_defaults(),
	on_construct=function(pos)
		local m = minetest.get_meta(pos)
		m:get_inventory():set_size("main", 32)
		m:set_string("infotext","Storage: closed")
		m:set_string("formspec",
			"size[8,8]" ..
			"list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";main;0,0;8,4;]" ..
			"list[current_player;main;0,4.2;8,4;]" ..
			"listring[current_player;main]" ..
			"listring[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";main]"
		)
	end,
	exatec={
		input_list="main",
		output_list="main",
		on_wire = function(pos)
			local m = minetest.get_meta(pos)
			local open = m:get_int("open") == 1 and 0 or 1
			m:set_int("open",open)
			m:set_string("infotext","Storage: " .. (open == 1 and "open" or "closed"))
		end,
		test_input=function(pos,stack,opos)
			return minetest.get_meta(pos):get_int("open") == 1
		end,
	},
	can_dig = function(pos, player)
		local inv = minetest.get_meta(pos):get_inventory()
		return inv:is_empty("main")
	end,
})

minetest.register_node("exatec:wire_gate", {
	description = "Wire gate",
	tiles={
		"default_ironblock.png^default_crafting_arrowup.png",
		"default_ironblock.png",
		"default_ironblock.png",
		"default_ironblock.png",
		"default_ironblock.png",
		"default_ironblock.png",
	},
	groups = {dig_immediate = 2,exatec_wire_connected=1},
	sounds = default.node_sound_wood_defaults(),
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	drawtype="nodebox",
	node_box = {type="fixed",fixed={-0.5,-0.5,-0.5,0.5,-0.4,0.5}},
	exatec={
		on_wire = function(pos)
			local d = minetest.facedir_to_dir(minetest.get_node(pos).param2)
			exatec.send({x=pos.x+d.x,y=pos.y+d.y,z=pos.z+d.z},true)
		end,
	}
})