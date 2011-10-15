#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <assert.h>
#include <termios.h>
#include <unistd.h>
#include <fcntl.h>
#include <time.h>
#include <pthread.h>
#include <lua5.1/lua.h>
#include <lua5.1/lauxlib.h>

#define		MAX_SOUND_LENGTH	1024 * 25

static unsigned char buffer[MAX_SOUND_LENGTH];
static unsigned int pos = 0;
static unsigned int length = 0;
static volatile int running = 1;

static void flush(int serial) {
	assert(write(serial, "\xf7", 1) == 1);
}


static void* play(void* dummy) {

	int serial = open("/dev/ttyUSB0", O_RDWR);
	struct termios config;
	tcgetattr(serial, &config);
	config.c_iflag = 0;
	config.c_oflag = 0;
	cfsetospeed(&config, B115200);
	cfsetispeed(&config, B115200);

	config.c_cflag = CS8|CREAD|CLOCAL;
	tcsetattr(serial, TCSANOW, &config);

	// zero out
	int i;
	unsigned char t[2] = { 0, 0 };
	for(i = 0; i < 25; i++) {
		t[0] = i;
		assert(write(serial, t, 2) == 2);
	}
	flush(serial);

	// kinda main loop
	while(running) {

		if(pos < length) {

			for(i = 0; i < 25; i++) {
				t[0] = i;
				t[1] = buffer[pos];
				assert(write(serial, t, 2) == 2);
				pos++;
			}
			flush(serial);
		}
		usleep(20000);
	}

	// zero out
	for(i = 0; i < 25; i++) {
		t[0] = i;
		assert(write(serial, t, 2) == 2);
	}
	flush(serial);


	close(serial);
	return NULL;
}



static int LUA_sidnoise_play_sound(lua_State *L) {

	size_t len;
	const char* sound = luaL_checklstring(L, 1, &len);
	if(len % 25 != 0 || len > MAX_SOUND_LENGTH) {
		lua_pushstring(L, "wrong length");
		lua_error(L);
	}

	length = len;
	memcpy(buffer, sound, len);
	pos = 0;

	return 0;
}


static unsigned long thread;
static void my_exit() {
	running = 0;
	pthread_join(thread, NULL);
}


LUALIB_API int luaopen_sidnoise(lua_State *L) {
	atexit(&my_exit);

	pthread_create(&thread, NULL, play, NULL);

	const luaL_reg reg[] = {
		{ "play_sound", LUA_sidnoise_play_sound },
		{ NULL, NULL }
	};
	luaL_register(L, "sidnoise", reg);

 	return 0;
}


