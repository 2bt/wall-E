

Fungus = GroundPatrol:new {
	step_time = 15,
	dy = -15
}

function Fungus:init(x, y, oneup)
	self:super(x, y)
	self.oneup = oneup

	if oneup then
		self.color = "aaeeaa"
	else
		self.color = "ccaa77"
	end

end

function Fungus:bounce()
	-- let the fungus jump
	self.dy = -17
end

function Fungus:touch()
	level:removeEntitiy(self)

	if self.oneup then
		mario.lives = mario.lives + 1
	else
		mario:powerup("fungus")
	end

end


Flower = Entity:new()

function Flower:touch()
	level:removeEntitiy(self)
	mario:powerup("flower")
end

function Flower:draw()
	local color = ({
		"ff0000",
		"99bb00",
	})[math.floor(tick / 4) % 2 + 1]

	level:pixel(self.x, self.y, color)
end


Star = GroundPatrol:new {
	step_time = 15,
	dy = -20,
}

function Star:touch()
	level:removeEntitiy(self)
	mario:powerup("star")
end


function Star:draw()
	local color = ({
		"ffff00",
		"ffffff",
	})[math.floor(tick / 4) % 2 + 1]

	level:pixel(self.x, self.y, color)
end

function Star:update()

	GroundPatrol.update(self)
	if self.dy == 0 and level:isSolid(self.x, self.y + 1) then
		self.dy = -20
	end


end





