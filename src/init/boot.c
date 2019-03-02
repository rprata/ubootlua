#include <init.h>
#include <string.h>
#include <stdlib.h>
#include <serial.h>
#include <math.h>
int __start() {

    do_init_mem_pool();
    
    short color = 0x0200;
    const char *msg = "Hello world! C example";
    short * vga = (short*)0xb8000;
    unsigned i = 0;

	// memset(buf, 100, 23);
	for (i = 0; i < 23; ++i) {
        vga[i] = color | msg[i];
    }
//http://minirighi.sourceforge.net/html/serial_8c-source.html
//https://github.com/tifanny-suyavong/hello64 

    serial_init(TTYS0, BPS_115200);
    printf(BANNER_VERSION);

    return 0;
}