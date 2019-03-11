#include <init.h>

const char * driver_list[1] = {
	"console"
};

void register_drivers() {
	int i = 0;
	for (i = 0; i < sizeof(driver_list); i++) {
		if (strcmp(driver_list[i], "console") == 0) {
			register_console_driver();
		}
	}
}

void print_banner() {
	assert(sizeof(BANNER_VERSION) != 0);
	printf(BANNER_VERSION);
}