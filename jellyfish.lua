require('fish')

-- jellyfish namespace
Jellyfish = {
	SHOCK_RADIUS = 10
}
Jellyfish.list = {}

Jellyfish.state = {
	IDLE = 'idle',
	SHOCKING = 'shocking'
}

-- fish constructor
function Jellyfish.new( radius )
	local self = Fish.new( radius )
	
	self.state = Jellyfish.state.IDLE
	
	self.update = Jellyfish.update
	self.draw = Jellyfish.draw
	
	return self
end

function Jellyfish.update( self, dt )

	self.state_counter = self.state_counter + dt
	
	if self.state_counter > 3 then
		self.state = Jellyfish.state.SHOCKING
		if self.state_counter > 6 then
			self.state_counter = self.state_counter - 6
			self.state = Jellyfish.state.IDLE
		end
	end
	
	if self.state == Jellyfish.state.SHOCKING then
		for fish, _ in pairs( Fish.list ) do
			if not( fish == cursor ) then
				if self:getDistTo( fish ) < SHOCK_RADIUS then
					fish:kill()
				end
			end
		end
	end
end

function Jellyfish.draw( self, camera )
	--if self.active then
	
		local pos = { x = self.body:getX() - camera.body:getX(), y = self.body:getY() - camera.body:getY() }
		local radius = self.shape:getRadius() / 2

		if self.state == Jellyfish.state.IDLE then
			love.graphics.setColor( 50, 20, 200 )
			love.graphics.circle( "fill", pos.x, pos.y, radius, 20 )
		else
			if math.mod( self.state_counter, 0.4 ) > 0.2 then
				love.graphics.setColor( 150, 120, 200 )
				love.graphics.circle( "fill", pos.x, pos.y, radius, 20 )
				love.graphics.circle( "fill", pos.x, pos.y, Jellyfish.SHOCK_RADIUS, 20 ) 
			else
				love.graphics.setColor( 15, 12, 60 )
				love.graphics.circle( "fill", pos.x, pos.y, radius, 20 )
			end
		end
		--end
		--love.graphics.circle("fill", pos.x, pos.y + 20*math.sin(self.freq), radius, 20)
	--end
end