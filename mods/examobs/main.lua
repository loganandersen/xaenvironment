examobs={}

examobs.main=function(self, dtime)
	self.timer1 = self.timer1 + dtime
	self.timer2 = self.timer2 + dtime
	self.lifetimer = self.lifetimer - dtime
	if self.timer1 > 0.1 then
		self.environment_timer = self.environment_timer + self.timer1
		self.environment_timer2 = self.environment_timer2 + self.timer1
		self.timer1 = 0
		if self.environment_timer > 0.2 and examobs.environment(self) then return end
	end
	if self.timer2 < self.updatetime then return end
	self.timer2 = 0

	if (self.dying or self.dead) and examobs.dying(self) then return end
	if self.step(self) then return end
	if examobs.following(self) then return end
	if examobs.fighting(self) then return end
	if examobs.fleeing(self) then return end
	if examobs.exploring(self) then return end
end

examobs.register_mob=function(def)

	local name = minetest.get_current_modname() ..":" .. def.name

	def.hp =				def.hp or				20
	def.hp_max = 			def.hp
	def.physical =			def.physical or			true
	def.collisionbox =			def.collisionbox or			{-0.35,-1.0,-0.35,0.35,0.8,0.35}
	def.visual =			def.visual or			"mesh"
	def.visual_size =			def.visual_size or			{x=1,y=1}
	def.mesh =			def.mesh or			"character.b3d"
	def.makes_footstep_sound =		def.makes_footstep_sound or		true

	def.walk_speed =			def.walk_speed or			2
	def.walk_run =			def.walk_run or			4
	def.lay_on_death =			def.lay_on_death or		1
	def.textures =			def.textures or			{"characrter.png"}
	def.type =			def.type or			"npc"
	def.team =			def.team or			"default"
	def.step =			def.step or			function() end
	def.range =			def.range or			15
	def.reach =			def.reach or			4
	def.dmg =			def.dmg or			1
	def.bottom =			def.bottom or			0
	def.breathing =			def.breathing or			1
	def.resist_nodes =			def.resist_nodes or			{}
	def.swiming =			def.swiming or			1
	def.inv = 				def.inv or				{}
	def.aggressivity =			def.aggressivity or			2
	def.floating =			def.floating or			{}
	def.updatetime =			def.updatetime or			1
	def.spawn_chance =		def.spawn_chance or		50
	def.spawn_on =			def.spawn_on or			{"group:spreading_dirt_type","group:sand","default:snow"}
	def.spawn_in =			def.spawn_in or			"air"
	def.light_min =			def.light_min or			9
	def.light_max =			def.light_max or			13
	def.lifetime =			def.lifetime or			120


	def.animation =			def.animation or			{
		stand={x=1,y=39,speed=30},
		walk={x=41,y=61,speed=30},
		run={x=41,y=61,speed=60},
		attack={x=65,y=75,speed=30},
		lay={x=113,y=123,speed=0},
	}
	if def.animation.walk then
		def.animation.run = def.animation.run or {x=def.animation.walk.x,y=def.animation.walk.y,speed = 60}
	end
	for i, a in pairs(def.animation) do
		def.animation[i].speed = def.animation[i].speed or 30
	end

	def.on_dying =			def.on_dying or			function() end
	def.death =			def.death or			function() end
	def.on_punched =			def.on_punched or			function() end
	def.on_click =			def.on_click or			function() end
	def.on_spawn =			def.on_spawn or			function() end
	def.on_load =			def.on_load or			function() end

	def.timer1 = 0
	def.timer2 = 0
	def.environment_timer = 0
	def.environment_timer2 = 0
	def.lifetimer = def.lifetime
	def.examob = 0
	def.heal=function(self,hp,gaps,num)
		num = num or 1
		gaps = gaps or 1
		self.hp = self.hp + ((hp * gaps) * num )
		self.hp = (self.hp < self.hp_max and self.hp) or self.hp_max
		self.object:set_hp(self.hp)
		examobs.showtext(self,self.hp .. "/" .. self.hp_max,"00ff00")
	end
	def.pos=function(self)
		return self.object:get_pos()
	end
	def.on_step=examobs.main
	def.on_rightclick=function(self, clicker,name)
		if not self.fight then
			examobs.lookat(self,clicker)
		end
		self.on_click(self)
	end
	def.get_staticdata = function(self)
		self.storage.dead=self.dead
		self.storage.dying=self.dying
		self.storage.hp=self.hp
		self.storage.lifetimer=self.lifetimer
		return minetest.serialize(self.storage)
	end
	def.on_activate=function(self, staticdata)
		self.storage = minetest.deserialize(staticdata) or {}
		self.examob = math.random(1,9999)

		self.dead = self.storage.dead or nil
		self.dying = self.storage.dying or nil
		self.hp = self.storage.hp or def.hp
		self.lifetimer = self.storage.lifetimer or def.lifetimer

		self.object:set_velocity({x=0,y=-1,z=0})
		self.object:set_acceleration({x=0,y=-10,z =0})

		if self.dead or self.dying then
			examobs.anim(self,"lay")
		end

		if staticdata ~= "" then
			self.on_load(self)
		else
			self.on_spawn(self)
		end
	end
	def.hurt=function(self,dmg)
		self.hp = self.hp - dmg
		self.object:set_hp(self.hp)
		if self.dead then
			if self.dead <= 0 or self.hp <= 0 then
				self.object:remove()
			end
			return self
		elseif self.dying then
			if self.hp <= 0 then
				examobs.dying(self,2)
				return self
			end
		elseif self.hp <= 0 then
			local pos=self.object:get_pos()
			if self.lay_on_death == 1 then
				examobs.stand(self)
				examobs.dying(self,1)
				return self
			else
				self.death(self,pos,punched_by)
				examobs.dropall(self)
				return self
			end
		end
		examobs.showtext(self,self.hp .. "/" .. self.hp_max)
	end
	def.on_punch=function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		local en = puncher:get_luaentity()
		local dmg = 0
		if not (en and en.examob == self.examob) then
			self.fight = puncher
			examobs.lookat(self,self.fight)
			if not examobs.known(self,puncher,"flee",true) then
				examobs.known(self,puncher,"fight")
			end
			self.on_punched(self,pos,puncher)
		end

		tool_capabilities.damage_groups.fleshy=tool_capabilities.damage_groups.fleshy or 1

		if tool_capabilities and tool_capabilities.damage_groups and tool_capabilities.damage_groups.fleshy then
			dmg = tool_capabilities.damage_groups.fleshy
		end

		local v={x = dir.x*3,y = self.object:get_velocity().y,z = dir.z*3}
		self.object:set_velocity(v)
		local r=math.random(1,99)
		self.onpunch_r=r
		minetest.after(1, function(self,v,r)
			if examobs.gethp(self.object) > 0 and self.onpunch_r==r then
				self.object:set_velocity({x = 0,y = self.object:get_velocity().y,z = 0})
			end
		end, self,v,r)

		self:hurt(dmg)
		return self
	end

	minetest.register_entity(name,def)

	if def.visual == "mesh" then
		minetest.register_node(name .."_spawner", {
			description = def.name .." spawner",
			wield_scale={x=0.1,y=0.1,z=0.1},
			tiles = def.textures,
			drawtype="mesh",
			mesh=def.mesh,
			paramtype="light",
			visual_scale=0.1,
			on_place = function(itemstack, user, pointed_thing)
				if pointed_thing.type=="node" then
					local p = pointed_thing.above
					minetest.add_entity({x=p.x,y=p.y+1,z=p.z}, name):set_yaw(math.random(0,6.28))
					itemstack:take_item()
				end
				return itemstack
			end,
		})
	else
		minetest.register_craftitem(name .."_spawner", {
			description = def.name .." spawner",
			inventory_image = def.textures[1] .. "^examobs_alpha_egg.png^[makealpha:0,255,0",
			on_place = function(itemstack, user, pointed_thing)
				if pointed_thing.type=="node" then
					local p = pointed_thing.above
					minetest.add_entity({x=p.x,y=p.y+1,z=p.z}, name):set_yaw(math.random(0,6.28))
					itemstack:take_item()
				end
				return itemstack
			end
		})
	end

	minetest.register_abm({
		nodenames = def.spawn_on,
		interval = def.spawn_interval or 30,
		chance = def.spawn_chance,
		action = function(pos)
			local pos1 = apos(pos,0,1)
			local pos2 = apos(pos,0,2)
			local l=minetest.get_node_light(pos1)
			if l==nil then return true end
			local n1 = minetest.get_node(pos1).name
			local n2 = minetest.get_node(pos2).name
			if math.random(1,def.spawn_chance) == 1 and l >= def.light_min and l <= def.light_max then
				if n1==def.spawn_in and n2==def.spawn_in or minetest.get_item_group(n1,def.spawn_in) > 0 then
					minetest.add_entity(apos(pos1,0,def.spawn_y), name):set_yaw(math.random(0,6.28))
				end
			end
		end
	})
end