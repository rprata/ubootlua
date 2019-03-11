#include <init.h>

int __start() {

    do_init_mem_pool();
    register_drivers();

    print_banner();

    return 0;
}