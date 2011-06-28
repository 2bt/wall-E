
local gem_colors = {}

gem_colors[-1] = "555555"	-- brick
gem_colors[0] = "000000"	-- background

gem_colors[1] = "bb2200"
gem_colors[2] = "0022bb"
gem_colors[3] = "00bb00"
gem_colors[4] = "bbbb00"
gem_colors[5] = "8800bb"
gem_colors[6] = "00bbbb"


function Field:draw()

	for y = 0, 14 do
		local row = self.grid[y] or {}
		for x = 0, 7 do

			local gem = row[x]
			if self.state == "normal" and y > 0 and x == self.x then
				-- also draw active column
				gem = self.column[self.y - y + 1] or gem
			end

			local color = gem and gem_colors[gem] or "888888"
			wall:pixel(self.pos + x, y, color)
		end
	end

	-- draw flashing gems
	if self.state == "highlight" then
		for _, coords in pairs(self.gems_in_line) do
			local color = ({ "ffffff", "000000" })[self.state_delay % 3 + 1]
			if color then
				wall:pixel(self.pos + coords.x, coords.y, color)
			end
		end
	end

	-- draw score
	local score = self.score
	local y = 13
	local x = self.pos == 0 and 7 or self.pos
	while score > 0 and y >= 0 do
		if score % 2 > 0 then
			wall:pixel(x, y, "aaaaaa")
		end
		score = math.floor(score / 2)
		y = y - 1
	end
end


