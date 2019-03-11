#include <stdio.h>
#include <assert.h>
#include <error.h>

void __assert_fail(const char * expr, const char * file, int line, const char * func)
{
	fprintf(stderr, "Assertion failed: %s (%s: %s: %d)\n", expr, file, func, line);
	while(1);
}