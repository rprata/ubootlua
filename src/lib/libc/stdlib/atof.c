#include <stdlib.h>

double atof(const char * nptr)
{
	return (double)strtod(nptr, 0);
}