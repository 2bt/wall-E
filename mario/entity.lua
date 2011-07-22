
Entity = Object:new {
	solid = false,
	active = false,
	color = "ff00ff"
}

function Entity:init(x, y)
	self.x = x
	self.y = y
end

function Entity:draw()
	level:pixel(self.x, self.y, self.color)
end

function Entity:update() end

-- called when mario touches the cell
function Entity:touch() end

-- called when mario enters the cell
function Entity:enter(dir_x, dir_x)
	-- return true if you handle the event and manipulate mario's movement
	return false
end

-- called when object is ontop of a block that got headbutted
function Entity:bounce() end


-- an entity that can move on the ground; affected by gravity
GroundPatrol = Entity:new {
	dx = 0,
	dy = 0,
	ddy = 0,

	-- meaningful default values
	step_time = 20,
	dir = 1,
}

function GroundPatrol:update()

	self.dx = self.dx + 1
	if self.dx > self.step_time then
		self.dx = 0

		-- collision check
		if level:isSolid(self.x + self.dir, self.y) then
			self.dir = -self.dir
		else
			-- FIXME
			local move = self.dir
			for e in level:entitiesAt(self.x + self.dir, self.y) do
				if getmetatable(self) == getmetatable(e) then
					self.dir = -self.dir
					e.dir = -e.dir
					move = 0
				end
			end
			self.x = self.x + move
		end
	end

	-- y-movement
	if self.dy ~= 0 or not level:isSolid(self.x, self.y + 1) then

		-- gravity
		self.dy = self.dy + 1
		self.ddy = self.ddy + self.dy

		local abs = math.abs(self.ddy)
		if abs > GRAVITY then
			local dir_y = self.ddy / abs
			self.ddy = self.ddy - dir_y * GRAVITY

			-- collision check
			if level:isSolid(self.x, self.y + dir_y) then
				self.dy = 0
				self.ddy = 0
			else
				self.y = self.y + dir_y
			end
		end
	end
end


-- simple particle object
CoinFlash = Entity:new { color = "eedd00", tick = 0 }


function CoinFlash:update()
	self.tick = self.tick + 1
	if self.tick % 3 == 0 then
		self.y = self.y - 1
	end
	if self.tick > 8 then
		level:removeEntitiy(self)
	end
end


