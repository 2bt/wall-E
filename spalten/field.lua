Field = Object:new()

require "bot"
require "draw"

function Field:init(pos, key_state)
	self.pos = pos
	self.key_state = key_state

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

	self.score = 0
	self.drop_count = 0
	self.combo_count = 0

	self.column = {}
	self:newColumn()

	self.state = "normal"
	self.state_delay = 0

	self.gems_in_line = {}
	self.opponent = nil

	self.raise = 0
	self.current_raise = 0

	self.input = { dx = 0, rep = 0 }

end


function Field:setOpponent(opponent)
	self.opponent = opponent
end


function Field:raiseField(count)
	self.raise = self.raise + count
	if self.state == "normal" then
		self.state = "wait"
		self.state_delay = 10
	end
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
				self.state_delay = 30
			else
				-- check for gems to be removed from the grid
				self.combo_count = 0
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

					-- initiate lowering of one's field
					-- and raising of opponent's field
					if self.combo_count > 1 then
						self.raise = self.raise - (self.combo_count - 1)
						if self.raise < 0 then
							if self.opponent then
								self.opponent:raiseField(-self.raise)
							end
							self.raise = 0
						end
					end

				end
			end
		end

	elseif self.state == "wait" then
		if self.state_delay == 0 then

			if self.current_raise > self.raise then
				-- lower the field
				self.current_raise = self.current_raise - 1

				for x = 1, 6 do
					for y = 13, 2, -1 do
						self.grid[y][x] = self.grid[y - 1][x]
					end
					self.grid[1][x] = 0
				end
				self.state_delay = 2

			elseif self.current_raise < self.raise then
				-- raise the field
				self.current_raise = self.current_raise + 1
				self.state_delay = 2
				for x = 1, 6 do
					if self.grid[1][x] > 0 then
						self.state = "over"
						self.state_delay = 30
					end
					for y = 1, 12 do
						self.grid[y][x] = self.grid[y + 1][x]
					end
					self.grid[13][x] = -1
				end

			else
				self:newColumn()
				self.state = "normal"
			end
		end

	elseif self.state == "over" then
		-- TODO

		if self.state_delay == 0 then
			love.event.push "q"
		end

	end
end


function Field:findGemsInLine()

	-- TODO: make the code look nicer

	local grid = self.grid

	local function addGem(x, y)
		self.gems_in_line[y .. " " .. x] = { x = x, y = y }	
	end

	-- [-] check
	for y = 1, 13 do
		for x = 1, 4 do
			if grid[y][x] > 0 and
			   grid[y][x] == grid[y][x + 1] and
			   grid[y][x] == grid[y][x + 2] then
				addGem(x, y)
				addGem(x + 1, y)
				addGem(x + 2, y)
				self.combo_count = self.combo_count + 1
			end
		end
	end
	-- [|] check
	for x = 1, 6 do
		for y = 1, 11 do
			if grid[y][x] > 0 and
			   grid[y][x] == grid[y + 1][x] and
			   grid[y][x] == grid[y + 2][x] then
				addGem(x, y)
				addGem(x, y + 1)
				addGem(x, y + 2)
				self.combo_count = self.combo_count + 1
			end
		end
	end
	-- [\] check
	for y = 1, 11 do
		for x = 1, 4 do
			if grid[y][x] > 0 and
			   grid[y][x] == grid[y + 1][x + 1] and
			   grid[y][x] == grid[y + 2][x + 2] then
				addGem(x, y)
				addGem(x + 1, y + 1)
				addGem(x + 2, y + 2)
				self.combo_count = self.combo_count + 1
			end
		end
	end
	-- [/] check
	for y = 1, 11 do
		for x = 3, 6 do
			if grid[y][x] > 0 and
			   grid[y][x] == grid[y + 1][x - 1] and
			   grid[y][x] == grid[y + 2][x - 2] then
				addGem(x, y)
				addGem(x - 1, y + 1)
				addGem(x - 2, y + 2)
				self.combo_count = self.combo_count + 1
			end
		end
	end

	-- return true if we found something
	return next(self.gems_in_line) ~= nil
end



