WINDOWBARSIZE = 20
questionmark = love.graphics.newImage('images/helpme.png')

function setupWindows()
	windows = {}
	
	background = {
		minx = 1,
		miny = 1,
		xsize = 800,
		ysize = 400,
		buttons = {['helpon'] = Button.createI(questionmark,5,375,20,20)},
		sliders = {}
	}
	help = {
		minx = 270,
		miny = 50,
		xsize = 260,
		ysize = 335,
		d = function () drawHelp() end,
		--BUTTONS
		buttons = {
			["resume"] = Button.createT("OK",90,260,80,20),
			["restart"] = Button.createT("Restart",90,285,80,20),
			["quit"] = Button.createT("Quit",90,310,80,20),
		},
		sliders = {}
	}
	showhelp = true
	helpimg = love.graphics.newImage('images/help.png')
	
	table.insert(windows,background)
	table.insert(windows,help)
	
	return windows
end


function drawHelp()
	love.graphics.setColor(white)
	love.graphics.draw(helpimg,minx+xsize/2,miny+128)
end


--Generic x windows drawing/updating
function updateWindows(dt)
	for i=1,#windows do
		wind = windows[i]
		if mouse.loc == i then
			--sliders and buttons
			for name,b in pairs(wind.buttons) do b:update(dt) end
			for name,s in pairs(wind.sliders) do
				s:update(dt)
				valueSliders(name,s)
			end
			--
		end
	end
end

function drawWindows()
	for i= 1,#windows do
		wind = windows[i]
		if i ~= Help_Window or showhelp then
			minx,miny,xsize,ysize = wind.minx,wind.miny,wind.xsize,wind.ysize
			if i > 1 then
				--override the last min and size values with those of the current wind
				minx,miny,xsize,ysize = wind.minx,wind.miny,wind.xsize,wind.ysize
				love.graphics.setColor(trwhite)
				love.graphics.rectangle(love.draw_fill,minx,miny,xsize,ysize)
				
				--create a scissor of the game wind so nothiNg is drawn outside of it (IE, particles too close to the edge)
				love.graphics.setScissor(minx,miny,xsize,ysize)
				wind.d()
				--draw any buttons in the wind
			end
			
			if i > 1 or showhelp == false then 
				for name,b in pairs(wind.buttons) do b:draw() end
			end
			
			if i > 1 then
				for name,s in pairs(wind.sliders) do s:draw() end
				--remove the scissor
				
				love.graphics.setScissor()
				drawSkin(wind)
			end
			
		end
	end
end

function drawSkin()
	--
	love.graphics.setColor(tgreen)
	love.graphics.rectangle(love.draw_fill,minx,miny-WINDOWBARSIZE,xsize,WINDOWBARSIZE)
	--
	love.graphics.setColor(black)
	love.graphics.setLineWidth(3)
	love.graphics.rectangle(love.draw_line,minx,miny-WINDOWBARSIZE,xsize,ysize+WINDOWBARSIZE)	
	love.graphics.line(minx,miny,minx+xsize,miny)
	love.graphics.setFont(f14)
	love.graphics.setColor(white)
end

--convert from actual mosue coordinates to localized windwo coordinates
function screen2window(x,y)
	return x-windows[mouse.loc].minx,y-windows[mouse.loc].miny
end