NASM:=nasm
CC:=gcc
SRC_NASM:=./src/boot/boot.asm
SRC_C:=./src/boot/boot.c
LINKER:=./src/boot/linker.ld
DEPLOY=./deploy
BUILD:=./build
BIN:=$(DEPLOY)/boot.bin
OBJ_NASM:=$(BUILD)/boot.o
CFLAGS:=-m32 -fno-pie -ffreestanding -mno-red-zone -fno-exceptions -nostdlib -Wall -Wextra -Werror
all:
	mkdir -p $(DEPLOY)
	mkdir -p $(BUILD)
	$(NASM) $(SRC_NASM) -f elf32 -o $(OBJ_NASM) 
	$(CC) $(SRC_C) $(OBJ_NASM) -o $(BIN) $(CFLAGS) -T $(LINKER)
run:
	qemu-system-i386 -fda $(BIN)

clean:
	rm -rf $(BIN)
	rm -rf $(OBJ_NASM)
