bows={
	cluser=true,
	pvp=minetest.settings:get_bool("enable_pvp") or nil,
	nitroglycerin=minetest.get_modpath("nitroglycerin")~=nil,
	creative=minetest.settings:get_bool("creative_mode"),
	mesecons=minetest.get_modpath("mesecons"),
	registed_arrows={},
	registed_bows={},
}

bows.register_arrow=function(name,def)
	if name==nil or name=="" then return false end
	def.damage = def.damage or 1
	def.name = minetest.get_current_modname() ..":arrow_".. name
	def.on_hit_object = def.on_hit_object or bows.nothing
	def.on_hit_node = def.on_hit_node or bows.on_hit_node
	def.on_hit_sound= def.on_hit_sound or "default_dig_dig_immediate"
	def.on_step = def.on_step or bows.nothing
	def.groups = def.groups or {}
	def.groups.arrow = 1
	def.groups.treasure = def.groups.treasure or 1

	bows.registed_arrows[def.name]=def

	minetest.register_craftitem(def.name, {
		description = def.description or name,
		inventory_image = (def.texture and def.texture .. "^default_arrow.png^[makealpha:0,255,0") or def.inventory_image or "default_wood.png^default_arrow.png^[makealpha:0,255,0",
		groups = def.groups,
	})
	if def.craft then
		def.craft_count= def.craft_count or 4
		minetest.register_craft({
			output = def.name .." " .. def.craft_count,
			recipe = def.craft
		})
	end
end

bows.automode=function(itemstack, user, pointed_thing)
	local meta = itemstack:get_meta()
	local m = meta:get_int("automode") == 0 and 1 or 0
	meta:set_int("automode", m)
	minetest.chat_send_player(user:get_player_name(), "Auto find arrow "..(m == 0 and "disabled" or "enabled"))
	return itemstack
end

bows.register_bow=function(name,def)
	if name==nil or name=="" then return false end

	def.replace = minetest.get_current_modname()..":bow_" .. name .."_loaded"
	def.name = minetest.get_current_modname()..":bow_".. name
	def.uses = def.uses-1 or 49
	def.shots = def.shots or 1
	def.level = def.level or 1
	def.autoaim = def.autoaim == true

	def.texture = def.texture or "default_wood.png"
	def.groups = def.groups or {}
	def.groups.bow = 1
	def.groups.treasure = def.groups.treasure or 1

	bows.registed_bows[def.replace]=def

	minetest.register_tool(def.name, {
		description = (def.description or name) .." (level ".. def.level .. (def.shots > 1 and ", shots ".. def.shots or "") .. (def.autoaim and ", autoaim" or "") ..")",
		inventory_image = def.texture .. "^default_bow.png^[makealpha:0,255,0",
		on_use =bows.load,
		on_place = bows.automode,
		groups = def.groups,
		wield_scale={x=2,y=2,z=1}
	})
	minetest.register_tool(def.replace, {
		description = (def.description or name) .." (level ".. def.level .. (def.shots > 1 and ", shots ".. def.shots or "") .. (def.autoaim and ", autoaim" or "") ..")",
		inventory_image = def.texture .. (def.shots == 1 and "^default_bow_loaded.png" or "^default_bow_loaded_multi.png") .. "^[makealpha:0,255,0",
		on_use =bows.shoot,
		on_place = bows.automode,
		groups = {bow=1,not_in_creative_inventory=1},
		wield_scale={x=2,y=2,z=1}
	})
	if def.craft then
		minetest.register_craft({output = def.name,recipe = def.craft})
	end
	def.craft=nil
end

bows.load=function(itemstack, user, pointed_thing)
	local inv=user:get_inventory()
	local meta = itemstack:get_meta()
	local shots = bows.registed_bows[itemstack:get_name() .. "_loaded"].shots
	local index
	local arrow

	if meta:get_int("automode") == 1 then
		for i,v in pairs(inv:get_list("main")) do
			if minetest.get_item_group(v:get_name(), "arrow") > 0 then
				index = i
				break
			end
		end
		if not index then
			return itemstack
		else
			arrow = inv:get_stack("main", index)
		end
	else
		index = user:get_wield_index()-1
		arrow = inv:get_stack("main", index)
		if minetest.get_item_group(arrow:get_name(), "arrow") == 0 then
			return itemstack
		end
	end

	if bows.creative == false then
		local c=arrow:get_count()-shots
		if c<0 then
			shots=arrow:get_count()
			c=0
		end
		inv:set_stack("main",index,ItemStack(arrow:get_name() .. " " .. c))
	end

	meta:set_string("arrow",arrow:get_name())
	meta:set_int("shots",shots)
	itemstack:set_name(itemstack:get_name() .. "_loaded")
	return itemstack
