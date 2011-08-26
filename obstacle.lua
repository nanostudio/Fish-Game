-- obstacle namespace
Obstacle = {}

function Obstacle.new( x, y, w, h )
	local obj = {}
	
	-- attributes
	obj.color = { r = 50, g = 124, b = 80 }
	obj.body = love.physics.newBody( world, x, y, 0, 0 )
	obj.body:setBullet( true )
	obj.width = w
	obj.height = h
	obj.shape = love.physics.newRectangleShape( obj.body, 0, 0, obj.width, obj.height, 0)
	
	-- methods
	obj.draw = Obstacle.draw
	
	return obj
end

function Obstacle.draw( self, camera )
	local pos = { x = self.body:getX() - camera.body:getX(), y = self.body:getY() - camera.body:getY() }

	love.graphics.setColor( self.color.r, self.color.g, self.color.b )
	love.graphics.rectangle( "fill", pos.x - (self.width/2), pos.y - (self.height/2), self.width, self.height )
end