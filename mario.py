#!/usr/bin/python

# FIXME (everything following this line)

import pygame
from pygame.locals import *
from OpenGL.GL import *
from OpenGL.GLU import *
import time
import wall


Y_INV_SPEED = 77

class Engine:

	WALL = True

	def __init__(self):

		if self.WALL: wall.init()

		self.keys = {}
		self.buffer = [["000000"] * 16 for i in range(15)]
		self.old_buffer = [row[:] for row in self.buffer]
		self.running = True

	def handle_events(self):
		for event in pygame.event.get():
			if event.type == pygame.QUIT: self.running = False
			elif event.type == pygame.KEYDOWN:
				if event.key == pygame.K_ESCAPE: self.running = False
				self.keys[event.key] = 1
			elif event.type == pygame.KEYUP:
				self.keys[event.key] = 0

	def keystate(self, key, kill=False):
		if type(key) == str: key = ord(key)
		c = self.keys.get(key, 0)
		if kill: self.keys[key] = 0
		return c

	def pixel(self, x, y, color):
		if 0 <= x < 16 and 0 <= y < 15: self.buffer[y][x] = color

	def render(self):

		# we don't render if things don't change
		if self.buffer == self.old_buffer: return
		self.old_buffer = [row[:] for row in self.buffer]

		# local output
		glClear(GL_COLOR_BUFFER_BIT)
		glBegin(GL_QUADS)
		for y, row in enumerate(self.buffer):
			for x, c in enumerate(row):
				glColor(*[int(c[i:i+2], 16) / 255.0 for i in range(0,6,2)])
				glVertex(x, y)
				glVertex(x+1, y)
				glVertex(x+1, y+1)
				glVertex(x, y+1)
		glEnd()
		pygame.display.flip()

		# wall output
		if self.WALL:
			buf = "".join(c for row in self.buffer for c in row)
			wall.frame(buf)


class Entity:
	solid = False
	def __init__(self, x, y, c): pass
	def render(self): pass
	def update(self): pass
	def hit(self): pass
	def touch(self): pass

class Block(Entity):
	solid = True
	def __init__(self, x, y, c):
		self.x = x
		self.y = y
		self.c = c


	def render(self):

		blink_color = ["ddcc00", "ccbb00", "998800", "ccbb00"][(main.ticks/12)%4]
		colors = {
			"b":	"552222",
			"e":	"aa8800",
			"c":	blink_color,
			"f":	blink_color,
		}

		engine.pixel(self.x - level.cam_pos, self.y, colors[self.c])

	def hit(self):
		if self.c == "b":
			if mario.big:
				level.entities.remove(self)
		elif self.c == "c":
			self.c = "e"
			# TODO: gain one coin
		elif self.c == "f":	# fungus
			level.entities.append(Fungus(self.x, self.y - 1))
			self.c = "e"


class Fungus(Entity):
	solid = False
	def __init__(self, x, y):
		self.x = x
		self.y = y
		self.dir = 1
		self.move_x = 0
		self.move_y = 0
		self.move_y_acc = 0

	def render(self):
		engine.pixel(self.x - level.cam_pos, self.y, "ccaa77")

	def touch(self):
		level.entities.remove(self)
		mario.big = True

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
		if not level.is_solid(self.x, self.y + 1):
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


class Level:
	def __init__(self, filename):

		self.colors = {
			" ":	"8888cc",		# background
			"Z":	"770000",		# wall
			"w":	"bbbbbb",		# clouds
			"b":	"11aa11",		# bushes
			"g":	"44aa44",		# grass
			"T":	"008800",		# tube
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
		}
		for y, row in enumerate(dynamic):
			for x, c in enumerate(row):
				if c in table:
					self.entities.append(table[c](x, y, c))

	def is_solid(self, x, y):
		if 0 <= x <= self.length and 0 <= y <= 15:
			if self.static[y][x].isupper(): return True

		for e in self.entities:
			if e.x == x and e.y == y and e.solid: return True

		return False


	def hit(self):
		for e in self.entities:
			if e.x == mario.x and e.y == mario.y - 1 - mario.big:
				e.hit()


	def render(self):
		# copy static data into buffer
		for r in range(15):
			for c in range(16):
				engine.pixel(c, r, self.colors[self.static[r][c + self.cam_pos]])

		# render dynamic stuff
		for e in self.entities: e.render()


	def update(self):
		for e in self.entities: e.update()

	def touch(self):
		for e in self.entities:
			if e.x == mario.x:
				if e.y == mario.y: e.touch()
				elif e.y == mario.y - 1: e.touch()


class Mario:

	def __init__(self):
		self.x = 3
		self.y = 12

		self.big = False

		self.move_x = 0
		self.move_y = 0
		self.move_y_acc = 0

	def render(self):

		if self.big:
			engine.pixel(self.x - level.cam_pos, self.y - 1, "aa0000")
			engine.pixel(self.x - level.cam_pos, self.y, "0000cc")
#			engine.pixel(self.x - level.cam_pos, self.y - 1, "bb8800")
#			engine.pixel(self.x - level.cam_pos, self.y, "aa0000")
		else:
			engine.pixel(self.x - level.cam_pos, self.y, "aa0000")

	def update(self):

		# x - movement
		dx = (engine.keystate(K_RIGHT) - engine.keystate(K_LEFT))
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
			if engine.keystate(K_SPACE, True):
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
					if level.is_solid(self.x, self.y + s - self.big):

						level.hit()	# hit e. g. a block

						self.move_y = 0
						self.move_y_accu = 0
					else:
						self.y += s

				elif s > 0:	# are we moving down?
					if level.is_solid(self.x, self.y + s):

						self.move_y = 0
						self.move_y_accu = 0
					else:
						self.y += s

		level.touch()



class Main:
	def __init__(self):
		global engine, level, mario

		engine = Engine()
		level = Level("level.txt")
		mario = Mario()

		self.ticks = 0

		pygame.display.init()
		pygame.display.set_mode((320, 300), DOUBLEBUF | OPENGL)
		glMatrixMode(GL_PROJECTION)
		glLoadIdentity()
		gluOrtho2D(0, 16, 15, 0)
		glMatrixMode(GL_MODELVIEW)
		glLoadIdentity()


	def start(self):
		while engine.running:

			engine.handle_events()

			# update
			level.update()
			mario.update()

			# render
			level.render()
			mario.render()
			engine.render()


			time.sleep(0.01)
			self.ticks += 1



if __name__ == "__main__":
	global main
	main = Main()
	main.start()


