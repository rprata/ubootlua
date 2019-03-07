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
    char message[255];
    serial_init(TTYS0, BPS_115200);
    char c = '\0';
    i = 0;
    while (c != '\r') {
        c = serial_getchar(TTYS0);
        message[i] = c;
        i++;
        printf("%c", c);
        // strcat(message, c);
    }
    message[i] = '\0';
    printf("%s\n", message);
    printf(BANNER_VERSION);

    return 0;
}