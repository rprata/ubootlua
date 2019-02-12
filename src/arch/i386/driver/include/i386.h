#ifndef _I386_H_
#define _I386_H_

#include <types.h>

#ifndef outb
static inline void outb(u16_t port, u8_t value)
{
    asm volatile("outb %0, %1 \n" :: "a"(value), "d"(port));
}
#endif

#ifndef inb
static inline u8_t inb(u16_t port)
{
    u8_t result = 0;
    asm volatile("inb %1, %0 \n" : "=&a"(result) : "d"(port));
    return result;
}
#endif

#endif