-- thorns namespace
Thorns = {
	list = {}
}


function Thorns.new( x, y, w, h )
	
	local obj = {}
	
	obj.color = { r = 200, g = 100, b = 20 }
	obj.x = x
	obj.y = y
	obj.width = w
	obj.height = h
	
	-- methods
	obj.update = Thorns.update
	obj.draw = Thorns.draw
	
	return obj
end

function Thorns.update( self, dt )
	for fish, _ in pairs( Fish.list ) do
		if 	fish.body:getX() > self.x - self.width/2 and
			fish.body:getX() < self.x + self.width/2 and
			fish.body:getY() > self.y - self.height/2 and
			fish.body:getY() < self.y + self.height/2 then
			fish:kill()
		end
	end
end

function Thorns.draw( self, camera )
	local pos = { x = self.x - camera.body:getX(), y = self.y - camera.body:getY() }

	love.graphics.setColor( self.color.r, self.color.g, self.color.b )
	love.graphics.rectangle( "fill", pos.x - (self.width/2), pos.y - (self.height/2), self.width, self.height )
end