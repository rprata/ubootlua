#ifndef _SERIAL_H_
#define _SERIAL_H_

#include <i386.h>

#define PORT0 0x3F8 // Serial port base address (for ttyS0).
#define PORT1 0x2F8 // Serial port base address (for ttyS1).
#define PORT2 0x3E8 // Serial port base address (for ttyS2).
#define PORT3 0x2F8 // Serial port base address (for ttyS3).

#define TTYS0 PORT0 //ttyS0 port address
#define TTYS1 PORT1 //ttyS1 port address
#define TTYS2 PORT2 //ttyS2 port address
#define TTYS3 PORT3 //ttyS3 port address

#define BPS_115200 	0x01 //115200 BPS.
#define BPS_56700 	0x02 //56700 BPS.
#define BPS_38400 	0x03 //38400 BPS.
#define BPS_19200 	0x06 //19200 BPS.
#define BPS_9600 	0x0C //9600 BPS.
#define BPS_4800 	0x18 //4800 BSP.
#define BPS_2400 	0x0C //2400 BPS.

#define RS232_BUF_DIM 256 //RS232 buffer size.
 	
void serial_init(word port, byte divisor);
void serial_putchar(word port, char c);
void serial_print(word port, const char *s);

#endif
