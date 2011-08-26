require('obstacle')

-- bubbles namespace
Bubbles = {
	BLOWING_TIME = 4,
	BLOWING_SPEED = 800,
	ACC_BLOWING_DT = 0,
	BLOWING_DT = 0.05,
	list = {}
}


function Bubbles.new( x, y, w, h, bubbles_dir )
	local obj = Obstacle.new( x, y, w, h )
	
	-- attributes
	obj.color = { r = 0, g = 200, b = 200 }
	obj.time = 0
	obj.bubbles_dir = bubbles_dir or 'up'
	
	if obj.bubbles_dir == 'up' then
		obj.bubbles_area = {
			x = obj.body:getX() - (obj.width/2),
			y = obj.body:getY() - (obj.width*6),
			w = obj.width,
			h = obj.width*6
		}
	else
		obj.bubbles_area = {
			x = obj.body:getX() + (obj.width/2),
			y = obj.body:getY() - (obj.width/2),
			w = (obj.width*9),
			h = obj.width
		}
	end
	
	-- overriding
	obj.update = Bubbles.update
	obj.draw = Bubbles.draw
	obj.is_blowing = Bubbles.is_blowing
	obj.is_inside_bubbles = Bubbles.is_inside_bubbles
	
	return obj
end

function Bubbles.update( self, dt )
	self.time = self.time + dt
	if self.time > Bubbles.BLOWING_TIME then self.time = 0 end
	
	if not( self:is_blowing() ) then
		self.color = { r = 200, g = 200, b = 0 }
	else
		Bubbles.ACC_BLOWING_DT = Bubbles.ACC_BLOWING_DT + dt
		if Bubbles.ACC_BLOWING_DT > Bubbles.BLOWING_DT then
			if self.bubbles_dir == 'up' then
				Bubbles.createBubble( self.body:getX() -(self.width/2) + math.random()*self.width, self.body:getY(), self.bubbles_dir )
			else
				Bubbles.createBubble( self.body:getX(), self.body:getY() - (self.height/2) + math.random()*self.height, self.bubbles_dir )
			end
			Bubbles.ACC_BLOWING_DT = 0
		end
		self.color = { r = 0, g = 0, b = 200 }
		
		for fish, _ in pairs( Fish.list ) do
			if self:is_inside_bubbles( fish.body:getX(), fish.body:getY() ) then
				fish.following = nil
				fish.state = Fish.state.DIZZY
				fish.state_counter = 2
				fish.dizziness = 5
				
				if self.bubbles_dir == 'up' then
					fish.body:setPosition( fish.body:getX(), fish.body:getY() - Bubbles.BLOWING_SPEED*dt )
				else
					fish.body:setPosition( fish.body:getX() + Bubbles.BLOWING_SPEED*dt, fish.body:getY() )
				end
			end
		end
	end
end

function Bubbles.draw( self, camera )
	Obstacle.draw( self, camera )
	
	--[[ drawing bubbles area
	love.graphics.setColor( 50, 100, 100 )
	love.graphics.rectangle( "fill", 
		self.bubbles_area.x - camera.body:getX(),
		self.bubbles_area.y - camera.body:getY(),
		self.bubbles_area.w,
		self.bubbles_area.h
	)
	--]]
end

function Bubbles.is_blowing( self )
	return self.time > Bubbles.BLOWING_TIME / 2
end

function Bubbles.is_inside_bubbles( self, x, y )
	return 	x > self.bubbles_area.x and
			x < self.bubbles_area.x + self.bubbles_area.w and
			y > self.bubbles_area.y and
			y < self.bubbles_area.y + self.bubbles_area.h
end

function Bubbles.createBubble( x, y, dir )
	local obj = {}
	
	obj.x = x
	obj.y = y
	obj.dir = dir
	obj.life = 0
	obj.radius = 5 + math.random()*5
	obj.update = function( self, dt )
		if dir == 'up' then
			self.y = self.y - (1.2-self.life)*Bubbles.BLOWING_SPEED*dt
		else
			self.x = self.x + (1.2-self.life)*Bubbles.BLOWING_SPEED*dt
		end
		self.life = self.life + dt
		
	end
	
	obj.draw = function( self )
		love.graphics.setColor( 255, 255, 255 )
		love.graphics.circle( 'line', self.x - camera.body:getX(), self.y - camera.body:getY(), self.radius )
	end

	Bubbles.list[ obj ] = true
end