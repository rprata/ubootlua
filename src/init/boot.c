#include <init.h>
#include <time.h>
int __start() {

    do_init_mem_pool();
    register_drivers();
    
    do_init_vfs();
    
    print_banner();

    
    return 0;
}