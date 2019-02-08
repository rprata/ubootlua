section .boot
bits 16                     ; We're working at 16-bit mode here
global boot

boot:
    mov ax, 0x2401			
    int 0x15 				; Enable A20 bit 
	
	mov ax, 0x3 			; Set VGA text mode 3
	int 0x10                ; Otherwise, call interrupt for printing the char	
	
	mov [disk],dl

	mov ah, 0x2    			;read sectors
	mov al, 6      			;sectors to read
	mov ch, 0      			;cylinder idx
	mov dh, 0      			;head idx
	mov cl, 2      			;sector idx
	mov dl, [disk] 			;disk idx
	mov bx, copy_target		;target pointer
	int 0x13

	cli                     ; Disable the interrupts
	lgdt [gdt_pointer] 		; Load the gdt table
	mov eax, cr0 			; Init swap cr0...
	or eax,0x1 				; Set the protected mode bit on special CPU reg cr0
	mov cr0, eax
	jmp CODE_SEG:boot32		; Long jump to the code segment


; base a 32 bit value describing where the segment begins
; limit a 20 bit value describing where the segment ends, can be multiplied by 4096 if granularity = 1
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
copy_target:
bits 32
	msg:	db "Hello, World more than 512 bytes!", 0

boot32:
	mov ax, DATA_SEG
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax	
	mov esi, msg            ; SI now points to our message
	mov ebx, 0xb8000		; vga memory position (0) 

.loop	lodsb               ; Loads SI into AL and increments SI [next char]
	or al, al               ; Checks if the end of the string
	jz halt                 ; Jump to halt if the end
	or eax,0x0200			; The top byte defines the character colour in the buffer as an int value from 0-15 with 0 = black, 1 = blue and 15 = white. 
							; The bottom byte defines an ASCII code point
    mov word [ebx], ax		
    add ebx, 2				
	jmp .loop               ; Next iteration of the loop

halt: 	
	mov esp,kernel_stack_top
	extern init_lua_script
	call init_lua_script
	cli
	hlt                     ; CPU command to halt the execution

section .bss
align 4
kernel_stack_bottom: equ $
	resb 16384 ; 16 KB
kernel_stack_top: