
-- the little mushroom enemy
Goomba = GroundPatrol:new {
	color = "883322",
	step_time = 22,
	dir = -1,

}

Level:registerEntity("ao", Goomba)

function Goomba:init(x, y, c)
	self:super(x, y)
	if c == "o" then self.dir = 1 end
end


function Goomba:enter(dir_x, dir_y)
	if mario.state ~= "super" and dir_y > 0 then
		mario.ddy = 0
		mario.dy = -17
		self:die(false)
		return true
	end
end

function Goomba:deathJump()
	self.dy = -20
	self.dir = mario.dir

	self.touch = Entity.touch

	self.bounce = Entity.bounce

	self.update = function(self)
		self.dx = self.dx + 1
		if self.dx > self.step_time then
			self.dx = 0
			self.x = self.x + self.dir
		end

		self.dy = self.dy + 1
		self.ddy = self.ddy + self.dy
		local abs = math.abs(self.ddy)
		if abs > GRAVITY then
			local s = self.ddy / abs
			self.ddy = self.ddy - s * GRAVITY
			self.y = self.y + s
		end

		if self.y > 17 then
			level:removeEntitiy(self)
		end
	end
end

function Goomba:die(jump)
	mario.score = mario.score + 100
	if jump then
		self:deathJump()
	else
		level:removeEntitiy(self)
	end
end


function Goomba:bounce()
	self:die(true)
end

function Goomba:touch()
	if mario.state == "normal" then
		mario:hurt()
	elseif mario.state == "super" then
		self:die(true)
	end
end


