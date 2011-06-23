#!/usr/bin/python
import os, time, random, wall

color_palette = {
	0: "000000",
	1: "777777",
	2: "999999",
	-1: "880000",
	-2: "000088"
}

stones = [
	[0, 0, 0, 0, 0,15,15, 0, 0,15,15, 0, 0, 0, 0, 0],
	[0, 0,10, 0, 5, 5,15, 5, 0, 0,10, 0, 0, 0,10, 0],
	[0, 0, 5, 0, 0, 0,15,15, 0,10,10, 5, 0, 0, 0, 0],
	[0, 0, 0, 5, 0,10,15, 5, 0, 0,15,10, 0, 0, 0, 0],
	[0, 4, 5, 8, 0,10,15,10, 0, 2, 5, 1, 0, 0, 0, 0],
	[0, 8, 5, 1, 0,10,15,10, 0, 4, 5, 2, 0, 0, 0, 0],
	[0, 0,11, 0, 0,13,15, 7, 0, 0,14, 0, 0, 0, 0, 0]
]


class Player:
	score = 0
	def __init__(self, pos, index):
		self.pos = pos
		self.index = index
		self.new()

	def new(self):

		self.stone = random.choice(stones)
		self.r = 2 ** random.randint(0, 3)
		self.x = self.pos
		self.y = -2
		self.move()

	def move(self, cmd=""):

		repeat = True
		while repeat:
			repeat = False

			old = (self.x, self.y, self.r)

			if cmd == "d": self.y += 1
			if cmd == "f": self.y += 1; repeat = True
			if cmd == "l": self.x -= 1
			if cmd == "r": self.x += 1
			if cmd == "x": self.r = self.r / 2 or 8
			if cmd == "c": self.r = (self.r * 2) % 15

			if self.test():
				self.x, self.y, self.r = old
				if cmd == "d" or cmd == "f":
					tetris.field = [(i, 2)[i == self.index] for i in tetris.field]
					tetris.check_rows()
					self.new()
				return

			tetris.field = [i * (i != self.index) for i in tetris.field]
			for y in range(4):
				if self.y + y >= 0:
					for x in range(4):
						c = (self.r & self.stone[y * 4 + x] > 0) * self.index
						if c:
							i = (self.y + y) * Tetris.width + self.x + x
							tetris.field[i] = c

	def test(self):
		for y in range(4):
			if self.y + y >= 0:
				for x in range(4):
					i = (self.y + y) * Tetris.width + self.x + x
					if self.r & self.stone[y * 4 + x] and tetris.field[i] not in (0, self.index):
						return True
		return False


class Tetris:

	width = 16
	height = 15
	field = ([1] + [0] * (width - 2) + [1]) * (height - 1) + [1] * width
	old_field = []

	def __init__(self):
		wall.init()
		wall.clear()

	def render(self):
		if self.field == self.old_field: return
		self.old_field = self.field[:]
		b = "".join(color_palette[c] for c in self.field)
		wall.frame(b)

	def check_rows(self):

		r = 0
		full = [1] + [2] * (self.width - 2) + [1]
		empty = [1] + [0] * (self.width - 2) + [1]
		for y in range(self.height - 1):
			i = y * self.width;
			if self.field[i:i + self.width] == full:
				self.field[i:i + self.width] = []
				self.field = empty + self.field
				r += 1
		return r

	def loop(self):

		player = Player(self.width / 2 - 2, -1)
		counter = 0
		key = ""

		while "q" not in key:
			key = os.read(1, 3)

			cmds = {
				"\x1b[D": "l",
				"\x1b[C": "r",
				"\x1b[B": "d",
				"x": "x",
				"c": "c",
				" ": "f",
			}

			counter += 1

			if key in cmds:
				player.move(cmds[key])
				if cmds[key] == "d" or cmds[key] == "f":
					counter = 0

			if counter == 50:
				counter = 0
				player.move("d")

			self.render()
			time.sleep(0.01)



if __name__ == "__main__":
	os.system("stty cbreak -echo min 0")
	global tetris
	try:
		tetris = Tetris()
		tetris.loop()
	except KeyboardInterrupt:
		pass
	os.system("stty sane")



