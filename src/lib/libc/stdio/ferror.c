#include <stdio.h>

int ferror(FILE * f)
{
	return f->error;
}