end

bows.shoot=function(itemstack, user, pointed_thing,on_dropitem)
	local meta = itemstack:get_meta()
	local arrow = meta:get_string("arrow")
	local shots = meta:get_int("shots")
	local name=itemstack:get_name()
	local replace = bows.registed_bows[name].name

	meta:set_string("arrow","")
	meta:set_int("shots",0)
	itemstack:set_name(replace)

	if not bows.registed_arrows[arrow] then
		return itemstack
	end

	local ar=bows.registed_bows[name].uses
	local wear=bows.registed_bows[name].uses
	local level=19 + bows.registed_bows[name].level
	local dmg = bows.registed_arrows[arrow].damage
	local autoaim = bows.registed_bows[itemstack:get_name() .. "_loaded"].autoaim
	local delay = autoaim and shots > 1 and 0.1 or 0.05

	if bows.creative==false then
		itemstack:add_wear(65535/wear)
	end
	for i=0,shots-1,1 do
		minetest.after(delay*i, function(level,user,arrow,dmg,autoaim)
			local pos = user:get_pos()
			local dir = user:get_look_dir()

			local x=math.random(-1,1)*0.1
			local y=math.random(-1,1)*0.1
			local z=math.random(-1,1)*0.1

			local e = minetest.add_entity(
				{x=pos.x+x,
				y=pos.y+((user:get_player_control().sneak or minetest.get_item_group(minetest.get_node(pos).name,"liquid") > 0) and 0.5 or 1.5)+y,
				z=pos.z+z
			}, "default:arrow")
			local self = e:get_luaentity()

			if autoaim then
				local obpos2,autodis = nil,100
				pos = e:get_pos()
				for _, ob in pairs(minetest.get_objects_inside_radius(pos, 200)) do
					local en = ob:get_luaentity()
					if ob ~= user and (en and en.examob and en.dead == nil or ob:is_player()) then
						local obpos = ob:get_pos()
						local ob2 = vector.normalize(vector.subtract(obpos, pos))
						local deg = math.acos((ob2.x*dir.x)+(ob2.y*dir.y)+(ob2.z*dir.z)) * (180 / math.pi)
						local d = vector.distance(pos,obpos)
						if d < autodis and not (deg < 0 or deg > 50) and minetest.line_of_sight(pos,obpos) then
							autodis = d
							obpos2 = ob:get_pos()
						end
					end
				end
				if obpos2 then
					level = level/2
					dir = vector.new((obpos2.x-pos.x)*1,(obpos2.y-pos.y)*1,(obpos2.z-pos.z)*1)
					e:set_velocity({x=num(dir.x*level), y=num(dir.y*level), z=num(dir.z*level)})
				else
					local inv = user:get_inventory()
					local s = ItemStack(arrow)
					if inv:room_for_item("main",s) then
						e:remove()
						inv:add_item("main",s)
						return
					else
						e:set_velocity({x=num(dir.x*level), y=num(dir.y*level), z=num(dir.z*level)})
					end
				end
			else
				e:set_velocity({x=num(dir.x*level), y=num(dir.y*level), z=num(dir.z*level)})
			end

			e:set_acceleration({x=num(dir.x*-3), y=-10, z=num(dir.z*-3)})
			e:set_yaw(user:get_look_horizontal()-math.pi/2)
			e:set_properties({textures={arrow}})
			self.on_dropitem=on_dropitem or function() end
			self.dir ={x=num(dir.x/2),y=num(dir.y/2),z=num(dir.z/2)}
			self.arrow = arrow
			self.user = user
			self.dmg = dmg
			minetest.sound_play("default_bow_shoot", {pos=pos})
		end,level,user,arrow,dmg,autoaim)
	end
	return itemstack
end

bows.nothing=function()
end

bows.on_hit_object=function(self,target,hp,user,lastpos)
	default.punch(target,self.user and self.user:get_pos() and self.user or target,hp)
end

bows.on_hit_node=function(self,pos,user,lastpos)
	return self
end

bows.rnd=function(r)
	return math.floor(r+ 0.5)
end

