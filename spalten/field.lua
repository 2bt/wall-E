Field = Object:new()

function Field:init(pos, keys)
	self.pos = pos
	self.keys = keys

	-- init clear grid
	self.grid = {}
	for i = 1, 13 do
		local row = {}
		for j = 1, 6 do
			row[j] = 0
		end
		self.grid[i] = row
	end


	-- how many different sorts of gems
	self.level = 5
	-- inverse dropping speed
	self.drop_delay = 20

	self.drop_count = 0
	self.combo_count = 0
	self.score = 0

	self.column = {}
	self:newColumn()
	self.state = "normal"
	self.state_delay = 0

	self.gems_in_line = {}
	self.opponent = nil

	self.input = { dx = 0, rep = 0 }

end


function Field:setOpponent(opponent)
	self.opponent = opponent
end


function Field:getInput()

	local events = {}

	local dx = bool[love.keyboard.isDown(self.keys.right)] -
			   bool[love.keyboard.isDown(self.keys.left)]

	if dx ~= self.input.dx then
		self.input.rep = 0
	end
	self.input.dx = dx
	self.input.rep = self.input.rep - 1
	if self.input.rep <= 0 then
		events.dx = dx
		self.input.rep = 3
	else
		events.dx = 0
	end

	events.down = love.keyboard.isDown(self.keys.down)

	events.rot = love.keyboard.isDown(self.keys.rot) and not self.input.rot
	self.input.rot = love.keyboard.isDown(self.keys.rot)

	return events
end


function Field:newColumn()
	self.x = 3
	self.y = 1
	self.column[1] = math.random(self.level)
	self.column[2] = math.random(self.level)
	self.column[3] = math.random(self.level)
end


function Field:pushColumn()
	for y = 1, 3 do
		if self.y - y + 1 > 0 then
			self.grid[self.y - y + 1][self.x] = self.column[y]
		end
	end
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


function Field:collapse()
	local grid = self.grid
	local ret = false
	for x = 1, 6 do
		local drop = false
		for y = 13, 1, -1 do
			drop = drop or grid[y][x] == 0
			if drop then
				grid[y][x] = grid[y - 1] and grid[y - 1][x] or 0
				ret = grid[y][x] > 0 or ret
			end
		end
	end
	return ret
end


function Field:update()

	self.state_delay = self.state_delay - 1
	if self.state == "normal" then

		local events = self:getInput()

		if events.rot then
			local c = self.column
			c[1], c[2], c[3] = c[3], c[1], c[2]
		end
		-- x-movement
		if events.dx ~= 0 then
			local x = self.x
			self.x = self.x + events.dx
			if self:collision() then
				self.x = x
			end
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

			self:pushColumn()
			if self.y < 3 then
				self.state = "over"
			else
				-- check for gems to be removed from the grid
				if self:findGemsInLine() then
					self.state = "highlight"
					self.state_delay = 20
				else
					self.state = "wait"
					self.state_delay = 10
				end
			end
		end

	elseif self.state == "highlight" then
		if self.state_delay == 0 then

			-- remove gems
			for _, coords in pairs(self.gems_in_line) do
				self.grid[coords.y][coords.x] = 0
				self.score = self.score + 1
			end
			self.gems_in_line = {}

			self.state = "collapse"
			self.state_delay = 2
		end

	elseif self.state == "collapse" then
		if self.state_delay == 0 then

			if self:collapse() then
				-- keep collapsing
				self.state_delay = 2
			else
				if self:findGemsInLine() then
					self.state = "highlight"
					self.state_delay = 20
				else
					self.state = "wait"
					self.state_delay = 10
				end
			end
		end

	elseif self.state == "wait" then
		if self.state_delay == 0 then
			self:newColumn()
			self.state = "normal"
		end

	elseif self.state == "over" then
		-- TODO
	end

end


function Field:findGemsInLine()

	-- TODO: make the code look nicer
	local buf = self.gems_in_line
	local grid = self.grid

	-- [-] check
	for y = 1, 13 do
		for x = 1, 4 do
			if grid[y][x] > 0 and
			   grid[y][x] == grid[y][x + 1] and
			   grid[y][x] == grid[y][x + 2] then
				local gem = grid[y][x]
				while grid[y][x] == gem do
					buf[y .. " " .. x] = { x = x, y = y }
					x = x + 1
				end
			end
		end
	end
	-- [|] check
	for x = 1, 6 do
		for y = 1, 11 do
			if grid[y][x] > 0 and
			   grid[y][x] == grid[y + 1][x] and
			   grid[y][x] == grid[y + 2][x] then
				local gem = grid[y][x]
				while y <= 13 and grid[y][x] == gem do
					buf[y .. " " .. x] = { x = x, y = y }
					y = y + 1
				end
			end
		end
	end
	-- [\] check
	for y = 1, 11 do
		for x = 1, 4 do
			if grid[y][x] > 0 and
			   grid[y][x] == grid[y + 1][x + 1] and
			   grid[y][x] == grid[y + 2][x + 2] then
				local gem = grid[y][x]
				local i = y
				while i <= 13 and grid[i][x] == gem do
					buf[i .. " " .. x] = { x = x, y = i }
					x = x + 1
					i = i + 1
				end
			end
		end
	end
	-- [/] check
	for y = 1, 11 do
		for x = 3, 6 do
			if grid[y][x] > 0 and
			   grid[y][x] == grid[y + 1][x - 1] and
			   grid[y][x] == grid[y + 2][x - 2] then
				local gem = grid[y][x]
				local i = y
				while i <= 13 and grid[i][x] == gem do
					buf[i .. " " .. x] = { x = x, y = i }
					x = x - 1
					i = i + 1
				end
			end
		end
	end

	-- return true if we found something
	return next(buf) ~= nil
end


local gem_colors = {}

gem_colors[-1] = "666666"	-- brick
gem_colors[0] = "000000"	-- background

gem_colors[1] = "bb0000"
gem_colors[2] = "0000bb"
gem_colors[3] = "00bb00"
gem_colors[4] = "bbbb00"
gem_colors[5] = "bb00bb"
gem_colors[6] = "00bbbb"


function Field:draw()

	for y = 0, 14 do
		local row = self.grid[y] or {}
		for x = 0, 7 do

			local gem = row[x]
			if self.state == "normal" and y > 0 and x == self.x then
				-- also draw active column
				gem = self.column[self.y - y + 1] or gem
			end

			local color = gem and gem_colors[gem] or "888888"
			wall:pixel(self.pos + x, y, color)
		end
	end

	-- draw flashing gems
	if self.state == "highlight" then
		for _, coords in pairs(self.gems_in_line) do
			local color = ({ "ffffff", "000000" })[self.state_delay % 3 + 1]
			if color then
				wall:pixel(self.pos + coords.x, coords.y, color)
			end
		end
	end

end

