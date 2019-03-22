#include <init.h>
#include <time.h>
int __start() {

    do_init_mem_pool();
    register_drivers();

    print_banner();

    struct timeval tv;
    gettimeofday(&tv, NULL);
    unsigned long ret = tv.tv_usec;
    ret /= 1000;
	ret += (tv.tv_sec * 1000);

	printf("%ul\n", ret);
    return 0;
}