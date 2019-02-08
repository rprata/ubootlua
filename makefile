NASM:=nasm
CC:=gcc
SRC_NASM:=./src/core/boot.asm
SRC_C:=./src/core/boot.c
LINKER:=./src/core/linker.ld
DEPLOY=./deploy
BUILD:=./build
BIN:=$(DEPLOY)/boot.bin
OBJ_NASM:=$(BUILD)/boot.o
CFLAGS:=-m32 -fno-pie -ffreestanding -mno-red-zone -fno-exceptions -nostdlib -Wall -Werror



all: zlib
	mkdir -p $(DEPLOY)
	mkdir -p $(BUILD)
	$(NASM) $(SRC_NASM) -f elf32 -o $(OBJ_NASM) 
	$(CC) $(SRC_C) $(OBJ_NASM) $(OBJ_ARCH) -o $(BIN) $(CFLAGS) -T $(LINKER)
run:
	qemu-system-i386 -fda $(BIN)

# arch
BUILD_ARCH:=./build/arch
OBJ_ARCH:=$(BUILD_ARCH)/memcpy.o \
		  $(BUILD_ARCH)/memset.o \
		  $(BUILD_ARCH)/malloc.o


# i386
CFLAGS+=-I./src/arch/i386
build/arch/%.o: src/arch/i386/%.c
	mkdir -p build/arch 
	$(CC) -c -o $@ $< $(CFLAGS)

arch: $(OBJ_ARCH)

# extenal 
# zlib 1.2.9
BUILD_ZLIB:=./build/zlib
OBJ_ZLIB:=$(BUILD_ZLIB)/adler32.o \
		  $(BUILD_ZLIB)/compress.o \
		  $(BUILD_ZLIB)/crc32.o \
		  $(BUILD_ZLIB)/deflate.o \
		  $(BUILD_ZLIB)/infback.o \
		  $(BUILD_ZLIB)/inffast.o \
		  $(BUILD_ZLIB)/inflate.o \
		  $(BUILD_ZLIB)/inftrees.o \
		  $(BUILD_ZLIB)/trees.o \
		  $(BUILD_ZLIB)/uncompr.o \
		  $(BUILD_ZLIB)/zutil.o

CFLAGS+=-I./src/external/zlib/

build/zlib/%.o: src/external/zlib/%.c
	mkdir -p build/zlib 
	$(CC) -c -o $@ $< $(CFLAGS)

zlib: $(OBJ_ZLIB) 
	# $(CC) -o $@ $(SRC_ZLIB) $(LDFLAGS)

clean:
	rm -rf $(BIN)
	rm -rf $(OBJ_NASM)
