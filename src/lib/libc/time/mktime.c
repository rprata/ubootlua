#include <time.h>

time_t mktime(struct tm * tm)
{
	return __tm_to_time(tm);
}
