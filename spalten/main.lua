require "helper"
require "wall"
require "field"


function love.keypressed(key)
	if key == "escape" then
		love.event.push "q"
	end
end


function love.load()
	math.randomseed(os.time())
	wall = Wall("ledwall", 1338, 3)

	time = love.timer.getTime() * 1000

	-- twp player
	fields = {
		Field(0, { left = "a", right = "d", down = "s", rot = "w" }),
--		Field(0, false),
		Field(8, { left = "left", right = "right", down = "down", rot = "up" })
	}
	fields[1]:setOpponent(fields[2])
	fields[2]:setOpponent(fields[1])


end


function love.update(dt)
	-- constant 30 FPS
	local t = love.timer.getTime() * 1000
	time = time + 1000 / 30
	love.timer.sleep(time - t)


	fields[1]:update()
	fields[2]:update()

end


function love.draw()

	fields[1]:draw()
	fields[2]:draw()

	-- send the stuff abroad
	wall:draw()
end



