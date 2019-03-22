#include <time.h>
#include <clocksource/clocksource.h>

int gettimeofday(struct timeval * tv, void * tz)
{
	if(!tv)
		return -1;

	ktime_t kt = ktime_get();
	tv->tv_sec = ktime_to_ns(kt) / 1000000000ULL;
	tv->tv_usec = (ktime_to_ns(kt) % 1000000000ULL) / 1000;
	return 0;
}
