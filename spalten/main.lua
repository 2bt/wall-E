require "helper"
require "wall"
require "field"
require "sound"

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
	math.randomseed(os.time())
	time = love.timer.getTime() * 1000

	wall = Wall()
--	wall = Wall("94.45.224.211", 1338, 3, false)

	fields = {
		Field(0, wall.input[1]),
		Field(8, false),	-- bot
	}

	fields[1]:setOpponent(fields[2])
	fields[2]:setOpponent(fields[1])

end


function love.update(dt)
	-- constant 30 FPS
	local t = love.timer.getTime() * 1000
	time = time + 1000 / 30
	love.timer.sleep(time - t)

	wall:update_input()

	-- allow 2nd player to join
	if not fields[2].key_state then
		if wall.input[2].a then
			fields[2].key_state = wall.input[2]
		end
	end

	fields[1]:update()
	fields[2]:update()

end


function love.draw()

	fields[1]:draw()
	fields[2]:draw()

	-- send the stuff abroad
	wall:draw()
end



