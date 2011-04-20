#!/usr/bin/python

# FIXME (everything following this line)

import pygame
from pygame.locals import *
from OpenGL.GL import *
from OpenGL.GLU import *
import time
import wall


class Engine:

	WALL = True

	def __init__(self):

		if self.WALL: wall.init()

		self.keys = {}
		self.buffer = [["000000"] * 16 for i in range(15)]
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


	def render(self, buf):

		# we don't render if things don't change
		if self.buffer == buf: return

		self.buffer = [row[:] for row in buf]

		# local output
		glClear(GL_COLOR_BUFFER_BIT)
		glBegin(GL_QUADS)
		for y, row in enumerate(buf):
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
			buf = "".join(c for row in buf for c in row)
			wall.frame(buf)


class Entity:
	solid = False
	
	def hit(self):
		# die after a hit?
		return False
	
	def __init__(self, x, y, c):
		pass

	def render(self):
		pass

class Block(Entity):
	solid = True
	def __init__(self, x, y, c):
		self.x = x
		self.y = y
		self.c = c


	def render(self):
		if level.cam_pos <= self.x < level.cam_pos + 16:

			color = {
				"b":	"552222",
				"c":	["ddcc00", "ccbb00", "998800", "ccbb00"][(main.ticks/12)%4],
				"e":	"bb9900",
			}

			main.buffer[self.y][self.x - level.cam_pos] = color[self.c]

	def hit(self):
		if self.c == "b": return mario.big
		elif self.c == "c":
			self.c = "e"
			# TODO: gain one coin
			return False
		elif self.c == "e": return False

class Level:
	def __init__(self, filename):

		self.colors = {
			" ":	"9999dd",		# background
			"Z":	"770000",		# wall
			"w":	"cccccc",		# clouds
			"g":	"22aa22",		# bushes
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
		}
		for y, row in enumerate(dynamic):
			for x, c in enumerate(row):
				if c in table:
					self.entities.append(table[c](x, y, c))


	def is_solid(self, x, y):
		if self.static[y][x].isupper():
			return True

		for e in self.entities:
			if e.x == x and e.y == y and e.solid:
				return True

		return False


	def hit(self):
		for e in self.entities:
			if e.x == mario.x and e.y == mario.y - 1 - mario.big:
				if e.hit(): self.entities.remove(e)


	def render(self):

		# copy static data into buffer
		for r in range(15):
			for c in range(16):
				main.buffer[r][c] = self.colors[self.static[r][c + self.cam_pos]]

		# render dynamic stuff
		for e in self.entities:
			e.render()



class Mario:

	def __init__(self):
		self.x = 3
		self.y = 12

		self.big = True

		self.move_x = 0
		self.move_y = 0
		self.move_y_acc = 0

	def render(self):

		if self.big:
			main.buffer[self.y - 1][self.x - level.cam_pos] = "aa0000"
			main.buffer[self.y][self.x - level.cam_pos] = "0000cc"
#			main.buffer[self.y - 1][self.x - level.cam_pos] = "bb8800"
#			main.buffer[self.y][self.x - level.cam_pos] = "aa0000"
		else:
			main.buffer[self.y][self.x - level.cam_pos] = "aa0000"

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
		if self.move_y == 0 and self.y <= 14 and level.is_solid(self.x, self.y + 1):
		
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
			if abs(self.move_y_acc) > 77:	# y - speed
				s = cmp(self.move_y_acc, 0)
				self.move_y_acc -= s * 77


				if s < 0:	# are we moving up?

					if level.is_solid(self.x, self.y + s - self.big):
						# hit e. g. a block
						level.hit()

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

				
	


class Main:
	def __init__(self):
		global engine, level, mario

		engine = Engine()
		level = Level("level.txt")
		mario = Mario()

		self.buffer = [[0] * 16 for i in range(15)]
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

			mario.update()

			self.render()
			time.sleep(0.01)
			self.ticks += 1


	def render(self):

		level.render()
		mario.render()
		engine.render(self.buffer)


if __name__ == "__main__":
	global main
	main = Main()
	main.start()


