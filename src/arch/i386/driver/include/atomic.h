#ifndef __ATOMIC_H__
#define __ATOMIC_H__

#include <compiler.h>
#include <types.h>

//! \brief Initialize an atomic variable.
#define atomic_init(i)		{ (i) }

//! \brief Set the atomic value of v to i (guaranteed only for 24 bits)
#define atomic_set(v, i)	(((v)->counter) = (i))

//! \brief Read the atomic value of v (guaranteed only for 24 bits)
#define atomic_read(v)		((v)->counter)

//! \brief Perform an atomic increment.
//! \warning Guaranteed only for 24 bits.
static __INLINE__ void atomic_inc(atomic_t *v)
{
	__asm__ __volatile__(
		"lock ; incl %0"
		: "=m"(v->counter) : "m"(v->counter));
}

//! \brief Perform an atomic decrement.
//! \warning Guaranteed only for 24 bits.
static __INLINE__ void atomic_dec(atomic_t *v)
{
	__asm__ __volatile__(
		"lock ; decl %0"
		: "=m"(v->counter) : "m"(v->counter));
}

//! Add an integer to the atomic variable v.
//! \warning Guaranteed only for 24 bits.
static __INLINE__ void atomic_add( int i, atomic_t *v )
{
	__asm__ __volatile__(
		"lock ; addl %1, %0"
		: "=m"(v->counter) : "ir"(i), "m"(v->counter));
}

//! Subtract an integer from the atomic variable v.
//! \warning Guaranteed only for 24 bits.
static __INLINE__ void atomic_sub( int i, atomic_t *v )
{
	__asm__ __volatile__(
		"lock ; subl %1, %0"
		: "=m"(v->counter) : "ir"(i), "m"(v->counter));
}

//! Add i to v and returns true if the result is negative, or false when
//! the result is greater than or equal to zero.
//! \warning Guaranteed only for 24 bits.
static __INLINE__ int atomic_add_negative( int i, atomic_t *v )
{
	unsigned char c;

	__asm__ __volatile__(
		"lock ; addl %2,%0; sets %1"
		:"=m"(v->counter), "=qm"(c)
		:"ir"(i), "m"(v->counter) : "memory");
	return( c );
}

//! Decrement and test.
//! \warning Guaranteed only for 24 bits.
static __INLINE__ int atomic_dec_and_test(atomic_t *v)
{
	unsigned char c;

	__asm__ __volatile__ (
		"lock\n"
		"decl %0\n"
		"sete %1"
		: "=m"(v->counter), "=qm"(c)
		: "m"(v->counter)
		: "memory" );
	return( c != 0 );
}

//! Increment and test.
//! \warning Guaranteed only for 24 bits.
static __INLINE__ int atomic_inc_and_test(atomic_t *v)
{
	unsigned char c;

	__asm__ __volatile__ (
		"lock\n"
		"incl %0\n"
		"sete %1"
		: "=m"(v->counter), "=qm"(c)
		: "m"(v->counter)
		: "memory" );
	return( c != 0 );
}

#endif
