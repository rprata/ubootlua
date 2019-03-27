section .boot
bits 16                     ; We're working at 16-bit mode here
global boot

boot:
    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov sp, 0x7c00          ; Set SS:SP just below bootloader

    cld                     ; DF=0 : string instruction forward movement
    mov ax, 0x2401
    int 0x15                ; Enable A20 bit

    mov ax, 0x3             ; Set VGA text mode 3
    int 0x10                ; Otherwise, call interrupt for printing the char

    mov [disk],dl

    ; Read 64 sectors from LBA 1, CHS=0,0,2 to address 0x0800:0
    mov ax, 0x0800
    mov es, ax              ;ES = 0x800

    mov ah, 0x2             ;read sectors
    mov al, 64              ;sectors to read
    mov ch, 0               ;cylinder idx
    mov dh, 0               ;head idx
    mov cl, 2               ;sector idx
    mov dl, [disk]          ;disk idx
    mov bx, 0               ;target pointer, ES:BX=0x0800:0x0000
    int 0x13

    ; Read 64 sectors from LBA 65, CHS=1,1,12 to address 0x1000:0
    mov ax, 0x1000
    mov es, ax              ;ES=0x1000

    mov ah, 0x2             ;read sectors
    mov al, 64              ;sectors to read
    mov ch, 1               ;cylinder idx
    mov dh, 1               ;head idx
    mov cl, 12              ;sector idx
    mov dl, [disk]          ;disk idx
    mov bx, 0x0000          ;target pointer, ES:BX=0x1000:0x0000
    int 0x13

    cli                     ; Disable the interrupts
    lgdt [gdt_pointer]      ; Load the gdt table
    mov eax, cr0            ; Init swap cr0...
    or eax,0x1              ; Set the protected mode bit on special CPU reg cr0
    mov cr0, eax
    jmp CODE_SEG:boot32     ; Long jump to the code segment


; base a 32 bit value describing where the segment begins
; limit a 20 bit value describing where the segment ends, can be multiplied by 4096
; if granularity = 1
; present must be 1 for the entry to be valid
; ring level an int between 0-3 indicating the kernel Ring Level
; direction:
;  > 0 = segment grows up from base, 1 = segment grows down for a data segment
;  > 0 = can only execute from ring level, 1 = prevent jumping to higher ring levels
; read/write if you can read/write to this segment
; accessed if the CPU has accessed this segment
; granularity 0 = limit is in 1 byte blocks, 1 = limit is multiples of 4KB blocks
; size 0 = 16 bit mode, 1 = 32 bit protected mode
gdt_start:
    dq 0x0
gdt_code:
    dw 0xFFFF
    dw 0x0
    db 0x0
    db 10011010b
    db 11001111b
    db 0x0
gdt_data:
    dw 0xFFFF
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0
gdt_end:
gdt_pointer:
    dw gdt_end - gdt_start
    dd gdt_start
disk:
    db 0x0

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

;; Magic numbers
times 510 - ($ - $$) db 0
dw 0xaa55

section .data
msg: db "Hello, World more than 512 bytes!", 0

bits 32
section .text.start
boot32:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    ;mov esi, msg        ; SI now points to our message
    ;mov ebx, 0xb8000    ; vga memory position (0)

.loop:
    lodsb               ; Loads SI into AL and increments SI [next char]
    or al, al           ; Checks if the end of the string
    jz halt             ; Jump to halt if the end
    or eax,0x0200       ; The top byte defines the character colour in the buffer as
                        ; an int value from 0-15 with 0 = black, 1 = blue and 15 = white.
                        ; The bottom byte defines an ASCII code point
    mov word [ebx], ax
    add ebx, 2
    jmp .loop           ; Next iteration of the loop

halt:
    mov esp, kernel_stack_top
    extern __start
    extern __bss_start
    extern __bss_sizel

    ; Zero the BSS section
    mov ecx, __bss_sizel
    mov edi, __bss_start
    xor eax, eax
    rep stosd

    ; Call C entry point
    call __start
    cli
    hlt                 ; CPU command to halt the execution

section .bss
align 4
kernel_stack_bottom:
    resb 16384          ; 16 KB stack
kernel_stack_top:
