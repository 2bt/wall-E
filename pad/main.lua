player = 1

require "socket"
require "bit"

function love.load()
	socket = socket.tcp()
	socket:connect("g3d2.hq.c3d2.de", 1339)
	socket:send("0400\r\n")
	key_state = 0
end

keys = {
	up = 1,
	down = 2,
	left = 4,
	right = 8,
	rshift = 16,
	["return"] = 32,
	x = 64,
	y = 128
}

function send()
	local msg = ("0A%02X%02XFF\r\n"):format(player, key_state)
	socket:send(msg)
end

function love.keypressed(key)
	if key == "escape" then
		love.event.push "q"
	end

	if keys[key] then
		key_state = bit.bor(key_state, keys[key])
		send()
	end
end

function love.keyreleased(key)
	if keys[key] then
		key_state = bit.band(key_state, bit.bnot(keys[key]))
		send()
	end
end
