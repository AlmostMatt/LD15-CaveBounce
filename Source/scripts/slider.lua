--Similar  to buttons, but different

Slider = {}
Slider.__index = Slider

sliderboxsize = 8

function Slider.create(x,y,min,max,width,text)
	local temp = {}
	setmetatable(temp, Slider)
	temp.x = x
	temp.y = y
	temp.text = text
	temp.width = width
	temp.pos = 0.5
	temp.min = min
	temp.max = max
	temp.hover = false
	return temp
end

function Slider:update(dt)
	local mx,my = screen2window(love.mouse.getPosition())
	if mx >= self.x and mx <= self.x+self.width and my >= self.y-sliderboxsize and my <= self.y+sliderboxsize then
		self.hover = true
		if love.mouse.isDown(love.mouse_left) then
			self.pos = (mx-self.x)/self.width
		end
	end
end

function Slider:getValue()
	return self.min + (self.max-self.min)*self.pos
end

function Slider:draw()
	--
	love.graphics.setColor(white)
	love.graphics.setLineWidth(3)
	love.graphics.line(minx+self.x,miny+self.y,minx+self.x+self.width,miny+self.y)
	--
	love.graphics.setColor(white)
	love.graphics.circle(love.draw_fill,minx+self.x + self.pos*(self.width),miny+self.y,sliderboxsize,16)
	love.graphics.setColor(trblack)
	love.graphics.setLineWidth(2)
	love.graphics.circle(love.draw_line,minx+self.x + self.pos*(self.width),miny+self.y,sliderboxsize,16)
	--
	love.graphics.setColor(white)
	love.graphics.setFont(f10)
	local thei = f10:getHeight()
	local twid = f10:getWidth(self.min)
	love.graphics.draw(self.min,self.x+minx-twid,self.y+miny+thei/2-2)
	love.graphics.draw(self.max,self.x+self.width+minx,self.y+miny+thei/2-2)
	--
	love.graphics.setFont(f10)
	love.graphics.draw(self.text .. ': ' .. self:getValue(), minx+self.x, miny + self.y - 10)
	--
end