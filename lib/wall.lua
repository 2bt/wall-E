require "socket"

Wall = Object:new()

function Wall:init(host, port, priority)

	self.buffer = {}
	for i = 1, 15 * 16 do
		self.buffer[i] = "000000"
	end

	if host == false then return end

	host = host or "ledwall"
	port = port or 1338
	priority = priority or 3

	self.msg = ""
	self.socket = socket.tcp()
	self.socket:connect(host, port)
	self:priority(priority)
end

function Wall:priority(priority)
	if self.socket then
		self.socket:send("04%02d\r\n" % priority)
	end
end

function Wall:record(flag)
	if self.socket then
		local opcode = flag and "05" or "06"
		self.socket:send(flag .. "\r\n")
	end
end

function Wall:pixel(x, y, color)
	if 0 <= x and x < 16 and 0 <= y and y < 15 then
		self.buffer[y * 16 + x + 1] = color
	end
end

function Wall:draw()
	local w = love.graphics.getWidth() / 16
	local h = love.graphics.getHeight() / 15
	for i, color in ipairs(self.buffer) do
		local x = ((i - 1) % 16) * w
		local y = math.floor((i - 1) / 16) * h
		local r, g, b = color:match "(..)(..)(..)"
		r = tonumber("0x" .. r)
		g = tonumber("0x" .. g)
		b = tonumber("0x" .. b)
		love.graphics.setColor(r, g, b)
		love.graphics.rectangle("fill", x, y, w, h)
	end
	local msg = table.concat(self.buffer)
	if msg ~= self.msg and self.socket then
		self.msg = msg
		self.socket:send("03%s\r\n" % msg)
	end
end

