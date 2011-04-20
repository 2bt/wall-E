#!/usr/bin/python

import pygame
from pygame.locals import *
from OpenGL.GL import *
from OpenGL.GLU import *
import time

import wall


WALL = True

class Engine:
	def __init__(self):

		if WALL: wall.init()

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
		buf = "".join(c for row in buf for c in row)
		if WALL:
			wall.frame(buf)


class Level:
	def __init__(self, filename):

		self.colors = {
			" ":	"9999dd",		# background
			"Z":	"770000",		# wall
			"w":	"dddddd",		# clouds
			"g":	"22aa22",		# bushes
		}

		f = open(filename).read().split("\n")

		self.static = f[:15]
		self.length = len(f[0])

		# TODO
		dynamic = f[15:30]


	def is_solid(self, x, y):
		return self.static[y][x].isupper()


	def render(self):
		# copy map data into buffer
		for r in range(15):
			for c in range(16):
				main.buffer[r][c] = self.colors[self.static[r][c + main.cam_pos]]




class Mario:

	def __init__(self):
		self.x = 3
		self.y = 12

		self.move_x = 0
		self.move_y = 0
		self.move_y_acc = 0

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
				self.x += s

		# restrict mario's movement
		if self.x < main.cam_pos:
			self.x = main.cam_pos
			self.move_x = 0

		# scrolling
		if main.cam_pos < self.x - 11:
			main.cam_pos = self.x - 11
			if main.cam_pos > level.length - 16:
				main.cam_pos = level.length - 16
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

				# collision check
				if level.is_solid(self.x, self.y + s):
					self.move_y = 0
					self.move_y_accu = 0
				else:
					self.y += s
	


class Main:
	def __init__(self):

		global engine, level

		engine = Engine()
		level = Level("level.txt")

		self.buffer = [[0] * 16 for i in range(15)]

		self.cam_pos = 0

		self.mario = Mario()

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


			self.mario.update()

			self.render()
			time.sleep(0.01)


	def render(self):


		level.render()

		# mario
		self.buffer[self.mario.y][self.mario.x - self.cam_pos] = "aa0000"



		engine.render(self.buffer)



if __name__ == "__main__":

	global main
	main = Main()

	try:
		main.start()

	except KeyboardInterrupt:
		pass

