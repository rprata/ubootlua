#include <serial.h>

void serial_init(word port, byte divisor) {
    // Turn off rs232 interrupt
    outb(port + 1, 0x00);
    // Set DLAB on 
    outb(port + 3, 0x80);
    // Set baud rate - Divisor Latch Low Byte
    outb(port + 0, divisor);
     // Set baud rate - Divisor Latch High Byte    
    outb(port + 1, 0x00);
    // 8 bits, no parity, 1 stop-bit
    outb(port + 3, 0x03);
    // FIFO Control Register
    outb(port + 2, 0xC7);
    // Turn on DTR, RTS and OUT2
    outb(port + 4, 0x0B);

    // Enable interrupts when data is received 
    outb(port + 1, 0x01);

    // Clear receiver
    (void)inb(port);
    // Clear line status
    (void)inb(port + 5);
    // Clear modem status
    (void)inb(port + 6);    
}

void serial_putchar(word port, char c) {
    // Wait for transmit to be empty
    while (!(inb(port + 5) & 0x20));
    outb(port, c);
}

void serial_print(word port, const char *s) {
    while (*s) {
        serial_putchar(port, *(s)++);
    }
}

void serial_println(word port, const char *s) {
    while (*s) {
        serial_putchar(port, *(s)++);
    }
    serial_putchar(port, '\n');
}