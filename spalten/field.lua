
local gem_colors = {}
gem_colors[0] = "000000"
gem_colors[1] = "ff0000"
gem_colors[2] = "0000ff"
gem_colors[3] = "00ff00"
gem_colors[4] = "ffff00"
gem_colors[5] = "ff00ff"
gem_colors[6] = "00ffff"

Field = Object:new()
function Field:init(pos, keys)
	self.pos = pos
	self.keys = keys
	self.column = {}

	-- init clear grid
	self.grid = {}
	for i = 1, 13 do
		local row = {}
		for j = 1, 6 do
			row[j] = 0
		end
		self.grid[i] = row
	end

	self.opponent = nil
	self.old_input = {}

	-- how many different sorts of gems
	self.level = 5
	-- inverse dropping speed
	self.drop_delay = 30

	self.drop_count = 0

	self:newColumn()
end


function Field:setOpponent(opponent)
	self.opponent = opponent
end


function Field:newColumn()
	self.x = 3
	self.y = 1
	self.column[1] = math.random(self.level)
	self.column[2] = math.random(self.level)
	self.column[3] = math.random(self.level)
end

function Field:rotateColumn()
	local c = self.column
	c[1], c[2], c[3] = c[2], c[3], c[1]
end


function Field:collision()
	if self.x < 1 or self.x > 6 or self.y > 13 then
		return true
	end
	for y = math.max(1, self.y - 2), self.y do
		if self.grid[y][self.x] ~= 0 then
			return true
		end
	end
	return false
end


function Field:update()
	-- look for input events
	local input = {}
	local events = {}
	for event, key in pairs(self.keys) do
		input[event] = love.keyboard.isDown(key)
		events[event] = input[event] and not self.old_input[event]
	end
	self.old_input = input


	-- rotation
	-- TODO: roatation should be possible also in other direction
	if events.rot then
		self:rotateColumn()
	end

	-- x-movement
	local x = self.x
	if events.left then
		self.x = self.x - 1
	end
	if events.right then
		self.x = self.x + 1
	end
	if self:collision() then
		self.x = x
	end

	-- y-movement
	self.drop_count = self.drop_count + 1

	local y = self.y
	if events.down or self.drop_count >= self.drop_delay then
		self.y = self.y + 1
		self.drop_count = 0
	end
	if self:collision() then
		self.y = y

		if self.y < 3 then
			-- TODO: game over!!!

		else
			-- push column to grid
			for y = 1, 3 do
				self.grid[self.y - y + 1][self.x] = self.column[y]
			end
			self.x = 3
			self.y = 1
			self:newColumn()
		end

	end


end


function Field:draw()

	for y = 0, 14 do
		local row = self.grid[y] or {}
		for x = 0, 7 do

			local gem = row[x]
			if y > 0 and x == self.x then
				gem = self.column[self.y - y + 1] or gem
			end

			local color = gem and gem_colors[gem] or "888888"
			wall:pixel(self.pos + x, y, color)
		end
	end

end

