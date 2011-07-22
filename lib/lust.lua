#!/usr/bin/lua

--	lust makes my games executable without the need of love

require "socket"

local do_nothing = function() end
local done

love = {
	keyboard = {
		isDown = function() return false end,
	},
	graphics = {
		getWidth = function() return 16 end,
		getHeight = function() return 15 end,
		setColor = do_nothing,
		rectangle = do_nothing,
	},
	event = {
		push = function(e) done = e == "q" end
	},
	timer = {
		getTime = socket.gettime,
		sleep = function(t) socket.sleep(t / 1000) end
	}
}

require "main"

love.load()

local time = socket.gettime()
local frame = 1 / 60

while not done do

	love.update()
	love.draw()

	local dt = socket.gettime() - time

	socket.sleep(math.max(0, 1 / 60 - dt))

	time = time + frame

end


