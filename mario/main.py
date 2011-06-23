#!/usr/bin/python

import pygame
from pygame.locals import *
import time
from superwall import SuperWall


Y_INV_SPEED = 77


class Entity:
	solid = False
	def render(self): pass
	def update(self): pass
	def hit(self): return False
	def touch(self): pass


class Block(Entity):
	solid = True
	def __init__(self, x, y, c):
		self.x = x
		self.y = y
		self.c = c

		if self.c == "s": self.solid = False


	def render(self):

		if self.c in "s": return

		blink_color = ["ddcc00", "ccbb00", "998800", "ccbb00"][(main.ticks/12)%4]
		colors = {
			"b":	"552222",
			"e":	"aa8800",
			"c":	blink_color,
			"f":	blink_color,
		}

		wall.pixel(self.x - level.cam_pos, self.y, colors[self.c])

	def hit(self):
		""" object is hit by mario from bottom """
		if self.c == "b":
			if mario.big:
				level.entities.remove(self)
				return False
			else:
				# fungus bounce
				for e in level.entities:
					if e.x == self.x and e.y == self.y - 1 and isinstance(e, Fungus):
						e.move_y = -17
				return True

		if self.c == "c":
			self.c = "e"
			level.entities.append(CoinFlash(self.x, self.y - 1))
			mario.coins += 1

			# fungus bounce
			for e in level.entities:
				if e.x == self.x and e.y == self.y - 1 and isinstance(e, Fungus):
					e.move_y = -17
			return True

		if self.c == "f":	# growth fungus
			level.entities.append(Fungus(self.x, self.y - 1, "grow"))
			self.c = "e"
			return True

		if self.c == "s":	# secret life
			self.solid = True
			level.entities.append(Fungus(self.x, self.y - 1, "life"))
			self.c = "e"
			return True

class Fungus(Entity):
	def __init__(self, x, y, type):
		self.type = type
		self.x = x
		self.y = y
		self.dir = 1
		self.move_x = 0
		self.move_y = 0
		self.move_y_acc = 0

	def render(self):
		color = {"grow": "ccaa77", "life": "aaddaa" }[self.type]
		wall.pixel(self.x - level.cam_pos, self.y, color)

	def touch(self):

		level.entities.remove(self)

		if self.type == "grow":
			mario.big = True
		elif self.type == "life":
			mario.lives += 1

	def update(self):

		self.move_x += self.dir

		if abs(self.move_x) > 20: # x - speed
			s = cmp(self.move_x, 0)
			self.move_x = 0
			# collision check
			if not level.is_solid(self.x + s, self.y):
				self.x += s
			else:
				self.dir = -self.dir

		# y - movement
		if self.move_y != 0 or not level.is_solid(self.x, self.y + 1):

			# gravity
			self.move_y += 1

			self.move_y_acc += self.move_y
			if abs(self.move_y_acc) > Y_INV_SPEED:
				s = cmp(self.move_y_acc, 0)
				self.move_y_acc -= s * Y_INV_SPEED

				if level.is_solid(self.x, self.y + s):
					self.move_y = 0
					self.move_y_accu = 0
				else:
					self.y += s


class CoinFlash(Entity):
	def __init__(self, x, y):
		self.x = x
		self.y = y
		self.tick = 0
	
	def render(self):
		wall.pixel(self.x - level.cam_pos, self.y, "eedd00")

	def update(self):
		self.tick += 1

		if self.tick % 3 == 0:
			self.y -= 1

		if self.tick > 8:
			level.entities.remove(self)


