
--TODO

--PITS
--COIN COUNTER = +10
--BETTER TILE GRAPHICS
--COMPELTE LEVEL DESIGN

--OBJECTIVE/CAKE = +1000/ YOU WIN!

function load()
	
	--lines = {}
	--caves = {{x1=10,x2=70,y1=10,y2=50}}
	coinimg = love.graphics.newImage('images/coin.png')
	
	width,height = love.graphics.getWidth(),love.graphics.getHeight()
	
	xdim = 64
	ydim = 32
	u = width/xdim
	
	tile = love.graphics.newImage('images/tile.png')
	tscale = u/tile:getWidth()
	
	player = {x=7,y=2,vel={0,0}}
	blurs = {}
	
	--these can be adjusted by slider.. but I like these values
	jump = 30
	speed = 30
	gravity = 100
	accel = 100
	
	love.filesystem.require('scripts/windows.lua')
	love.filesystem.require('scripts/mousecontrol.lua')
	love.filesystem.require('scripts/slider.lua')
	love.filesystem.require('scripts/button.lua')
	love.filesystem.require('scripts/levelchange.lua')
	
	--
	levels = {}--list of maps, each of which contains a front and a back map
	--
	love.filesystem.require('levs.lua') --load levels and coinlocs
	level = 1
	maps = levels[level]
	setSpawnPoint()
	--setup missile stuffs now
	love.filesystem.require('scripts/missilestuffs.lua')
	
	front = 1 --the index of teh foreground map
	
	score = 0
	floatytexts = {}
	floatytexttime = 1
	floatyspeed = -20
	
	f10 = love.graphics.newFont(love.default_font,10)
	f14 = love.graphics.newFont(love.default_font,14)
	f20 = love.graphics.newFont(love.default_font,18)
	
	white = love.graphics.newColor(255,255,255,255)
	twhite = love.graphics.newColor(255,255,255,128)
	ttwhite = love.graphics.newColor(255,255,255,64)
	trwhite = love.graphics.newColor(255,255,255,192)
	tgreen = love.graphics.newColor(0,255,0,128)
	trblack = love.graphics.newColor(0,0,0,192)
	tblack = love.graphics.newColor(0,0,0,128)
	ttblack = love.graphics.newColor(0,0,0,64)
	black = love.graphics.newColor(0,0,0,255)
	
	setupMouse()
	setupWindows()
	
	vol = 0.5
	
	timer = 0
	love.graphics.setColorMode(love.color_modulate)
	onground = false
	
end

function round(n)
	return math.floor(n + 0.5)
end
function lesser(a,b)
	if a < b then return a else return b end
end
function greater(a,b)
	if a < b then return b else return a end
end

function iswall(map,x,y)
	if y <= map[x][1] then return true end
	if y >= map [x][2] then return true end
	return false
end

function update(dt)
	local coins = coinlocs[level]
	
	updateTurretsAndMissiles(dt)
	
	--check for collected coins
	if #coins > 0 then
		for i = #coins,1,-1 do
			local coin = coins[i]
			local x = coin[1]
			local y = coin[2]
			if math.sqrt((player.x-x)*(player.x-x)+(player.y-y)*(player.y-y)) < 1 then
				score = score + 10
				table.insert(floatytexts,{x=(x-0.5)*u,y=(y-0.5)*u,life=floatytexttime})
				table.remove(coinlocs[level],i)
				--!!
			end
		end
	end
	
	--accel if move left/right
	if love.keyboard.isDown(love.key_left) then
		if -accel*dt + player.vel[1] < -speed then
			player.vel[1] = -speed
		else
			player.vel[1] = player.vel[1] - accel*dt
		end
	end
	if love.keyboard.isDown(love.key_right) then
		if accel*dt + player.vel[1] > speed then
			player.vel[1] = speed
		else
			player.vel[1] = player.vel[1] + accel*dt
		end
	end
	--stop if not move left and not move right
	if not love.keyboard.isDown(love.key_left) and not love.keyboard.isDown(love.key_right) then player.vel[1] = 0 end
	
	--jump if up and on ground
	-- and love.keyboard.isDown(love.key_up) --this was removed so autobounce
	if onground and love.keyboard.isDown(love.key_up) then player.vel[2] = -jump end
	
	local dx,dy = player.vel[1],player.vel[2]
	local tryx,tryy = dx*dt,dy*dt
	
	--OFF SCREEN, SO CHANGE SCREEN
	if round(player.x + tryx + 0.5) > xdim then
		nextlevel()
	elseif round(player.x + tryx - 0.5) < 1 then
		prevlevel()
	end
	
	-- DIED, GO BACK TO START
	if player.y > ydim then restartLevel() end
	
	local cmr = true --can move right = true
	local cml = true 
	local cmu = true --can move up = true
	local cmd = true
	
	local map = maps[front]
	
	if iswall(map,round(player.x+tryx+0.5),round(player.y+0.4))
	or iswall(map,round(player.x+tryx+0.5),round(player.y-0.4)) then cmr = false end
	
	if iswall(map,round(player.x+tryx-0.5),round(player.y+0.4)) 
	or iswall(map,round(player.x+tryx-0.5),round(player.y-0.4)) then cml = false end
	
	if iswall(map,round(player.x+0.4),round(player.y+tryy-0.5)) 
	or iswall(map,round(player.x-0.4),round(player.y+tryy-0.5)) then cmu = false end
	
	if iswall(map,round(player.x+0.4),round(player.y+tryy+0.5)) 
	or iswall(map,round(player.x-0.4),round(player.y+tryy+0.5)) then cmd = false end
	
	if cml == false and dx < 0 then dx = 0 player.x = round(player.x) player.vel[1] = 0 end
	if cmr == false and dx > 0 then dx = 0 player.x = round(player.x) player.vel[1] = 0 end
	if cmu == false and dy < 0 then dy = 0 player.y = round(player.y) player.vel[2] = 0 end
	if cmd == false and dy > 0 then dy = 0 player.y = round(player.y) player.vel[2] = 0 end
	
	player.x = player.x + dx*dt
	player.y = player.y + dy*dt
	
	if dx == 0 then player.vel[1] = 0 end--crashed or soemthing
	
	if cmd == true then onground = false player.vel[2] = player.vel[2] + gravity*dt
	else onground = true player.vel[2] = 0 end
	
	table.insert(blurs,{x=player.x,y=player.y})
	
	for i = #floatytexts,1,-1 do
		t = floatytexts[i]
		t.y = t.y + floatyspeed*dt
		t.life = t.life - dt
		if t.life < 0 then
			table.remove(floatytexts,i)
		end
	end
	
		
	
	updateWindows()
	updateMouse()