bows.arrow_remove=function(self)
	if self.target then default.punch(self.target,self.object,1) end
	self.removed = true
	self.object:remove()
	return self
end

minetest.register_entity("default:arrow",{
	hp_max = 10,
	visual="wielditem",
	visual_size={x=0.20,y=0.20},
	collisionbox = {-0.01,-0.01,-0.01,0.01,0.01,0.01},
	physical=true,
	textures={"air"},
	static_save = false,
	on_punch=function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		if not self.target then return self end
		if not self.hp then self.hp=self.object:get_hp() end
		local hp=self.object:get_hp()
		local hurt=self.hp-self.object:get_hp()
		self.hp=self.object:get_hp()
		self.target:set_hp(self.target:get_hp()-hurt)
		default.punch(target,self.object,hurt)
		if hurt>100 or hp<=hurt then
			self.target:set_detach()
			self.target:set_velocity({x=0, y=4, z=0})
			self.target:set_acceleration({x=0, y=-10, z=0})
			self.on_punch(self, puncher, time_from_last_punch, tool_capabilities, dir)
			bows.arrow_remove(self)
		end
		return self
	end,
	bow_arrow=true,
	timer=20,
	drop=function(self)
		if not self.removed then
			local pos=self.object:get_pos()
			local e = minetest.add_item({x=pos.x, y=math.floor(pos.y+0.5), z=pos.z},self.arrow)
			e:set_velocity({x = math.random(-0.5, 0.5),y=0.5,z = math.random(-0.5, 0.5)})
			self.on_dropitem(e)
			self.removed = true
			self.object:remove()
		end
	end,
	on_step=function(self, dtime, moveresult)
		self.timer=self.timer-dtime
		local pos=self.object:get_pos()
		bows.registed_arrows[self.arrow].on_step(self,dtime,self.user,pos,self.oldpos or pos)
		if not self.user or self.timer < 16 then
			self:drop()
			return
		elseif moveresult and moveresult.collides then
			for i,v in pairs(moveresult.collisions) do
				if v.type == "node" then
					minetest.check_for_falling(pos)
					bows.registed_arrows[self.arrow].on_hit_node(self,pos,self.user,self.oldpos or pos)
					minetest.sound_play(bows.registed_arrows[self.arrow].on_hit_sound, {pos=pos, gain = 1.0, max_hear_distance = 7})
					self:drop()
					return
				elseif v.type == "object" and not default.is_decoration(v.object,true) then
					local en = v.object:get_luaentity()
					if not (en and en.user and en.user == self.user) then
						bows.on_hit_object(self,v.object,self.dmg,self.user,self.oldpos or pos)
						bows.registed_arrows[self.arrow].on_hit_object(self,v.object,self.dmg,self.user,self.oldpos or pos)
						minetest.sound_play(bows.registed_arrows[self.arrow].on_hit_sound, {pos=pos, gain = 1.0, max_hear_distance = 7})
						self:drop()
						return
					end
				end
			end
		end
		self.oldpos = vector.new(pos)
		return self
	end,
})

bows.register_bow("wood",{
	description="Wooden bow",
	uses=50,
	level=1,
	craft={
		{"","group:stick","materials:string"},
		{"group:stick","","materials:string"},
		{"","group:stick","materials:string"}
	},
})

bows.register_arrow("arrow",{
	description="Arrow",
	texture="default_wood.png",
	damage=5,
	craft_count=8,
	groups =  {store=10},
	craft={{"group:tip","group:stick","examobs:feather"},}
})

bows.register_arrow("fire",{
	description="Fire arrow",
	texture="default_wood.png^[colorize:#ffb400cc",
	damage=10,
	craft_count=1,
	groups={treasure=2},
	on_hit_node=function(self,pos,user,lastpos)
		lastpos = lastpos or pos
		if not minetest.is_protected(lastpos, user:get_player_name()) and default.defpos(lastpos,"buildable_to") then
			minetest.set_node(lastpos,{name="fire:basic_flame"})
		end
		bows.arrow_remove(self)
		return self
	end,
	on_hit_object=function(self,target,hp,user,lastpos)
		local p = target:get_pos() or self.object:get_pos()
		bows.registed_arrows["default:arrow_fire"].on_hit_node(self,lastpos,user,p)
		minetest.get_meta(p):set_int("radius",3)
		minetest.get_node_timer(p):start(0.1)
		bows.arrow_remove(self)
	end,
	craft={
		{"group:arrow","default:torch"},
	}
})


