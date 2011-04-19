#!/usr/bin/python
import os, time, wall

font = {
	" ": ["   ", "   ", "   "],
	"\x7f": ["   ", "   ", "   "],
	"a": [" # ", "# #", "# #"],
	"b": ["#  ", "###", "###"],
	"c": ["###", "#  ", "###"],
	"d": ["  #", "###", "###"],
	"e": ["###", "## ", "###"],
	"f": ["###", "## ", "#  "],
	"g": ["## ", "# #", "###"],
	"h": ["# #", "###", "# #"],
	"i": ["###", " # ", "###"],
	"j": ["  #", "# #", "###"],
	"k": ["# #", "## ", "# #"],
	"l": ["#  ", "#  ", "###"],
	"m": ["###", "###", "# #"],
	"n": ["###", "# #", "# #"],
	"o": ["###", "# #", "###"],
	"p": ["###", "###", "#  "],
	"q": ["###", "###", "  #"],
	"r": ["## ", "###", "# #"],
	"s": [" ##", " # ", "## "],
	"t": ["###", " # ", " # "],
	"u": ["# #", "# #", "###"],
	"v": ["# #", "# #", " # "],
	"w": ["# #", "###", "###"],
	"x": ["# #", " # ", "# #"],
	"y": ["# #", " # ", " # "],
	"z": ["## ", " # ", " ##"],
	"0": [" # ", "# #", " # "],
	"1": ["## ", " # ", " # "],
	"2": ["## ", " # ", " ##"],
	"3": ["###", " ##", "###"],
	"4": ["#  ", "###", " # "],
	"5": [" ##", " # ", "## "],
	"6": ["#  ", "###", "###"],
	"7": ["###", "  #", "  #"],
	"8": [" ##", "###", "## "],
	"9": ["###", "###", "  #"],
	".": ["   ", "   ", " # "],
	",": ["   ", "   ", " # "],
	":": [" # ", "   ", " # "],
	"-": ["   ", "###", "   "],
	"<": ["  #", " # ", "  #"],
	">": ["#  ", " # ", "#  "],
	"/": ["  #", " # ", "#  "],
	"\\": ["#  ", " # ", "  #"],
	"=": ["###", "   ", "###"],
	"|": [" # ", " # ", " # "],
	"_": ["   ", "   ", "###"],
	"+": [" # ", "###", " # "],
}

def loop():
	cursor_x = 0
	cursor_y = 0

	colors = ["ff0000", "ffff00", "00ff00", "00ffff", "0000ff", "ff00ff"]

	key = ""
	while True:
		key = os.read(1, 3)
#		print repr(key)

		# move cursor
		if key == "\x1b[D": cursor_x -= 3
		if key == "\x1b[C": cursor_x += 3
		if key == "\x1b[A": cursor_y -= 4
		if key == "\x1b[B": cursor_y += 4
		if key == "\n": cursor_x = 0; cursor_y += 4
		if key == "\x7f": # backspace
			cursor_x -= 3
			if cursor_x < 0: cursor_x = 12; cursor_y -= 4
		if key == "\x0c": # clear screen
			cursor_x = 0
			cursor_y = 0
			wall.clear()

		# print letter
		if key in font:
			letter = font[key]
			for y, r in enumerate(letter):
				for x, p in enumerate(r):
					c = ["000000", colors[0]][p == "#"]
					wall.pixel(cursor_x + x, cursor_y + y, c)
			cursor_x += 3
			if cursor_x == 15:
				cursor_x = 0
				cursor_y += 4
			colors = colors[1:] + [colors[0]]

		if key == "\x7f": # backspace
			cursor_x -= 3
			if cursor_x < 0: cursor_x = 12; cursor_y -= 4

		time.sleep(0.05)

wall.init()
wall.send("0403")
wall.clear()

os.system("stty cbreak -echo min 0")
try: loop()
except KeyboardInterrupt: pass
os.system("stty sane")

