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
		love.event.push "q"
	end
end

function love.load()
	tick = 0
	wall = Wall()
	level = Level("level-1-1.txt")
	mario = Mario()
end

function love.update(dt)
	tick = tick + 1

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
