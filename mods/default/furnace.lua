default.furnace={}


default.get_fuel=function(stack)
	local time=minetest.get_craft_result({method="fuel", width=1, items={stack:get_name()}}).time
	if time==0 then
		time=minetest.get_item_group(stack:get_name(),"flammable")
	end
	if time==0 then
		time=minetest.get_item_group(stack:get_name(),"igniter")
	end
	if time==0 then
		time=minetest.get_item_group(stack:get_name(),"tempsurvive_add")
	end
	return time
end

minetest.register_node("default:furnace", {
	description = "Furnace",
	tiles = {"default_cobble.png","default_stone.png","default_stone.png"},
	groups = {stone=2,cracky=2},
	drawtype="mesh",
	mesh="default_furnace.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	sounds = default.node_sound_stone_defaults(),
	after_place_node = function(pos, placer, itemstack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("cook", 4)
		inv:set_size("fuel", 16)
		inv:set_size("fried", 4)
		meta:set_string("owner", placer:get_player_name())
		meta:set_string("infotext", " Furnace (inactive)")
		meta:set_string("formspec",
		"size[8,9]" ..
		"list[context;cook;1.5,0;2,2;]" ..
		"list[context;fried;4.5,0;2,2;]" ..
		"list[context;fuel;0,3;8,2;]" ..
		"image[3.5,1;1,1;default_fire_bg.png]" ..
		"list[current_player;main;0,5.3;8,4;]" ..
		"listring[current_player;main]" ..
		"listring[current_name;fuel]" .. 
		"listring[current_name;fried]" .. 
		"listring[current_name;cook]"
		)
		end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname=="cook" or (listname=="fuel" and default.get_fuel(stack)>0) then
			local meta = minetest.get_meta(pos)

			if listname=="cook" then
				local result,after=minetest.get_craft_result({method="cooking", width=1, items={stack}})
				if result.item:get_name()=="" then
					return 0
				end
			end

			local name = player:get_player_name()
			if name==meta:get_string("owner") or not minetest.is_protected(pos,name) then
				if meta:get_int("active")==0 then
					minetest.get_node_timer(pos):start(1)
				end
				return stack:get_count()
			end
		end
		return 0
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		local name = player:get_player_name()
		if name==meta:get_string("owner") or not minetest.is_protected(pos,name) then
			return stack:get_count()
		end
		return 0
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if from_list == to_list then
			return count
		end
		return 0
	end,
	can_dig = function(pos, player)
		local inv = minetest.get_meta(pos):get_inventory()
		return inv:is_empty("fuel") and inv:is_empty("fried") and inv:is_empty("cook")
	end,
	on_timer = function (pos, elapsed)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local fulltime = meta:get_int("fulltime")
		local burntime = meta:get_int("time") -1
		local newtime = 0
		local cook_slot = meta:get_int("cook_slot")
		local cooking_time = meta:get_int("cooking_time") -1
		local fuel_slot = math.random(1,16)
		local cook_stack = inv:get_stack("cook",cook_slot)
		local fuel_stack

		meta:set_int("time", burntime)
		meta:set_int("cooking_time",cooking_time)
--fuel slot

		if burntime <= 0 then
			local slots={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}
			for i=fuel_slot,fuel_slot+16 do
				fuel_slot=slots[i]
				fuel_stack=inv:get_stack("fuel",fuel_slot)
				if fuel_stack:get_count()>0 then
					newtime = default.get_fuel(fuel_stack)
					break
				end
			end
		end

--result





		if burntime > 0 or newtime > 0 then
			local result,after=minetest.get_craft_result({method="cooking", width=1, items={cook_stack}})
			local new_cook
			if inv:room_for_item("fried", result.item) then
-- new fuel
				if cooking_time >= 0 and burntime <= 0 then
					burntime = newtime
					fulltime = newtime
					meta:set_int("time", newtime)
					meta:set_int("fulltime", newtime)
					fuel_stack:take_item()
					inv:set_stack("fuel",fuel_slot,fuel_stack)
				end
-- done
				if cooking_time <= 0 and burntime >= 0 then
					inv:add_item("fried", result.item)
					cook_stack:take_item()
					inv:set_stack("cook",cook_slot,cook_stack)
					new_cook = true
				end
-- new cook
				if new_cook or (cooking_time <= 0 and burntime <= 0) then
					local slots = {1,2,3,4,1,2,3,4}
					cook_slot = math.random(1,4) 

					for i=cook_slot,cook_slot+4 do
						cook_slot = slots[i]
						cook_stack=inv:get_stack("cook",cook_slot)
						if cook_stack:get_count()>0 then
							cooking_time = result.time
							meta:set_int("cooking_time",cooking_time)
							meta:set_int("cooking_fulltime",cooking_time)
							meta:set_int("cook_slot",cook_slot)
							return true
						end
					end
				end
			end
		end
--formspec
		local label = ""

		if meta:get_int("cooking_fulltime") ~= 0 then
			label = "label[3.6,0.2;" .. (100 - math.floor(cooking_time / meta:get_int("cooking_fulltime") * 100)) .."%]"
		end

		meta:set_string("formspec",
		"size[8,9]" ..
		"list[context;cook;1.5,0;2,2;]" ..
		"list[context;fried;4.5,0;2,2;]" ..
		"list[context;fuel;0,3;8,2;]" ..
		 label ..
		"image[3.5,1;1,1;default_fire_bg.png^[lowpart:" .. math.floor(burntime / fulltime * 100) .. ":default_fire.png]" ..
		"list[current_player;main;0,5.3;8,4;]" ..
		"listring[current_player;main]" ..
		"listring[current_name;fuel]" .. 
		"listring[current_name;fried]" .. 
		"listring[current_name;cook]"
		)
		if burntime > 0 then
			return true
		else
			return false
		end
	end
})