require "sidnoise"

sounds = {}

function sound(name)
	sidnoise.play_sound(sounds[name])
end

-- create the actual sounds --

sounds["mute"] = ("\0"):rep(25)

function note(n)
	local f = 440 * 2 ^ ((n - 65) / 12)
	local value = math.floor(f * 16.777216 + 0.5)
	local high = math.floor(value / 256)
	local low = value - high * 256
	return low, high, value
end

function state_to_string(state)
	local s = {}
	for v = 1, 3 do
		local voice = state[v]
		for r = 1, 7 do
			s[#s + 1] = string.char(voice[r] or 0)
		end
	end
	for i = 4, 7 do
		s[#s + 1] = string.char(state[i] or 0)
	end
	return table.concat(s)
end


local state = {
	{ 0x00, 0x00, 0x00, 0x08, 0x41, 0x0f, 0xf0 },
	{},
	{},
	0, 0, 0, 15
}
local v1 = state[1]

local buffer = {}
v1[5] = 0x21
for i = 60, 56, -1 do

	v1[1], v1[2] = note(i)
	table.insert(buffer, state_to_string(state))
	table.insert(buffer, state_to_string(state))

	v1[1], v1[2] = note(i + 7)
	table.insert(buffer, state_to_string(state))
	table.insert(buffer, state_to_string(state))

	v1[1], v1[2] = note(i + 12)
	table.insert(buffer, state_to_string(state))
	table.insert(buffer, state_to_string(state))
end
v1[5] = 0x20
buffer[#buffer] = state_to_string(state)

sounds["line-complete"] = table.concat(buffer)


buffer = {}
v1[4] = 0x08
v1[5] = 0x41
v1[6], v1[7] = 0x0a, 0xa0
for i = 0, 7 do
	v1[1], v1[2] = note(45 - i * 2)
	table.insert(buffer, state_to_string(state))
end
v1[5] = 0x40
buffer[#buffer] = state_to_string(state)

sounds["collision"] = table.concat(buffer)


buffer = {}
v1[4] = 0x02
v1[5] = 0x41
v1[6], v1[7] = 0x08, 0x80

v1[1], v1[2] = note(60)
table.insert(buffer, state_to_string(state))

v1[1], v1[2] = note(67)
table.insert(buffer, state_to_string(state))

v1[1], v1[2] = note(72)
table.insert(buffer, state_to_string(state))


v1[5] = 0x40
buffer[#buffer] = state_to_string(state)


sounds["rotate"] = table.concat(buffer)



