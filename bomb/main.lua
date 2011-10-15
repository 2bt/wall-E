require "helper"
require "wall"
require "bomb"

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
	level:update()

end


function love.draw()

	level:draw()
	-- send the stuff abroad
	wall:draw()
end
