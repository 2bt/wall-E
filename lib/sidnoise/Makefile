SRC = $(wildcard *.c)
TARGET = ../sidnoise.so

$(TARGET): $(SRC)
	gcc -Wall -shared -fPIC -O2 -s -o $@ $(SRC) -pthread

clean:
	rm -f $(TARGET)
