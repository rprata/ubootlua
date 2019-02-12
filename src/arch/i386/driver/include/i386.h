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

#define enable()	__asm__ __volatile__ ("sti" : : : "memory");

#define disable()	__asm__ __volatile__ ("cli" : : : "memory");

#define save_flags( flags ) \
	__asm__ __volatile__ ("pushfl ; popl %0" : "=g"(flags) : )

#define restore_flags( flags ) \
	__asm__ __volatile__ ("pushl %0 ; popfl" : : "g"(flags) : "memory", "cc")

#ifndef local_irq_save
#define local_irq_save(flags) \
	__asm__ __volatile__ ("pushfl ; popl %0 ; cli" : "=g"(flags) : : "memory")
#endif

#define local_irq_set(flags) \
	__asm__ __volatile__ ("pushfl ; popl %0 ; sti" : "=g"(flags) : : "memory")

#ifndef local_irq_restore
#define local_irq_restore(flags)	restore_flags(flags)
#endif
	
#define idle() \
	__asm__ __volatile__ ("hlt" : : : "memory");

#define safe_idle() \
	do { enable(); idle();  } while(0)


#endif