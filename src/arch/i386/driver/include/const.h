#ifndef __CONST_H__
#define __CONST_H__

#include <types.h>
#include <compiler.h>

#define TRUE	1
#define FALSE	0
#define NULL	0

#define __LITTLE_ENDIAN__	1234
#define __BIG_ENDIAN__		4321
#define __BYTE_ORDER__		__LITTLE_ENDIAN__

#define MIN(a, b)	((a) < (b) ? (a) : (b))
#define MAX(a, b)	((a) > (b) ? (a) : (b))
#define ABS(a)		((a) < 0 ? -(a) : (a))
#define TRUNC(addr, align)	((addr) & ~((align) - 1))
#define ALIGN_DOWN(addr, align)	TRUNC(addr, align)
#define ALIGN_UP(addr, align)	( ((addr) + (align) - 1) & (~((align) - 1)) )

#endif
