ENTRY(boot)
SECTIONS {
    . = 0x7c00;
    .boot :
    {
        *(.boot)
    }
    /* Place kernel right after boot sector on disk but set the
     * VMA (ORiGin point) to 0x8000 */
    .text 0x8000 : AT(0x7e00)
    {
        __kernel_start = .;
        *(.text.start)
        *(.text*)
    }
    .rodata :
    {
        *(.rodata*)
    }
    .data :
    {
        *(.data)
    }
    __kernel_end = .;
    /* Compute number of sectors that the kernel uses */
    __kernel_size = (__kernel_end - __kernel_start + 511) / 512;

    .bss :
    {
        __bss_start = .;
        *(COMMON)
        *(.bss)
        . = ALIGN(4);
        __bss_end = .;
        /* Compute number of DWORDS that BSS section uses */
        __bss_sizel = (__bss_end - __bss_start) / 4;
    }
}
