#include <console.h>

char console_buffer[255];

void register_console_driver() {
	serial_init(TTYS0, BPS_115200);
}

void unregister_console_driver() {

}

ssize_t read_console_driver(void * message) {
    char c = '\0';
    int i = 0;
    while (c != '\r') {
        c = serial_getchar(TTYS0);
        console_buffer[i] = c;
        i++;
    }
    console_buffer[i] = '\0';
    message = console_buffer;
    memset(console_buffer, 0, sizeof(console_buffer));
    return sizeof(message);
}

ssize_t write_console_driver(void * message) {
	serial_print(TTYS0, (char *) message);
	return 0;
}
