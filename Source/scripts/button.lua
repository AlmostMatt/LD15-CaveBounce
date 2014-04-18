-----------------------
-- Created: 23.08.08 by Michael Enger
-- Website: http://www.facemeandscream.com
-- Licence: ZLIB
-----------------------
-- Handles buttons and such.
-----------------------

-----------------------
--Modified: 25.08.09 by Matthew Hyndman
-----------------------
-- x,y coordinates given when creating the button is the topleft point
-- buttons have width and height paramaters
-- able to handle image buttons
-- rectangle and outline for button, not just image/text
-----------------------
--Modified: 26.08.09 by Matthew Hyndman
-----------------------
--supertweaked, now is awesome compatible with my windows script
--and probably incompatible with everything else. Oh well, thus is life.
-----------------------

Button = {}
Button.__index = Button

function Button.createT(text,x,y,width,height)
	
	local temp = {}
	setmetatable(temp, Button)
	temp.type = 'text'
	temp.hover = false -- whether the mouse is hovering over the button
	temp.click = false -- whether the mouse has been clicked on the button
	temp.text = text -- the text in the button
	temp.width = width
	temp.height = height
	temp.x = x
	temp.y = y
	return temp
	
end

function Button.createI(image,x,y,width,height)
	
	local temp = {}
	setmetatable(temp, Button)
	temp.type = 'image'
	temp.hover = false -- whether the mouse is hovering over the button
	temp.image = image -- the image in the button
	temp.width = width
	temp.height = height
	temp.x = x
	temp.y = y
	return temp
	
end

function Button:draw()
	if self.hover then love.graphics.setColor(twhite)
	else love.graphics.setColor(ttblack) end
	--back rectangle fill
	love.graphics.rectangle(love.draw_fill,self.x+minx,self.y+miny,self.width,self.height)
	--text/image
	love.graphics.setColor(black)
	if self.type == 'text' then
		love.graphics.setFont(f20)
		local imwid = f20:getWidth(self.text)
		local imhei = f20:getHeight()
		love.graphics.draw(self.text, self.x + (self.width-imwid)/2 + minx, self.y + self.height - (self.height-imhei)/2 - 2 + miny)
	elseif self.type == 'image' then
		love.graphics.setColor(white)
		local imwid = self.image:getWidth()
		local imhei = self.image:getHeight()
		local margin = 2 -- small gap between image and borders
		local scale = lesser(self.width/(imwid+margin),self.height/(imhei+margin))
		love.graphics.draw(self.image, self.x + (self.width/2) + minx, self.y + (self.height/2) + miny,0,scale)
	end
	--outer border line
	love.graphics.setColor(black)
	love.graphics.setLineWidth(2)
	love.graphics.rectangle(love.draw_line,self.x + minx,self.y + miny,self.width,self.height)
end

function Button:update(dt)
	self.hover = false
	local x, y = screen2window(love.mouse.getPosition())
	if x > self.x
		and x < self.x + self.width
		and y > self.y
		and y < self.y + self.height then
		self.hover = true
	end
end

function Button:mousepressed(x, y, button)
	if self.hover then
		return true
	end
	return false
end
