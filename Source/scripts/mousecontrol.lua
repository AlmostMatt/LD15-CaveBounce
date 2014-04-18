--function to declare all mouserelated variables and constants, run once
function setupMouse()
	--MOUSE STATES (specific values are irrelevant, so long as they are different from each other)
	Generic = 0
	Drag_Window = 1
	
	--MOUSE LOCS (indeces for each window in teh windows list)
	Back_Ground = 1
	Help_Window = 2
	
	--MOUSE INITIAL VALUES
	mouse = {}
	mouse.loc = Back_ground
	mouse.mode = Generic
	mouse.start = {x=0,y=0} --(redefined when I clcik somewhere to start a drag box)
	
end


function updateMouse()
	--MOUSE STATE
	mx = love.mouse.getX()
	my = love.mouse.getY()
	if mouse.mode == Drag_Window then
		--no change to active window, move the window
		local dx,dy = mx-start.x,my-start.y
		start.x,start.y = mx, my
		windows[mouse.loc].minx = windows[mouse.loc].minx + dx
		windows[mouse.loc].miny = windows[mouse.loc].miny + dy
	else
		mouse.loc = Back_Ground --defautl to background
		for i,wind in ipairs(windows) do
			if i ~= Help_Window or showhelp then
				local minx,miny,maxx,maxy = wind.minx,wind.miny,wind.minx+wind.xsize,wind.miny+wind.ysize
				if mx > minx and mx < maxx and my > (miny-WINDOWBARSIZE) and my < maxy then
					mouse.loc = i --latest window that teh mosue is over is teh active window
				end
			end
		end
	end
end


--this is called whenever a mouse button is pressed
function clicked(button)	
	--LEFT CLICK
	if button == love.mouse_left then
		--check for if trying to drag a window around first
		if mouse.loc ~= Back_Ground and
			love.mouse.getY() <= windows[mouse.loc].miny then --mouse is on teh 'top' bar of teh window
			start = {x=love.mouse.getX(),y=love.mouse.getY()}
			mouse.mode = Drag_Window
		end
		--check buttons in active window
		for i,wind in ipairs(windows) do
			if mouse.loc == i then
				for name,b in pairs(wind.buttons) do
					if b:mousepressed(x, y, button) then
						buttonAction(name)
					end
				end
			end
		end
	end
end   


--let go of the mouse button
function released(button)
	if button == love.mouse_left then
		if  mouse.mode == Drag_Window then
			mouse.mode = Generic
		end
	end
end


--DRAW THE MOUSE IN WHATEVER STATE IT IS IN
function drawMouse()
	local mx,my = love.mouse.getPosition()
	--also, for teh heck of it, draw soemthign where teh mouse is
	love.graphics.setColor(twhite)
	love.graphics.setLineWidth(2)
	love.graphics.line(mx-10,my-10,mx+10,my+10)
	love.graphics.line(mx-10,my+10,mx+10,my-10)
	love.graphics.circle(love.draw_line,mx,my,7,16)
end
