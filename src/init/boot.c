#include <init.h>
#include <string.h>
#include <stdlib.h>

int __start() {

    do_init_mem_pool();
    
    short color = 0x0200;
    const char *msg = "Hello world! C example\0";
    short * vga = (short*)0xb8000;
    unsigned i = 0;

    // printf(msg);
    return 0;
}