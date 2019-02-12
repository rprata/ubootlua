#ifndef __GCC_COMPILER_H__
#define __GCC_COMPILER_H__

#if ( __GNUC__ < 2 )
#error Your compiler is too old or not recognized!
#endif

#define __INLINE__	__inline__ __attribute__((__always_inline__))

#define __NOINLINE__	__attribute__((__noinline__))

#define __DEPRECATED__	__attribute__((__deprecated__))

#define __ALIGN16__	__attribute__((__aligned__(16)))

#define __ALIGN32__	__attribute__((__aligned__(32)))

#define FASTCALL( x )	__attribute__((__regparm__(3))) x

#define __NORETURN__	__attribute__((__noreturn__))

#define __INIT__	__attribute__((__section__(".init")))

#endif