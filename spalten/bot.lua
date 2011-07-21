

function Field:getInput()

	local key_down = {}
	if self.key_state then
		-- human
		key_down.right = self.key_state.right
		key_down.left = self.key_state.left
		key_down.down = self.key_state.down
		key_down.rot = self.key_state.a

	else
		-- bot
		key_down = self:bot()
	end

	local events = {}
	local dx = bool[key_down.right] - bool[key_down.left]
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
	events.down = key_down.down
	events.rot = key_down.rot and not self.input.rot
	self.input.rot = key_down.rot

	return events
end


function Field:bot()

	-- stateless bot - very inefficient, but it kinda works
	-- go through all moves, choose the 'best'

	local save_x = self.x
	local save_y = self.y

	local moves = {}
	-- do nothing if no move can be found
	moves[0] = {
		{ x = self.x, rot = 0 }
	}

	for rot = 0, 2 do
		for x = 1, 6 do
			self.x = x
			self.y = save_y
			if not self:collision() then
				repeat
					self.y = self.y + 1
				until self:collision()
				self.y = self.y - 1
				if self.y >= 3 then
					self:pushColumn()

					self:findGemsInLine()
					local magic = self.combo_count * 4
					for y2 = 1, 13 do
						if math.max(unpack(self.grid[y2])) > 0 then
							magic = magic + y2
							break
						end
					end

					if not moves[magic] then
						moves[magic] = {}
					end
					table.insert(moves[magic], { x = x, rot = rot })

					self.gems_in_line = {}
					self.combo_count = 0


					-- reverse the push
					self.grid[self.y][self.x] = 0
					self.grid[self.y - 1][self.x] = 0
					self.grid[self.y - 2][self.x] = 0
				end

			end
		end

		-- rotate
		local c = self.column
		c[1], c[2], c[3] = c[3], c[1], c[2]
	end
	self.x = save_x
	self.y = save_y

	-- select any of the best moves
	local max_magic = 0
	for i, l in pairs(moves) do
		if i > max_magic then
			max_magic = i
		end
	end

	local best_move = moves[max_magic][1]
	for _, move in ipairs(moves[max_magic]) do
		if math.abs(move.x - self.x) < math.abs(best_move.x - self.x) then
			best_move = move
		end
	end

	local key_down = {}

	-- easy bot
	key_down.left = self.x > best_move.x and math.random(10) == 1
	key_down.right = self.x < best_move.x and math.random(10) == 1
	key_down.down = self.x == best_move.x and self.y > math.random(10)
	key_down.rot =  best_move.rot > 0 and math.random(3) == 1

--[[
	-- fast bot
	key_down.left = self.x > best_move.x
	key_down.right = self.x < best_move.x
	key_down.down = self.x == best_move.x or math.random(3) == 1
	key_down.rot =  best_move.rot > 0 and math.random(2) == 1
--]]

	return key_down
end

