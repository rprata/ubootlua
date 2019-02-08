#include <stddef.h>

/* https://codereview.stackexchange.com/questions/105114/re-implementing-memcpy */

void * memcpy(void * dst, const void * src, size_t n)
{
    void * ret = dst;
    asm volatile("rep movsb" : "+D" (dst) : "c"(n), "S"(src) : "cc", "memory");
    return ret;
}