require "helper"
require "wall"
require "field"


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



-- keys for a possible local player
local input_keys = {
	up = "up",
	down = "down",
	left = "left",
	right = "right",
	select = "rshift",
	start = "return",
	a = "x",
	b = "c",
}


function love.load()
	math.randomseed(os.time())
	time = love.timer.getTime() * 1000

	wall = Wall("ledwall", 1338, 3, true)

	local_input = {}
	for button in pairs(input_keys) do
		local_input[button] = false
	end

	fields = {
		Field(0, wall.input),
--		Field(8, local_input),		-- local player
		Field(8, false),			-- bot
	}

	fields[1]:setOpponent(fields[2])
	fields[2]:setOpponent(fields[1])

end


function love.update(dt)
	-- constant 30 FPS
	local t = love.timer.getTime() * 1000
	time = time + 1000 / 30
	love.timer.sleep(time - t)


	for button, key in pairs(input_keys) do
		local_input[button] = love.keyboard.isDown(key)
	end
	wall:update_input()



	fields[1]:update()
	fields[2]:update()

end


function love.draw()

	fields[1]:draw()
	fields[2]:draw()

	-- send the stuff abroad
	wall:draw()
end



