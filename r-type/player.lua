Container = Object:new()
function Container:add(x)
	table.insert(self, x)
end
function Container:remove(x)
	for i, k in ipairs(self) do
		if k == x then
			table.remove(self, i)
			return
		end
	end
end
Container.each = table.foreach

lasers = Container()


Laser = Object:new()
function Laser:init(x, y)
	self.x = x
	self.y = y
end
function Laser:update()
	self.x = self.x + 1
end
function Laser:draw()
	wall:pixel(self.x, self.y, "00bb00")
end



Player = Object:new()
function Player:init()

	self.x = 3
	self.y = 7

	self.speed = 3

	self.cx = 0
	self.cy = 0

end
function Player:update()

	local dx = bool[wall.input[1].right] - bool[wall.input[1].left]
	if dx ~= 0 then
		self.cx = self.cx + dx
		if math.abs(self.cx) > self.speed then
			self.cx = 0
			self.x = self.x + dx
		end
	else
		if self.cx > 0 then
			self.cx = self.cx - 1
		elseif self.cx < 0 then
			self.cx = self.cx + 1
		end
	end


	local dy = bool[wall.input[1].down] - bool[wall.input[1].up]
	if dy ~= 0 then
		self.cy = self.cy + dy
		if math.abs(self.cy) > self.speed then
			self.cy = 0
			self.y = self.y + dy
		end
	else
		if self.cy > 0 then
			self.cy = self.cy - 1
		elseif self.cy < 0 then
			self.cy = self.cy + 1
		end
	end

	if wall.input[1].a then
		lasers:add(Laser(player.x, player.y))
	end

end
function Player:draw()

	wall:pixel(self.x, self.y, "777777")
	wall:pixel(self.x - 1, self.y, "778888")

	local colors = {"000000", "000000", "774400", "aa6600", "774400"}
	wall:pixel(self.x - 2, self.y, colors[tick % #colors + 1])

end

