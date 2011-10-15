require "helper"
require "wall"
require "player"


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
	time = love.timer.getTime() * 1000

	tick = 0

	player = Player()

end


function love.update(dt)
	-- constant 30 FPS
	local t = love.timer.getTime() * 1000
	time = time + 1000 / 30
	love.timer.sleep(time - t)

	wall:update_input()

	tick = tick + 1

	player:update()

	lasers:each(function(i, l) l:update() end)

end


function love.draw()

	for x = 0, 16 do
		for y = 0, 15 do
			wall:pixel(x, y, "000000")
		end
	end

	lasers:each(function(i, l) l:draw() end)

	player:draw()

	wall:draw()
end


