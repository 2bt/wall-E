#!/usr/bin/python
import os, time, wall
import pygame
from pygame.locals import *

WALL = True

class Engine:
	def __init__(self):

		self.buffer = [[0] * 16 for i in range(15)]

		self.colors = {
			" ":	("9999cc", "\x1b[40m  \x1b[49m"),		# background
			"#":	("770000", "\x1b[41m[]\x1b[49m"),		# wall
			"m":	("aa0000", "\x1b[44mma\x1b[49m"),		# mario
			"w":	("dddddd", "\x1b[40mww\x1b[49m"),		# clouds
			"g":	("22aa22", "\x1b[42mgg\x1b[49m"),		# bushes
		}

		os.system("stty cbreak -echo min 0")
		os.write(0, "\x1b[2J\x1b[?25l")

		if WALL:
			wall.init()
			wall.send("0404")

	def render(self, buf):

		# we don't render if things don't change
		if self.buffer == buf: return

		self.buffer = [row[:] for row in buf]

		# console output
		os.write(0, "\x1b[1;1H") # clear
		for row in buf:
			print "".join(self.colors[c][1] for c in row)

		# wall output
		buf = "".join(self.colors[c][0] for row in buf for c in row)
		if WALL:
			wall.frame(buf)

	def exit(self):
		os.system("stty sane")
		os.write(0, "\x1b[?25h")



# input keys
keys = {}
def keystate(key, kill=False):
	if type(key) == str: key = ord(key)
	c = keys.get(key, 0)
	if kill: keys[key] = 0
	return c


class Mario:

	def __init__(self):
		self.x = 3
		self.y = 12

		self.move_x = 0
		self.move_y = 0
		self.move_y_acc = 0

	def update(self):

		# x - movement
		dx = (keystate(K_RIGHT) - keystate(K_LEFT))
		self.move_x += dx
		if not dx: self.move_x = 0

		if abs(self.move_x) > 10:
			s = cmp(self.move_x, 0)
			self.move_x = 0
			# collision check
			if main.level[self.y][self.x + s] != "#":
				self.x += s

		# restrict mario's movement
		if self.x < main.cam_pos:
			self.x = main.cam_pos
			self.move_x = 0

		# scrolling
		if main.cam_pos < self.x - 11:
			main.cam_pos = self.x - 11
			if main.cam_pos > len(main.level[0]) - 16:
				main.cam_pos = len(main.level[0]) - 16
				if self.x > len(main.level[0]) - 1:
					self.x = len(main.level[0]) - 1
					self.move_x = 0

		# jump
		if self.move_y == 0 and self.y <= 14 and main.level[self.y + 1][self.x] == "#" and keystate(K_SPACE, True):
			self.move_y = -26	# jump height
			self.move_y_acc = 0

		# gravity
		self.move_y += 1

		# y - movement
		self.move_y_acc += self.move_y
		if abs(self.move_y_acc) > 77:	# y - speed
			s = cmp(self.move_y_acc, 0)
			self.move_y_acc -= s * 77

			# collision check
			if self.y + s > 14: return self.die()
			if main.level[self.y + s][self.x] != "#":
				self.y += s
			else:
				self.move_y = 0
				self.move_y_accu = 0
	
	def die(self):
		main.running = False


class Main:
	def __init__(self):

		self.running = True
		self.engine = Engine()

		self.buffer = [[0] * 16 for i in range(15)]

		self.level = open("level.txt").read().split("\n")

		self.cam_pos = 0

		self.mario = Mario()


		pygame.display.init()
		pygame.display.set_mode((1,1))


	def start(self):

		while self.running:

			for event in pygame.event.get():
				if event.type == pygame.QUIT: return
				elif event.type == pygame.KEYDOWN:
					if event.key == pygame.K_ESCAPE: return
					keys[event.key] = 1
				elif event.type == pygame.KEYUP:
					keys[event.key] = 0

			self.mario.update()

			self.render()
			time.sleep(0.01)

#		raw_input()

	def render(self):

		# copy map data into buffer
		for r in range(15):
			for c in range(16):
				self.buffer[r][c] = self.level[r][c + self.cam_pos]

		# mario
		self.buffer[self.mario.y][self.mario.x - self.cam_pos] = "m"

		self.engine.render(self.buffer)


	def exit(self):
		self.engine.exit()


if __name__ == "__main__":

	global main
	main = Main()

	try:
		main.start()

	except KeyboardInterrupt:
		pass

	main.exit()


