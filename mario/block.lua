
Block = Entity:new()

-- TODO: write a legend - document block types
Level:registerEntity("sbBecfi", Block)

function Block:init(x, y, c)
	self:super(x, y)
	self.c = c
	self.solid = not ("s" == c)

	if c == "c" then
		self.coins = 1
	elseif c == "B" then
		self.coins = 15
	end

end

function Block:draw()

	if self.c == "s" then return end

	local blink = ({
		"ddcc00",
		"ccbb00",
		"998800",
		"ccbb00"
	})[math.floor(tick / 12) % 4 + 1]

	local color = ({
		["b"] = "552222",
		["i"] = "552222",
		["B"] = "552222",
		["e"] = "aa8800",
		["c"] = blink,
		["f"] = blink,
	})[self.c]

	level:pixel(self.x, self.y, color)

end

function Block:enter(dir_x, dir_y)

	-- only consider the case of mario headbutting the block
	if dir_y ~= -1 then
		return
	end

	if self.c ~= "e" then
		for e in level:entitiesAt(self.x, self.y - 1) do
			e:bounce()
		end
	end


	if self.c == "b" then
		mario.dy = 0
		mario.ddy = 0
		if mario.big then
			level:removeEntitiy(self)
		end
		return true

	elseif self.c == "c" or self.c == "B" then
		mario:collectCoin()
		level:addEntitiy(CoinFlash(self.x, self.y - 1))
		self.coins = self.coins - 1
		if self.coins == 0 then
			self.c = "e"
		end

	elseif self.c == "f" then
		if mario.big then
			level:addEntitiy(Flower(self.x, self.y - 1))
		else
			level:addEntitiy(Fungus(self.x, self.y - 1))
		end
		self.c = "e"

	elseif self.c == "i" then	-- star
		level:addEntitiy(Star(self.x, self.y - 1))
		self.c = "e"


	elseif self.c == "s" then	-- hidden 1up
		self.solid = true
		level:addEntitiy(Fungus(self.x, self.y - 1, true))
		self.c = "e"

	end
end


