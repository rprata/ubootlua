#include <stddef.h>

volatile int atomic_gate_memory = 0;
//https://embeddedartistry.com/blog/2017/2/9/implementing-malloc-first-fit-free-list
static inline void atomic_open(volatile int *gate)
{
  asm volatile (
      "wait:\n"
      "cmp %[lock], %[gate]\n"
      "je wait\n"
      "mov %[lock], %[gate]\n"
      : [gate] "=m" (*gate)
      : [lock] "r" (1)
  );
}

static inline void atomic_close(volatile int *gate)
{
  asm volatile (
      "mov %[lock], %[gate]\n"
      : [gate] "=m" (*gate)
      : [lock] "r" (0)
  );
}

void * _malloc(size_t n)
{
  atomic_open(&atomic_gate_memory);
  void *mem = malloc(n);
  atomic_close(&atomic_gate_memory);
  return mem;
}
#define malloc(size) _malloc(size)