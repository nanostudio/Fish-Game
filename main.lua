require('fish')
require('obstacle')
require('bubbles')
require('thorns')
require('jellyfish')

function love.load()

	WORLD_WIDTH = 2000
	WORLD_HEIGHT = 1500

	world = love.physics.newWorld( -WORLD_WIDTH/2, -WORLD_HEIGHT/2, WORLD_WIDTH/2, WORLD_HEIGHT/2 )
	world:setMeter( 64 )
	
	escape_area = { x = -200, y = -400, w = 420, h = 220 }
	
	respawn_areas = {
		{ x = -920, y = 450, w = 220, h = 220 },
		{ x = 700, y = 450, w = 220, h = 220 }
	}
	
	game_state = 'game'
	fishes = {}
	obstacles = {}
	n_fishes = 20
	fish_speed = 50
	randomness = 1040
	alert_radius = 200
	mouse_was_down = 0
	
	debug_mode = false
	debug_str = ''
	
	cursor_speed = 470
	cursor_active = true
	
	tests = 0
	time_left = 60
	
	-- creating fishes
	for i = 1, n_fishes do
		Fish.new()
	end
	
	-- creating jellyfish
	local jelly = Jellyfish.new()
	jelly.body:setPosition( -400, -400 )
	
	-- creating obstacles
	local wall_thickness = 50
	
	-- surrounding walls
	obstacles[ #obstacles+1 ] = Obstacle.new( 0, -WORLD_HEIGHT/2, WORLD_WIDTH + wall_thickness, wall_thickness )
	obstacles[ #obstacles+1 ] = Obstacle.new( -WORLD_WIDTH/2, 0, wall_thickness, WORLD_HEIGHT + wall_thickness )
	obstacles[ #obstacles+1 ] = Obstacle.new( WORLD_WIDTH/2, 0, wall_thickness, WORLD_HEIGHT + wall_thickness )
	obstacles[ #obstacles+1 ] = Obstacle.new( 0, WORLD_HEIGHT/2, WORLD_WIDTH + wall_thickness, wall_thickness )
	
	-- lower left stone ceiling
	obstacles[ #obstacles+1 ] = Obstacle.new( -WORLD_WIDTH/2 + (WORLD_WIDTH / 12), WORLD_HEIGHT/4, WORLD_WIDTH / 6, wall_thickness )
	
	-- middle reef
	obstacles[ #obstacles+1 ] = Obstacle.new( 0, -wall_thickness * 2.5, ( WORLD_WIDTH / 4 ) + wall_thickness, wall_thickness )
	obstacles[ #obstacles+1 ] = Obstacle.new( 0, -wall_thickness * 1.5, ( WORLD_WIDTH / 3 ) + wall_thickness, wall_thickness * 1.5 )
	obstacles[ #obstacles+1 ] = Obstacle.new( 0, 0, ( WORLD_WIDTH / 2 ) + wall_thickness, wall_thickness * 2 )
	
	-- upper right stone wall
	obstacles[ #obstacles+1 ] = Obstacle.new( WORLD_WIDTH/3, -WORLD_HEIGHT/2 + WORLD_HEIGHT/8, wall_thickness, WORLD_HEIGHT/4 )
	
	-- bubbles
	obstacles[ #obstacles+1 ] = Bubbles.new( WORLD_WIDTH/4, 0, 60, 100, 'left' )
	obstacles[ #obstacles+1 ] = Bubbles.new( -WORLD_WIDTH/4, WORLD_HEIGHT / 2, 100, 60 )
	
	-- thorns
	obstacles[ #obstacles+1 ] = Thorns.new( WORLD_WIDTH/2 - 60, 0, 60, 180 )
	obstacles[ #obstacles+1 ] = Thorns.new( -WORLD_WIDTH/2 + 60, 0, 60, 180 )
	obstacles[ #obstacles+1 ] = Thorns.new( -WORLD_WIDTH/4 - 60, 0, 60, 100 )
	
	-- total number of obstacles
	n_obstacles = #obstacles
	
	camera = {}
	camera.body = love.physics.newBody( world, 200, 200, 0, 0 )
	camera.shape = love.physics.newCircleShape( camera.body, 100, 100, 20 )
	
	cursor = Fish.new( 25 )
	cursor.body:setMass( 0, 0, 0, 0 )
	cursor.following_number = 0
	cursor.isAvailableLeader = function( self )
		return #self.followers < 4
	end
end


function love.update( dt )

	world:update( dt )
	
	if time_left > 0 then
	
		time_left = time_left - dt

		if love.keyboard.isDown( 'k' ) then cursor_active = not(cursor_active) end
		if love.keyboard.isDown( 'l' ) then debug_mode = not(debug_mode) end

		--local move = { x = 0, y = 0 }
		--if love.keyboard.isDown( 'a' ) then move.x = -cursor_speed*dt end
		--if love.keyboard.isDown( 'd' ) then move.x = cursor_speed*dt end
		--if love.keyboard.isDown( 'w' ) then move.y = -cursor_speed*dt end
		--if love.keyboard.isDown( 's' ) then move.y = cursor_speed*dt end
		
		if love.mouse.isDown( 'l' ) then
			if mouse_was_down > 0.6 then
				local mouse_x, mouse_y = love.mouse.getPosition()
				local new_x, new_y = 	camera.body:getX() + mouse_x,
										camera.body:getY() + mouse_y
										--cursor.body:getX() + ( ( mouse_x - ( love.graphics.getWidth()/2 ) ) / 64 ), 
										--cursor.body:getY() + ( ( mouse_y - ( love.graphics.getHeight()/2 ) ) / 64 ) 
				cursor.body:setX( new_x ) 
				cursor.body:setY( new_y )
				debug_str = '--> '..( ( ( mouse_x - ( love.graphics.getWidth()/2 ) ) / 64 ) )..', '..( ( mouse_y - ( love.graphics.getHeight()/2 ) ) / 64 )
			else
				mouse_was_down = mouse_was_down + dt
			end
		else
			mouse_was_down = 0
		end
		
		for fish,_ in pairs( Fish.list ) do
			fish:update( dt )
		end
		
		for i = 1, n_obstacles do
			if obstacles[ i ].update then obstacles[ i ]:update( dt ) end
		end
		
		for bubble, _ in pairs( Bubbles.list ) do
			bubble:update( dt )
			if bubble.life > 1 then Bubbles.list[ bubble ] = nil end
		end
		
		-- updating camera position
		local cam_dir = { cursor.body:getX() - ( love.graphics.getWidth() / 2 ) - camera.body:getX(), cursor.body:getY() - ( love.graphics.getHeight() / 2 ) - camera.body:getY() }
		local cam_dist = math.sqrt( (cam_dir[1]*cam_dir[1]) + (cam_dir[2]*cam_dir[2]) )
		local cam_speed = cam_dist / 10000
		camera.body:setPosition( camera.body:getX() + cam_dir[1]*cam_speed, camera.body:getY() + cam_dir[2]*cam_speed )
	end
end


function love.draw()
	
	-- drawing obstacles
	for i = 1, n_obstacles do
		obstacles[i]:draw( camera ) 
	end
	
	-- drawing fishes
	for fish, _ in pairs( Fish.list ) do
		if not( fish == cursor ) then
			fish:draw( camera )
		end
	end
	
	-- drawing bubbles
	for bubble, _ in pairs( Bubbles.list ) do
		bubble:draw( camera )
	end
	
	love.graphics.setColor( 255, 255, 255 )
	love.graphics.print( "TEMPO RESTANTE: "..time_left, 10, 20 )
	love.graphics.print( "PEIXES COLETADOS: "..tests, 10, 40 )

	-- drawing cursor
	love.graphics.setColor(0, 255, 255, mouse_was_down * 255 )
	if mouse_was_down > 0.6 then
		love.graphics.circle("fill", cursor.body:getX() - camera.body:getX(), cursor.body:getY() - camera.body:getY(), cursor.shape:getRadius() / 2, 20)
	else
		love.graphics.circle("fill", love.mouse.getX(), love.mouse.getY(), cursor.shape:getRadius() / 2, 20)
	end

	-- drawing escape area
	love.graphics.setColor( 255, 255, 0 )
	love.graphics.rectangle( 'line', escape_area.x - camera.body:getX(), escape_area.y - camera.body:getY(), escape_area.w, escape_area.h )
	
	-- drawing respawn areas
	love.graphics.setColor( 80, 60, 60 )
	for i, area in ipairs(respawn_areas) do
		love.graphics.rectangle( 'line', area.x - camera.body:getX(), area.y - camera.body:getY(), area.w, area.h )
	end
end