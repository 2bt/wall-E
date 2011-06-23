
GRAVITY = 77

Mario = Object:new {
	big = false,
	fire = false,
	score = 0,
	coins = 0,
	lives = 3,

	x = 4,
	y = 12,
	dx = 0,
	dy = 0,
	ddy = 0,
	dir = 1,

	state = "normal",
	state_delay = 0,

--	x = 100, big = true
}

function Mario:collectCoin()
	self.score = self.score + 200
	self.coins = self.coins + 1
	if self.coins == 100 then
		self.coins = 0
		self.lives = self.lives + 1
	end
end

function Mario:powerup(t)
	mario.score = mario.score + 1000
	if t == "fungus" then
		self.big = true
		self.state_delay = 50
		self.state = "growing"
	elseif t == "flower" then
		self.big = true
		self.fire = true
		self.state_delay = 50
		self.state = "burning"
	elseif t == "star" then
		self.state = "invincible"
		self.state_delay = 60 * 10
	end

end


function Mario:hurt()
	if self.big == true then
		self.big = false
		self.fire = false
		self.state = "shrinking"
		self.state_delay = 50
	else
		self.lives = self.lives - 1
		self.state = "dying"
		self.state_delay = 120
		self.ddy = 0
		self.dy = -20
	end

end


function Mario:draw()

	if self.state == "growing" or self.state == "shrinking" then
		if self.state_delay % 8 < 4 then
			level:pixel(self.x, self.y, "0000cc")
			level:pixel(self.x, self.y - 1, "aa0000")
		else
			level:pixel(self.x, self.y, "aa0000")
		end

	elseif self.state == "flashing" then
		if self.state_delay % 8 < 4 then
			level:pixel(self.x, self.y, "aa0000")	
		end

	elseif self.state == "invincible" then
		if self.big then
			if self.state_delay % 8 < 4 then
				level:pixel(self.x, self.y - 1, "aa0000")
				if self.fire then
					level:pixel(self.x, self.y, "aa9999")
				else
					level:pixel(self.x, self.y, "0000cc")
				end
			else
				level:pixel(self.x, self.y - 1, "ffff00")
				level:pixel(self.x, self.y, "ffff00")
			end
		else
			if self.state_delay % 8 < 4 then
				level:pixel(self.x, self.y, "aa0000")
			else
				level:pixel(self.x, self.y, "ffff00")
			end
		end

	elseif self.state == "burning" then
		level:pixel(self.x, self.y - 1, "aa0000")
		if self.state_delay % 8 < 4 then
			level:pixel(self.x, self.y, "0000cc")
		else
			level:pixel(self.x, self.y, "cc9999")
		end

	else
		if self.big then
			if self.fire then
				level:pixel(self.x, self.y - 1, "aa0000")
				level:pixel(self.x, self.y, "aa8888")
			else
				level:pixel(self.x, self.y - 1, "aa0000")
				level:pixel(self.x, self.y, "0000cc")
			end
		else
			level:pixel(self.x, self.y, "aa0000")
		end
	end
end

function Mario:update()

	-- state stuff
	-- FIXME: split this is several functions
	self.state_delay = self.state_delay - 1

	if self.state == "dying" then

		-- let mario jump of the screen
		if self.state_delay < 100 then
			self.dy = self.dy + 1			-- gravity
			self.ddy = self.ddy + self.dy
			local abs = math.abs(self.ddy)
			if abs > GRAVITY then
				local s = self.ddy / abs
				self.ddy = self.ddy - s * GRAVITY
				self.y = self.y + s
			end
		end

		if self.state_delay == 0 then
			love.event.push "q"
		end

	elseif self.state == "shrinking" then
		if self.state_delay == 0 then
			self.state = "flashing"
			self.state_delay = 180
		end

	elseif self.state == "flashing" or
		   self.state == "growing" or
		   self.state == "burning" or
		   self.state == "invincible" then

		if self.state_delay == 0 then
			self.state = "normal"
		end

	end


	if self.state ~= "normal" and
	   self.state ~= "flashing" and
	   self.state ~= "invincible" then
		return
	end

	if self.y > 17 then
		self.big = false
		self:hurt() -- die
	end



	-- x-movement
	local lr = bool[love.keyboard.isDown "right"] -
				bool[love.keyboard.isDown "left"]

	self.dx = self.dx + lr
	if lr == 0 then
		self.dx = 0
	else
		self.dir = lr
	end

	local abs = math.abs(self.dx)
	if abs > 8 then
		local dir_x = self.dx / abs
		self.dx = 0

		-- collision check
		if not level:enter(dir_x, 0) and
		   not level:isSolid(self.x + dir_x, self.y) then

			if not (self.big and level:isSolid(self.x + dir_x, self.y - 1)) then
				self.x = self.x + dir_x
			end

		end
	end

	-- restrict mario's movement
	if self.x < level.cam_x then
		self.x = level.cam_x
		self.dx = 0
	end
	if self.x >= level.length then
		self.x = level.length - 1
		self.dx = 0
	end


	level:scroll()

	local jump = love.keyboard.isDown " "

	if self.dy == 0 and level:isSolid(self.x, self.y + 1) then
		-- staning on ground

		self.dy = 0
		self.ddy = 0

		if jump and not self.old_jump then
			self.dy = -26
		end

	else
		-- up in air
		self.dy = self.dy + 1 -- gravity

		-- y-movement
		self.ddy = self.ddy + self.dy
		local abs = math.abs(self.ddy)
		if abs > GRAVITY then
			local dir_y = self.ddy / abs
			self.ddy = self.ddy - dir_y * GRAVITY

			local y = self.y + dir_y
			if self.big and dir_y < 0 then
				y = y - 1
			end

			if not level:enter(0, dir_y) then
				if level:isSolid(self.x, y) then
					self.dy = 0
					self.ddy = 0
				else
					self.y = self.y + dir_y
				end
			end

		end
	end

	self.old_jump = jump
end




