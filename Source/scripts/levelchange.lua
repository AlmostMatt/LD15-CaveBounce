function nextlevel()
	player.x = 1.1
	level = level + 1
	if level > #levels then level = 1 end
	maps = levels[level] --pick new maps
	setSpawnPoint()
	blurs = {}
	turrets = tmap[level]
	for i,t in ipairs(turrets) do t.a = 0 end--make sure all turrets HAVE an angle
	removeMissiles()
end

function prevlevel()
	player.x = xdim-0.1
	level = level - 1
	if level < 1 then level = #levels end
	maps = levels[level] --pick new maps
	setSpawnPoint()
	blurs = {}
	turrets = tmap[level]
	for i,t in ipairs(turrets) do t.a = 0 end
	removeMissiles()
end

function setSpawnPoint()
	spawnpoint = {x = player.x,y = player.y}
end

function restartLevel()
	player.x = spawnpoint.x
	player.y = spawnpoint.y
	player.vel = {0,0}
	blurs = {}
end