class Level:
	def __init__(self, filename):

		self.colors = {
			" ":	"8888cc",		# background
			"Z":	"770000",		# wall
			"w":	"bbbbbb",		# clouds
			"b":	"11aa11",		# bushes
			"g":	"44aa44",		# grass
			"T":	"007700",		# tube
			"E":	"006600",		# tube end
		}

		f = open(filename).read().split("\n")

		self.static = f[:15]
		self.length = len(f[0])

		self.cam_pos = 0

		self.entities = []
		dynamic = f[15:30]
		table = {
			"b":	Block,
			"c":	Block,
			"f":	Block,
			"s":	Block,
		}
		for y, row in enumerate(dynamic):
			for x, c in enumerate(row):
				if c in table:
					self.entities.append(table[c](x, y, c))

	def is_solid(self, x, y):
		if 0 <= x <= self.length and 0 <= y < 15:
			if self.static[y][x].isupper(): return True

		for e in self.entities:
			if e.x == x and e.y == y and e.solid: return True

		return False


	def hit(self):
		""" test if mario has hit something whith his head from below """
		res = self.is_solid(mario.x, mario.y - 1 - mario.big)
		for e in self.entities:
			if e.x == mario.x and e.y == mario.y - 1 - mario.big:
				res = e.hit() or res 
		return res


	def render(self):
		# copy static data into buffer
		for r in range(15):
			for c in range(16):
				wall.pixel(c, r, self.colors[self.static[r][c + self.cam_pos]])

		# render dynamic stuff
		for e in self.entities: e.render()


	def update(self):

		for e in self.entities:
			e.update()
			if e.x == mario.x:
				if e.y == mario.y: e.touch()
				elif e.y == mario.y - 1: e.touch()	# I don't know why I wrote that (maybe if mario is big?)


class Mario:

	def __init__(self):

		self.big = False
		self.coins = 0
		self.lives = 3

		self.x = 4
		self.y = 12
		self.move_x = 0
		self.move_y = 0
		self.move_y_acc = 0

	def render(self):

		if self.big:
			wall.pixel(self.x - level.cam_pos, self.y - 1, "aa0000")
			wall.pixel(self.x - level.cam_pos, self.y, "0000cc")
		else:
			wall.pixel(self.x - level.cam_pos, self.y, "aa0000")

	def update(self):

		# x - movement
		dx = (wall.keystate(K_RIGHT) - wall.keystate(K_LEFT))
		self.move_x += dx
		if not dx: self.move_x = 0

		if abs(self.move_x) > 10:
			s = cmp(self.move_x, 0)
			self.move_x = 0
			# collision check
			if not level.is_solid(self.x + s, self.y):
				if not self.big: self.x += s
				elif not level.is_solid(self.x + s, self.y - 1): self.x += s

		# restrict mario's movement
		if self.x < level.cam_pos:
			self.x = level.cam_pos
			self.move_x = 0

		# scrolling
		if level.cam_pos < self.x - 11:
			level.cam_pos = self.x - 11
			if level.cam_pos > level.length - 16:
				level.cam_pos = level.length - 16
				if self.x > level.length - 1:
					self.x = level.length - 1
					self.move_x = 0

		# if staning on ground?
		if self.move_y == 0 and level.is_solid(self.x, self.y + 1):
		
			self.move_y = 0
			self.move_y_acc = 0
		
			# jump
			if wall.keystate(K_SPACE, True):
				self.move_y = -26	# jump height

		else:
			# gravity
			self.move_y += 1

			# y - movement
			self.move_y_acc += self.move_y
			if abs(self.move_y_acc) > Y_INV_SPEED:
				s = cmp(self.move_y_acc, 0)
				self.move_y_acc -= s * Y_INV_SPEED

				if s < 0:	# are we moving up?
					if level.hit():
						self.move_y = 0
						self.move_y_accu = 0
					else:
						self.y -= 1

				elif s > 0:	# are we moving down?
					if level.is_solid(self.x, self.y + 1):

						self.move_y = 0
						self.move_y_accu = 0
					else:
						self.y += 1



class Main:
	def __init__(self):
		global wall, level, mario

		wall = SuperWall()

		level = Level("level.txt")
		mario = Mario()

		self.ticks = 0

	def start(self):
		while wall.running:

			wall.handle_events()

			# update
			mario.update()
			level.update()

			# render
			level.render()
			mario.render()
			wall.render()

			time.sleep(0.01)
			self.ticks += 1


if __name__ == "__main__":
	global main
	main = Main()
	main.start()


