import socket
import pygame
from pygame.locals import *
from OpenGL.GL import *
from OpenGL.GLU import *

class SuperWall:

	def __init__(self, priority=3, host="172.22.99.6", port=1338):

		self.keys = {}
		self.buffer = [["000000"] * 16 for i in range(15)]
		self.old_buffer = [row[:] for row in self.buffer]
		self.running = True

		self.priority = priority
		if self.priority:
			self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
			self.socket.connect((host, port))
			self.socket.send("04%02x\r\n" % priority)

		pygame.display.init()
		pygame.display.set_mode((320, 300), DOUBLEBUF | OPENGL)
		glMatrixMode(GL_PROJECTION)
		glLoadIdentity()
		gluOrtho2D(0, 16, 15, 0)
		glMatrixMode(GL_MODELVIEW)
		glLoadIdentity()


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
				glColor(*[int(c[i:i+2], 16) / 255.0 for i in range(0, 6, 2)])
				glVertex(x, y)
				glVertex(x+1, y)
				glVertex(x+1, y+1)
				glVertex(x, y+1)
		glEnd()
		pygame.display.flip()

		# wall output
		if self.priority:
			buf = "".join(c for row in self.buffer for c in row)
			self.socket.send("03%s\r\n" % buf)


