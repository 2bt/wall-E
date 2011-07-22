
GRAVITY = 77

Mario = Object:new {
	score = 0,
	coins = 0,
	lives = 3,

	x = 4,
	y = 12,
	dx = 0,
	dy = 0,
	ddy = 0,
	dir = 1,

	big = false,
	fire = false,
	animation = "small",
	state = "normal",
	state_delay = 0,

--	debug stuff
--	x = 100, big = true, fire = true, animation = "fire",

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
		self.animation = "grow"
		self.state_delay = 50
		self.state = "growing"
	elseif t == "flower" then
		if self.fire == false then
			self.big = true
			self.fire = true
			self.animation = "burn"
			self.state_delay = 50
			self.state = "burning"
		end
	elseif t == "star" then
		self.state = "super"
		self.state_delay = 60 * 10
		if self.big then
			if self.fire then
				self.animation = "fire_super"
			else
				self.animation = "big_super"
			end
		else
			self.animation = "small_super"
		end

	end

end


function Mario:hurt()
	if self.big == true then
		self.big = false
		if self.fire == true then
			self.animation = "fire_shrink"
			self.fire = false
		else
			self.animation = "shrink"
		end
		self.state = "shrinking"
		self.state_delay = 50
	else
		self.lives = self.lives - 1
		self.state = "dying"
		self.animation = "small"
		self.state_delay = 120
		self.ddy = 0
		self.dy = -20
	end

end

function Mario:draw()
	local sprites = {
		none			= {},
		small			= { "aa0000" },
		big				= { "0000cc", "aa0000" },
		fire			= { "aaaaaa", "aa0000"},
		fire2			= { "dddddd", "dd0000"},
		small_super		= { "bbbb00" },
		small_super2	= { "ffff00" },
		big_super		= { "ffff00", "ffff00" },
		big_super2		= { "bbbb00", "bbbb00" },
	}

	local animations = {
		small			= { "small" },
		big				= { "big" },
		fire			= { "fire" },
		flash			= { "small", "none" },
		grow			= { "small", "big" },
		shrink			= { "small", "big" },
		fire_shrink		= { "small", "fire" },
		small_super		= { "small", "small_super", "small_super2" },
		big_super		= { "big", "big_super", "big_super2" },
		fire_super		= { "fire", "big_super", "big_super2" },
		burn			= { "big", "fire2" },
	}

	local anim = animations[self.animation]
	local frame = anim[math.floor(tick / 4) % #anim + 1]
	local colors = sprites[frame]

	for i, color in ipairs(colors) do
		level:pixel(self.x, self.y + 1 - i, color)
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
			self.animation = "flash"
		end

	elseif self.state == "flashing" then
		if self.state_delay == 0 then
			self.state = "normal"
			self.animation = "small"
		end

	elseif self.state == "growing" then
		if self.state_delay == 0 then
			self.state = "normal"
			self.animation = "big"
		end

	elseif self.state == "burning" then
		if self.state_delay == 0 then
			self.state = "normal"
			self.animation = "fire"
		end

	elseif self.state == "super" then
		if self.state_delay == 0 then
			self.state = "normal"
			if self.big then
				if self.fire then
					self.animation = "fire"
				else
					self.animation = "big"
				end
			else
				self.animation = "small"
			end
		end

	end


	if self.state ~= "normal" and
	   self.state ~= "flashing" and
	   self.state ~= "super" then
		return
	end

	if self.y > 17 then
		self.big = false
		self:hurt() -- die
	end



	-- x-movement
	local lr = bool[wall.input.right] - bool[wall.input.left]


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

	local jump = wall.input.a

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