bows.register_arrow("build",{
	description="Build arrow",
	texture="default_wood.png^[colorize:#33336677",
	groups={treasure=2},
	on_hit_node=function(self,pos,user,lastpos)
		local name=user:get_player_name()
		local node=minetest.get_node(lastpos).name
		local index=user:get_wield_index()+1
		local inv=user:get_inventory()
		local stack=inv:get_stack("main", index)
		if minetest.is_protected(lastpos, name) then
			minetest.chat_send_player(name, minetest.pos_to_string(lastpos) .." is protected")
		elseif default.def(node,"buildable_to") and minetest.registered_nodes[stack:get_name()] then
			minetest.set_node(lastpos,{name=stack:get_name()})
			if bows.creative==false then
				inv:set_stack("main",index,ItemStack(stack:get_name() .. " " .. (stack:get_count()-1)))
			end
		end
		bows.arrow_remove(self)
		return self
	end,
	craft_count=8,
	damage=8,
	groups =  {store=100},
	craft={
		{"group:arrow","group:arrow","group:arrow"},
		{"group:arrow","default:obsidian","group:arrow"},
		{"group:arrow","group:arrow","group:arrow"}
	}
})

bows.register_arrow("dig",{
	description="Dig arrow",
	groups={treasure=2},
	texture="default_wood.png^[colorize:#333333aa",
	on_hit_node=function(self,pos,user,lastpos)
		minetest.node_dig(pos, minetest.get_node(pos), user)
		bows.arrow_remove(self)
		return self
	end,
	craft_count=16,
	damage=8,
	groups =  {store=100},
	craft={
		{"group:arrow","group:arrow","group:arrow"},
		{"group:arrow","default:steel_lump","group:arrow"},
		{"group:arrow","group:arrow","group:arrow"}
	}
})

bows.register_arrow("toxic",{
	description="Toxic arrow",
	groups={treasure=2},
	texture="default_wood.png^[colorize:#66aa11aa",
	on_hit_object=function(self,target,hp,user,lastpos)
		if self then
			bows.arrow_remove(self)
		end
		default.punch(target,target,3)
		if math.random(1,15) == 1 or target:get_hp() == 0 or not target:get_pos() then
			return
		end
		minetest.after(math.random(0.5,2),function(target)
			bows.registed_arrows["default:arrow_toxic"].on_hit_object(nil,target)
		end,target)
	end,
	craft_count=1,
	damage=0,
	craft={
		{"group:arrow","plants:dolls_eyes_berries"},
	}
})

bows.register_arrow("tetanus",{
	description="Tetanus arrow (currently affects mobs only)",
	groups={treasure=2},
	texture="default_wood.png^[colorize:#aa5500aa",
	on_hit_object=function(self,target,hp,user,lastpos)
		bows.arrow_remove(self)
		local en =  target:get_luaentity()
		if en and en.hp_max < 100 then
			local step = en.on_step
			en.on_step=function(self,dtime)
				self.Tetanus_timer = (self.Tetanus_timer or 0) + dtime
				if self.Tetanus_timer > 10 then
					self.on_step=step
					self.Tetanus_timer = nil
				end
				return self
			end
		end
	end,
	craft_count=4,
	damage=1,
	craft={
		{"","group:arrow",""},
		{"group:arrow","plants:cow_parsnip_big","group:stick"},
		{"","group:arrow",""}
	}
})

bows.register_arrow("exposive",{
	description="Exposive arrow",
	texture="default_wood.png^[colorize:#aa0000aa",
	groups={treasure=2,store=200},
	on_hit_object=function(self,target,hp,user,lastpos)
		bows.registed_arrows["default:arrow_exposive"].on_hit_node(self,target:get_pos(),user)
	end,
	on_hit_node=function(self,pos,user)
		bows.arrow_remove(self)
		local name = user:get_player_name()
		if not minetest.is_protected(pos, name) then
			nitroglycerin.explode(pos,{
				place_chance=1,
				user_name=name,
			})
		end
	end,
	craft_count=2,
	damage=15,
	craft={
		{"","default:coal_lump",""},
		{"default:coal_lump","group:arrow","default:coal_lump"},
		{"","default:coal_lump",""}
	}
})

