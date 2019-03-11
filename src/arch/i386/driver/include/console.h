#ifndef _CONSOLE_H_
#define _CONSOLE_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <serial.h>

void register_console_driver();
void unregister_console_driver();
ssize_t read_console_driver(void * message);
ssize_t write_console_driver(void * message);

#endif