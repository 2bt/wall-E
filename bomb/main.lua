require "helper"
require "wall"

Player = Object:new()
function Player:init(nr, x, y)
	self.nr = nr
	self.x = x
	self.y = y

end



Level = Object:new()
function Level:init(filename)
	
	local file = io.open(filename)
	self.walls = {}
	self.players = {}

	for y = 1, 15 do
		local row = {}
		local line = file:read()
		for x = 1, 15 do
			local cell = line:sub(x, x)
			if ("1234"):find(cell) then
				table.insert(self.players, Player(tonumber(cell), x, y))
			end
			if ("#m"):find(cell) then
				row[x] = cell
			else
				row[x] = " "
			end
		end
		self.walls[y] = row
	end

end

function Level:draw()
	local colors = {
		[" "] = "114411",
		["#"] = "666666",
	}
	for y, row in ipairs(self.walls) do
		for x, cell in ipairs(row) do
			wall:pixel(x - 1, y - 1, colors[cell])
		end
	end
end



function love.keypressed(key)
	if key == "escape" then
		love.event.push "q"

	elseif key == "f1" then
		wall:record(true)
		print("recording...")

	elseif key == "f2" then
		wall:record(false)
		print("recording stopped")

	end
end

function love.load()
	wall = Wall("ledwall", 1338, 3, false)

	level = Level("level.txt")

	tick = 0
end

function love.update(dt)
	tick = tick + 1

	wall:update_input()

end


function love.draw()

	level:draw()
	-- send the stuff abroad
	wall:draw()
end
