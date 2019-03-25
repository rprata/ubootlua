#include <init.h>
#include <clockevent/clockevent.h>
#include <clocksource/clocksource.h>

const char * driver_list[3] = {
	"console",
	"clockevent",
	"clocksource"
};

void register_drivers() {
	int i = 0;
	for (i = 0; i < sizeof(driver_list); i++) {
		if (strcmp(driver_list[i], "console") == 0) {
			register_console_driver();
		}
		if (strcmp(driver_list[i], "clockevent") == 0) {
			register_clockevent_driver(NULL);
		}
		if (strcmp(driver_list[i], "clocksource") == 0) {
			register_clocksource_driver(NULL);
		}

	}
}

void print_banner() {
	assert(sizeof(BANNER_VERSION) != 0);
	printf(BANNER_VERSION);
}