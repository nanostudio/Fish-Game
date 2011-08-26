-- fish namespace

Fish = {}
Fish.list = {}

Fish.state = { 
	IDLE = 'idle',
	MOVING = 'moving',
	DIZZY = 'dizzy'
}


-- fish constructor
function Fish.new( radius )
	local obj = {}
	
	-- ATTRIBUTES
		-- fish radius
		obj.original_radius = radius or 10 + math.random()*30
	
		-- body and shape
		obj.body = love.physics.newBody( world, 0, 0, obj.original_radius, 0 )
		--obj.body:setBullet( true )
		--obj.body:setAllowSleeping( false )
		
		obj.shape = love.physics.newCircleShape( obj.body, 0, 0, obj.original_radius )
		
		-- initial direction
		obj.dir = { 1, 0 }
		
		-- life frequency (used for floating animation)
		obj.freq = math.random()*100
		
		-- whether the fish is active
		--obj.active = true
		
		-- state of the fish
		obj.state = Fish.state.IDLE
		obj.state_counter = 0
		
		-- who this fish is following
		--obj.following = nil
		
		-- list of fishes who are following me
		obj.followers = {}

		
	-- METHODS
		obj.update = Fish.update
		obj.draw = Fish.draw
		obj.getDistTo = Fish.getDistTo
		obj.addFollower = Fish.addFollower
		obj.lostLeader = Fish.lostLeader
		obj.isAvailableLeader = Fish.isAvailableLeader
		obj.respawn = Fish.respawn
		obj.kill = Fish.kill
		obj.rescue = Fish.rescue
		
	Fish.list[ obj ] = true
	
	-- spawning fish somewhere in a respawn area
	Fish.respawn( obj )
	
	return obj
end

function Fish.update( self, dt )

	--if self.active then

		-- updating frequency
		
		if self.state == Fish.state.IDLE then
			self.freq = self.freq + dt
		
			self.state_counter = self.state_counter - dt
			if self.state_counter < 0 then
				self.state = Fish.state.MOVING
				self.dir = { math.random()*2 - 1, math.random()*2 - 1 } 
				self.state_counter = math.random()*10
			end
			
		elseif self.state == Fish.state.DIZZY then
			self.freq = self.freq + 15*dt
			
			self.state_counter = self.state_counter - dt
			if self.state_counter < 0 then
				self.state = Fish.state.IDLE
				self.state_counter = math.random()*5
			end
			
		elseif self.state == Fish.state.MOVING then
			self.freq = self.freq + 5*dt
			
			if self.following then
				-- testing if the fish has been rescued
				if 	self.body:getX() > escape_area.x and
					self.body:getY() > escape_area.y and
					self.body:getX() < escape_area.x + escape_area.w and
					self.body:getY() < escape_area.y + escape_area.h then
						--self.active = false
						self:rescue()
						return
				end
			
				-- get the direction of the leader
				local dist, dir, speed = self:getDistTo( self.following )
				local cursor_dist, cursor_dir, cursor_speed = self:getDistTo( cursor )		
				
				if dist > 150 then
					self.body:setPosition( self.body:getX() + dir[1]*speed, self.body:getY() + dir[2]*speed )
				end
			else
				-- try to follow cursor
				local dir = { cursor.body:getX() - self.body:getX(), cursor.body:getY() - self.body:getY() }
				local dist = math.sqrt( (dir[1]*dir[1]) + (dir[2]*dir[2]) )
				if dist <= alert_radius and cursor_active then
					cursor:addFollower( self )
				else
					self.state_counter = self.state_counter - dt
					if self.state_counter < 0 then
						self.state = Fish.state.IDLE
						self.state_counter = math.random()
					else
						-- fish wandering speed
												--	iansdoaisn = oansdoasnd + 1
						local speed = 0.0
						self.body:setPosition( self.body:getX() + self.dir[1]*speed, self.body:getY() + self.dir[2]*speed )
					end
				end
			end
		end
	--end
end

