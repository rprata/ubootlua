
int kmain() {
    short color = 0x0200;
    const char *msg = "Hello world! C example\0";
    short* vga = (short*)0xb8000;
    unsigned i = 0;
    for (i = 0; i < 23; ++i)
        vga[i+80] = color | msg[i];

    return 0;
}