end

function keypressed(key)
	if key == love.key_z then
		--try to switch layers
		if not iswall(maps[3-front],round(player.x),round(player.y)) then--check for obstacle on other layer
			front = 3-front --toggle between 1 and 2
		end
	end
end

function mousepressed(x,y,button)
	clicked(button)
end

function mousereleased(x,y,button)
	released(button)
end

function valueSliders(name,slider)
	if name == "mspeed" then
		mspeed = slider:getValue()
	elseif name == "rot" then
		rot = slider:getValue()
	elseif name == "cooldown" then
		cooldown = slider:getValue()
	end
end

function buttonAction(name)
	if name == "quit" then
		love.system.exit()
	elseif name == "restart" then
		love.system.restart()
	elseif name == "resume" then
		showhelp = false
	elseif name == "helpon" then
		showhelp = true
	end
end

function draw()
	love.graphics.setLineWidth(1)
	
	for i = 3-front,front,front-3+front do --random way to do back map then front map
		map = maps[i]
		if i == front then love.graphics.setColor(white)
		else love.graphics.setColor(ttwhite) end
		for x = 1,xdim do
			--draw thsi column from top down and down to top
			local lim = map[x]
			for y = 1,lim[1] do
				love.graphics.draw(tile,(x-0.5)*u,(y-0.5)*u,0,tscale)
			end
			for y = lim[2],ydim do
				love.graphics.draw(tile,(x-0.5)*u,(y-0.5)*u,0,tscale)
			end
			--trace vertical difference line (between this column and the previous column)
			if x > 1 then
				local y1 = map[x-1][1] --dir is 1 or 2, meaning from roof or from floor
				local y2 = lim[1]
				love.graphics.line((x-1)*u,(y1)*u,(x-1)*u,(y2)*u)
				local y1 = map[x-1][2] --dir is 1 or 2, meaning from roof or from floor
				local y2 = lim[2]
				love.graphics.line((x-1)*u,(y1-1)*u,(x-1)*u,(y2-1)*u)
			end
			if lim[1] ~= lim[2]-1 then
				love.graphics.line((x-1)*u,(lim[1])*u,(x)*u,(lim[1])*u)
				love.graphics.line((x-1)*u,(lim[2]-1)*u,(x)*u,(lim[2]-1)*u)
			end
		end
	end
	--draw coins
	love.graphics.setColor(255,255,255,255)
	for i,coin in ipairs(coinlocs[level]) do
		local x = coin[1]
		local y = coin[2]
		love.graphics.draw(coinimg,(x-0.5)*u,(y-0.5)*u,0,u/64)
	end
	--remove older blurs
	while #blurs > 30 do
		table.remove(blurs,1)
	end
	
	--name says it all.
	drawTurretsAndMissiles()
	
	--draw blurs
	for i,blur in ipairs(blurs) do
		love.graphics.setColor(0,255,0,i/#blurs*128)
		love.graphics.circle(love.draw_fill,(blur.x-0.5)*u,(blur.y-0.5)*u,i/#blurs*u/2,16)
	end
	
	--draw player
	love.graphics.setColor(tgreen)
	love.graphics.circle(love.draw_fill,(player.x-0.5)*u,(player.y-0.5)*u,u/2,16)
	love.graphics.setColor(white)
	love.graphics.circle(love.draw_line,(player.x-0.5)*u,(player.y-0.5)*u,u/2,16)
	
	--draw floaty text numbers
	for i = #floatytexts,1,-1 do
		t = floatytexts[i]
		love.graphics.setColor(255,255,255,t.life/floatytexttime*255)
		love.graphics.setFont(f14)
		love.graphics.draw('10',t.x,t.y)
	end
	
	--draw UI windows
	drawWindows()
	
	--draw ugly text for debugging
	love.graphics.setColor(white)
	love.graphics.setFont(f20)
	love.graphics.draw('Score: '..score,10,20)
end