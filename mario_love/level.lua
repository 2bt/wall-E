
Level = Object:new()

Level.static_colors = {
	[" "] = "8888cc",	-- background
	["Z"] = "770000",	-- wall
	["B"] = "552222",	-- wall two
	["c"] = "552222",	-- background wall
	["x"] = "111111",	-- black
	["w"] = "bbbbbb",	-- clouds
	["b"] = "11aa11",	-- bushes
	["g"] = "44aa44",	-- grass
	["T"] = "007700",	-- tube
	["E"] = "006600",	-- tube top
}

Level.entity_registry = {}

function Level:registerEntity(chars, class)
	for c in chars:gmatch "." do
		self.entity_registry[c] = class
	end
end

function Level:init(filename)

	self.static = {}
	self.entities = {}
	self.cam_x = 0

	local getrow = io.open(filename):lines()

	-- read the first 15 lines of static level data
	local x = 0
	for y = 0, 14 do
		x = 0
		local row = {}
		for c in getrow():gmatch "." do
			row[x] = c
			x = x + 1
		end
		self.static[y] = row
	end

	self.length = x

	-- read the next 15 lines of dynamic objects
	for y = 0, 14 do
		x = 0
		for c in getrow():gmatch "." do
			local class = self.entity_registry[c]
			if class then
				self:addEntitiy(class(x, y, c))
			end
			x = x + 1
		end
	end
end

function Level:pixel(x, y, c)
	wall:pixel(x - self.cam_x, y, c)
end


function Level:addEntitiy(entity)
	table.insert(self.entities, entity)
end

function Level:removeEntitiy(entity)
	for i, e in pairs(self.entities) do
		if entity == e then
			table.remove(self.entities, i)
			return
		end
	end
end

function Level:entitiesAt(x, y)
	local i = 0
	local entities = self.entities
	return function()
		local e
		repeat
			i = i + 1
			e = entities[i]
		until e == nil or (e.x == x and e.y == y)
		return e
	end
end

function Level:scroll()
	if self.cam_x < mario.x - 10 then
		self.cam_x = mario.x - 10
		if self.cam_x > self.length - 16 then
			self.cam_x = self.length - 16
		end
	end
end

function Level:update()
	for _, e in ipairs(self.entities) do
		if e.x < self.cam_x + 16 then
			e.active = true
		end
		if e.active then
			e:update()
			if e.x == mario.x and
			   (e.y == mario.y or (mario.big and e.y == mario.y - 1)) then
				e:touch()
			end
		end
	end
end

function Level:isSolid(x, y)
	if 0 <= x and x < self.length and 0 <= y and y < 15 then
		if self.static[y][x]:find "%u" then
			return true
		end
	end
	for e in self:entitiesAt(x, y) do
		if e.solid then
			return true
		end
	end
	return false
end

function Level:enter(dir_x, dir_y)
	local x = mario.x + dir_x
	local y = mario.y + dir_y
	if mario.big and dir_y < 0 then
		y = y - 1
	end

	local res = false
	for e in self:entitiesAt(x, y) do
		res = e:enter(dir_x, dir_y) or res
	end
	return res
end


function Level:draw()

	for y, row in pairs(self.static) do
		for x = 0, 16 do
			local color = self.static_colors[row[x + self.cam_x]]
			wall:pixel(x, y, color)
		end
	end

	-- render dynamic stuff
	for _, e in pairs(self.entities) do
		e:draw()
	end

end