bows.register_arrow("nitrogen",{
	description="Nitrogen arrow",
	texture="default_wood.png^[colorize:#00c482aa",
	groups={treasure=2,store=100},
	on_hit_object=function(self,target,hp,user,lastpos)
		bows.arrow_remove(self)
		if target:get_hp() <= 13 then
			nitroglycerin.freeze(target)
		else
			default.punch(target,target,10)
		end
	end,
	craft_count=4,
	damage=0,
	craft={
		{"","default:ice",""},
		{"default:ice","group:arrow","default:ice"},
		{"","default:ice",""}
	}
})

bows.register_arrow("teleport",{
	description="Teleport arrow",
	texture="default_quantumblock.png",
	on_hit_object=function(self,target,hp,user,lastpos)
		local d = user:get_look_dir()
		local p = user:get_pos()
		target:set_pos({x=p.x+(d.x*2),y=p.y+(d.y*2),z=p.z+(d.z*2)})
		bows.arrow_remove(self)
	end,
	on_hit_node=function(self,pos2,user,lastpos)
		user:set_pos(lastpos)
		bows.arrow_remove(self)
	end,
	craft_count=99,
	groups={treasure=2,store=1000},
	damage=0,
	craft={
		{"","group:arrow",""},
		{"group:arrow","default:quantumblock",""},
		{"","group:arrow",""}
	}
})

bows.register_arrow("lightning",{
	description="Lightning arrow",
	texture="default_wood.png^[colorize:#FFFFFFFF",
	on_step=function(self)
		local d = self.user:get_look_dir()
		local pos1 = self.object:get_pos()
		local uname  = self.user:get_player_name()
		local pos2
		for i=1,100 do
			pos2 = {x=pos1.x+(d.x*i),y=pos1.y+(d.y*i),z=pos1.z+(d.z*i)}
			if default.defpos(pos2,"walkable") then
				break
			end
			for i, ob in pairs(minetest.get_objects_inside_radius(pos2, 1)) do
				local en  = ob:get_luaentity()
				if not (en and en.bow_arrow or ob:is_player() and ob:get_player_name() == uname) then
					default.punch(ob,self.user,20)
				end
			end
		end
		local vec = {x=pos1.x-pos2.x, y=pos1.y-pos2.y, z=pos1.z-pos2.z}
		local y = math.atan(vec.z/vec.x)
		local z = math.atan(vec.y/math.sqrt(vec.x^2+vec.z^2))
		if pos1.x >= pos2.x then y = y+math.pi end
		local lightning = minetest.add_entity(pos1, "default:arrow_lightning")
		lightning:set_rotation({x=0,y=y,z=z})
		lightning:set_pos({x=pos1.x+(pos2.x-pos1.x)/2,y=pos1.y+(pos2.y-pos1.y)/2,z=pos1.z+(pos2.z-pos1.z)/2})
		lightning:set_properties({visual_size={x=vector.distance(pos1,pos2),y=0.03,z=0.03}})
		bows.arrow_remove(self)
	end,
	craft_count=3,
	damage=0,
	groups={treasure=2,store=1000},
	craft={
		{"","group:arrow",""},
		{"group:arrow","default:electric_lump",""},
		{"","group:arrow",""}
	}
})

minetest.register_entity("default:arrow_lightning",{
	physical = false,
	visual = "cube",
	pointable = false,
	textures={"default_cloud.png","default_cloud.png","default_cloud.png","default_cloud.png","default_cloud.png","default_cloud.png"},
	on_step=function(self,dtime)
		self.t = self.t - dtime
		if self.t < 0 then
			self.object:remove()
		end
	end,
	t=1
})

bows.register_arrow("crystal",{
	description="Crystat arrow",
	texture="default_noise.png",
	on_hit_object=function(self,target,hp,user,lastpos)
		local p = target:get_pos()
		local c = target:get_properties().collisionbox
		local cp1 = vector.add(p,vector.new(c[1],c[2],c[3]))
		local cp2 = vector.add(p,vector.new(c[4],c[5],c[6]))
		local d = math.floor(vector.distance(cp1,cp2))
		for x = -d,d do
		for y = -d-1,d+1 do
		for z = -d,d do
			local p2 = apos(lastpos,x,y,z)
			if not minetest.is_protected(p2,"") and default.defpos(p2,"buildable_to") then
				minetest.set_node(p2,{name="plants:crystal_block"..math.random(1,#plants.dye_colors)})
			end
		end
		end
		end
		bows.arrow_remove(self)
	end,
	craft_count=3,
	groups={treasure=2,store=1000},
	damage=0,
	craft={
		{"group:arrow","group:crystal","default:peridot"},
	}
})