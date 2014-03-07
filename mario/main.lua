require "helper"
require "wall"
require "level"
require "entity"
require "block"
require "goomba"
require "powerup"
require "mario"

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()

	elseif key == "f1" then
		wall:record(true)
		print("recording...")

	elseif key == "f2" then
		wall:record(false)
		print("recording stopped")

	end
end

function love.load()
	wall = Wall("10.0.1.2", 1350, 3, true)

	level = Level("level-1-1.txt")
	mario = Mario()

	tick = 0
end

function love.update(dt)
	tick = tick + 1

	wall:update_input()

	mario:update()
	if mario.state ~= "growing" and
	   mario.state ~= "shrinking" and
	   mario.state ~= "burning" and
	   mario.state ~= "dying" then
		level:update()
	end

end


function love.draw()

	level:draw()
	mario:draw()

	-- send the stuff abroad
	wall:draw()
end
