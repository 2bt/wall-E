
Field = Object:new()
function Field:init(pos, keys)
	self.pos = pos
	self.keys = keys

	-- init clear grid
	self.grid = {}
	for i = 1, 13 do
		local row = {}
		for j = 1, 6 do
			row[j] = 0
		end
		self.grid[i] = row
	end

	self.opponent = nil
end

function Field:setOpponent(opponent)
	self.opponent = opponent
end

function Field:update()

end

function Field:draw()

end

