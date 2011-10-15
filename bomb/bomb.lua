
Player = Object:new()
function Player:init(nr, x, y)
	self.nr = nr
	self.input = wall.input[nr]
	self.x = x
	self.y = y

	self.color = ({
		"99aa66",
		"7777aa",
	})[nr]

	self.delay = 0
end
function Player:update()

	local input = self.input
	local walls = level.walls
	local x = self.x
	local y = self.y

	if self.delay == 0 then
		self.delay = 15

		if input.right and x < 15 and walls[y][x + 1] == " " then
			self.x = x + 1
		elseif input.left and x > 1 and walls[y][x - 1] == " " then
			self.x = x - 1
		elseif input.up and y > 1 and walls[y - 1][x] == " " then
			self.y = y - 1
		elseif input.down and y < 15 and walls[y + 1][x] == " " then
			self.y = y + 1
		else
			self.delay = 0
		end
	else
		self.delay = self.delay - 1
	end

end
function Player:draw()
	wall:pixel(self.x - 1, self.y - 1, self.color)
end


Level = Object:new()
function Level:init(filename)
	
	local file = io.open(filename)
	self.walls = {}
	self.players = {}

	for y = 1, 15 do
		local row = {}
		local line = file:read()
		for x = 1, 15 do
			local cell = line:sub(x, x)
			if ("1234"):find(cell) then
				table.insert(self.players, Player(tonumber(cell), x, y))
			end
			if ("#m"):find(cell) then
				row[x] = cell
			else
				row[x] = " "
			end
		end
		self.walls[y] = row
	end

end
function Level:update()

	for _, player in ipairs(self.players) do
		player:update()
	end


end
function Level:draw()
	local colors = {
		[" "] = "114411",
		["#"] = "666666",
	}
	for y, row in ipairs(self.walls) do
		for x, cell in ipairs(row) do
			wall:pixel(x - 1, y - 1, colors[cell])
		end
	end

	for _, player in ipairs(self.players) do
		player:draw()
	end

end