function Fish.draw( self, camera )
	--if self.active then
	
		local pos = { x = self.body:getX() - camera.body:getX(), y = self.body:getY() - camera.body:getY() }
		local radius = self.shape:getRadius() / 2
	
		--if self.following then
			--love.graphics.setColor(255, 0, 0)
			--love.graphics.circle("fill", pos.x, pos.y, radius, 20)
			
			--if debug_mode then
			--	love.graphics.setColor(0, 255, 0)
			--	love.graphics.line( pos.x, pos.y, self.following.body:getX() - camera.body:getX(), self.following.body:getY() - camera.body:getY() )
			--	love.graphics.print( "      "..( self.following_number or "" ), pos.x, pos.y )
			--end
		--else
			if self.state == Fish.state.DIZZY then
				love.graphics.setColor(0, 255, 0)
				love.graphics.circle("fill", pos.x + 10*math.cos(self.freq), pos.y + 10*math.sin(self.freq), radius, 20)
			else
				love.graphics.setColor(0, 0, 255)
				love.graphics.circle("fill", pos.x, pos.y + 20*math.sin(self.freq), radius, 20)
			end
		--end
		--love.graphics.circle("fill", pos.x, pos.y + 20*math.sin(self.freq), radius, 20)
	--end
end

function Fish.getDistTo( self, other )
	local dir = { other.body:getX() - self.body:getX(), other.body:getY() - self.body:getY() }
	local dist = math.sqrt( (dir[1]*dir[1]) + (dir[2]*dir[2]) )
	--local rand = dist * randomness / 900
	--local rand_dir = { rand*math.random() - (rand/2), rand*math.random() - (rand/2)}
	--dir[1] = dir[1] + rand_dir[1]
	--dir[2] = dir[2] + rand_dir[2]
	self.dir = { self.body:getX() + dir[1], self.body:getY() + dir[2] }
	local rand_dist = math.sqrt( (dir[1]*dir[1]) + (dir[2]*dir[2]) )
	dir[1] = dir[1] / dist
	dir[2] = dir[2] / dist
	local radius = self.shape:getRadius()
	local speed = (13/radius)*(rand_dist-45)/fish_speed 
	return dist, dir, speed
end

function Fish.addFollower( self, follower )
	
	----[[
	follower.following = self
	follower.following_number = self.following_number + 1
	self.followers[ #self.followers+1 ] = follower
	--]]
	--[[if #self.followers < 4 then
		follower.following = self
		follower.following_number = self.following_number + 1
		self.followers[ #self.followers+1 ] = follower
	else
		local least_followers = 100
		local least_followers_id = 0
		for i = 1, #self.followers do
			if #self.followers[ i ].followers < least_followers then
				least_followers_id = i
				least_followers = #self.followers[ i ].followers
			end
		end
		self.followers[ least_followers_id ]:addFollower( follower )
	end
	--]]
end

function Fish.lostLeader( self )
	self.freq = 0	
	-- inertia 
	--self.body:applyImpulse( dir[1]*speed*3, dir[2]*speed*3 )	
				
	self.following = nil
				
	for i = 1,#self.followers do
		self.followers[ i ]:lostLeader()
	end
end

function Fish.isAvailableLeader( self )
	return (#self.followers < 4) and self.following
end

function Fish.respawn( self )
	local chosen_respawn_area = respawn_areas[ math.random( 1, #respawn_areas ) ]
	
	self.body:setX( chosen_respawn_area.x + math.random()*chosen_respawn_area.w )
	self.body:setY( chosen_respawn_area.y + math.random()*chosen_respawn_area.h )
	
	self.body:setAllowSleeping( false )
	self.body:setBullet( true )
	self.state = Fish.state.IDLE
	self.state_counter = 0
	
	--self.original_radius = math.random() > 0.5 and 20 or 40
	
	self.following = nil
end

function Fish.kill( self )
	if not( self == cursor ) then
		self:respawn()
	end
end

function Fish.rescue( self )
	if not( self == cursor ) then
		tests = tests + 1
		self:respawn()
	end
end