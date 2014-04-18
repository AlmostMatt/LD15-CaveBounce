timer = 0
turrets = tmap[1]
missiles = {}
particles = {}
rot = 1
mspeed = 10

--missile and smoke particle images
miss = love.graphics.newImage('images/missile.png')
smoke = love.graphics.newImage('images/smoke.png')
turr = love.graphics.newImage('images/turret.png')

mscale = 1.5*u/miss:getWidth()
cooldown = 1.5

function updateTurretsAndMissiles(dt)
	
	for i,turret in ipairs(turrets) do
		turret.a = math.atan2(player.y-turret.y,player.x-turret.x)
	end
	
	--shoot after cooldown
	timer = timer + dt
	if timer > cooldown then
		timer = 0
		for i,turret in ipairs(turrets) do
			fire(turret)
		end
	end
	if #missiles > 0 then
		for i = #missiles,1,-1 do
			--update the status of the missile/move it etc
			local missile = missiles[i]
		
			--check for collision
			local dx = player.x-missile.x
			local dy = player.y-missile.y
			local dleft = math.sqrt(dx*dx+dy*dy)
			local dead = false
			if dleft < 1 then
				dead = true
				restartLevel() --reset player to level start loc
			end
			if round(missile.x) < 1 or round(missile.x) > xdim then dead = true
			else
				if iswall(maps[front],round(missile.x),round(missile.y)) then
					dead = true
				end
			end
			
			--update angle
			local idealangle = math.atan2(dy,dx)
			if idealangle > missile.angle+math.pi then idealangle = idealangle - 2*math.pi
			elseif idealangle < missile.angle-math.pi then idealangle = idealangle + 2*math.pi end
			if missile.angle < idealangle then
				missile.angle = missile.angle + rot*dt
			elseif missile.angle > idealangle then
				missile.angle = missile.angle - rot*dt
			end
			
			--update position
			dx,dy = math.cos(missile.angle)*mspeed*dt,math.sin(missile.angle)*mspeed*dt
			missile.x = missile.x + dx
			missile.y = missile.y + dy
			
			--add awesome trail particles
			trailBit(missile.x*u,missile.y*u,missile.angle)
			
			--destroy if necessary
			if dead then
				addBoom(missile.x*u,missile.y*u)
				table.remove(missiles,i)
				missile = nil
			end
		end
	end
	--update explosions
	updateBoom(dt)
end

function drawTurretsAndMissiles()
	love.graphics.setColor(255,255,255,255)
	drawBoom()
	for i,missile in ipairs(missiles) do
		love.graphics.draw(miss,(missile.x-0.5)*u,(missile.y-0.5)*u,math.deg(missile.angle)+90,mscale)
	end
	for i,turret in ipairs(turrets) do
		love.graphics.draw(turr,(turret.x-0.5)*u,(turret.y-0.5)*u,math.deg(turret.a)+90,mscale)
	end
end

function fire(turret)
	local newm = {
		x = turret.x,
		y = turret.y,
		angle = turret.a,
	}
	table.insert(missiles,newm)
end

function addBoom(x,y)
	for r = 1,15 do
		--make an explosion!
		local c1 = love.graphics.newColor(255,255,0,128)
		local c2 = love.graphics.newColor(255,0,0,0)
		local v1 = math.random(10,200)
		local v2 = v1*2
		local p = love.graphics.newParticleSystem(smoke, 1000)
		p:setEmissionRate(100)
		p:setSpeed(v1,v2)
		p:setSize(0.3,0.2)
		p:setColor(c1,c2)
		p:setPosition(x, y)
		p:setLifetime(0.1)
		p:setParticleLife(0.2,0.3)
		p:setDirection(math.random(1,360))
		p:setSpread(1)
		p:setTangentialAcceleration(1000)
		p:setRadialAcceleration(-3000)
		p:start()
		table.insert(particles,p)
	end
end
function trailBit(x,y,angle)
	local c1 = love.graphics.newColor(255,255,255,255)
	local c2 = love.graphics.newColor(0,0,0,0)
	local p = love.graphics.newParticleSystem(smoke, 10)
	p:setEmissionRate(100)
	p:setSpeed(100, 300)
	p:setSize(0.15,0.1)
	p:setColor(c1,c2)
	p:setPosition(x, y)
	p:setLifetime(0.04)
	p:setParticleLife(0.2,0.4)
	p:setDirection(math.deg(angle)+180)
	p:setSpread(3)
	p:setTangentialAcceleration(00)
	p:setRadialAcceleration(500)
	p:start()
	table.insert(particles,p)
end

function updateBoom(dt)
	if #particles > 0 then
		for i = #particles,1,-1 do
			p = particles[i]
			p:update(dt)
			if p:isEmpty() then
				p = nil
				table.remove(particles,i)
			end
		end
	end
end
function drawBoom()
	for i,p in ipairs(particles) do
		love.graphics.draw(p,-0.5*u,-0.5*u)
	end
end

function removeMissiles() --no explosions, just poof gone
	--something to get rid of old missiles when change screen
	if #missiles > 0 then
		for i=#missiles,1,-1 do
			missiles[i] = nil
			table.remove(missiles,i)
		end
	end
	if #particles > 0 then
		for i = #particles,1,-1 do
			particles[i] = nil
			table.remove(particles,i)
		end
	end
end