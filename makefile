NASM:=nasm
CC:=gcc
SRC_NASM:=./src/init/boot.asm
SRC_C:=./src/init/boot.c
LINKER:=./src/init/linker.ld
DEPLOY=./deploy
BUILD:=./build
BIN:=$(DEPLOY)/boot.bin
OBJ_NASM:=$(BUILD)/boot.o
CFLAGS:=-m32 -fno-pie -ffreestanding -mno-red-zone -fno-exceptions -nostdlib -I./src/include 

export ARCH:=i386

all: zlib
	mkdir -p $(DEPLOY)
	mkdir -p $(BUILD)
	$(NASM) $(SRC_NASM) -f elf32 -o $(OBJ_NASM) 
	$(CC) $(SRC_C) $(OBJ_NASM) $(OBJ_LIBC) $(OBJ_ARCH) -o $(BIN) $(CFLAGS) -T $(LINKER)
run:
	qemu-system-i386 -fda $(BIN)


#########################
######### lib ###########
#########################

#########################
######## malloc #########
#########################
BUILD_LIBC_MALLOC:=./build/lib/libc/malloc
OBJ_LIBC_MALLOC:=$(BUILD_LIBC_MALLOC)/malloc.o

#########################
######### exit ##########
#########################
BUILD_LIBC_EXIT:=./build/lib/libc/exit
OBJ_LIBC_EXIT:=$(BUILD_LIBC_EXIT)/assert.o \
			   $(BUILD_LIBC_EXIT)/abort.o \
			   $(BUILD_LIBC_EXIT)/exit.o

OBJ_LIBC:=$(OBJ_LIBC_EXIT) $(OBJ_LIBC_MALLOC)
ifeq ($(ARCH),i386)
CFLAGS+=-I./src/arch/i386/include
endif
build/lib/libc/malloc/%.o: src/lib/libc/malloc/%.c
	mkdir -p build/lib/libc/malloc 
	$(CC) -c -o $@ $< $(CFLAGS)

build/lib/libc/exit/%.o: src/lib/libc/exit/%.c
	mkdir -p build/lib/libc/exit 
	$(CC) -c -o $@ $< $(CFLAGS)

libc_clean:
	rm -rf build/lib/libc

libc: arch $(OBJ_LIBC_EXIT) $(OBJ_LIBC_MALLOC)


#########################
######### arch ##########
#########################

BUILD_ARCH:=./build/arch
OBJ_ARCH:=$(BUILD_ARCH)/memcpy.o \
		  $(BUILD_ARCH)/memset.o \
		  $(BUILD_ARCH)/memcmp.o \

ifeq ($(ARCH),i386)
#########################
######### i386 ##########
#########################
build/arch/%.o: src/arch/i386/%.c
	mkdir -p build/arch 
	$(CC) -c -o $@ $< $(CFLAGS)

build/arch/%.o: src/arch/i386/%.S
	mkdir -p build/arch 
	$(CC) -c -o $@ $< $(CFLAGS)

arch_clean:
	rm -rf build/arch

arch: $(OBJ_ARCH)
endif

#########################
####### external ########
#########################

#########################
######### zlib ##########
#########################
BUILD_ZLIB:=./build/external/zlib
OBJ_ZLIB:=$(BUILD_ZLIB)/adler32.o \
		  $(BUILD_ZLIB)/compress.o \
		  $(BUILD_ZLIB)/crc32.o \
		  $(BUILD_ZLIB)/deflate.o \
		  $(BUILD_ZLIB)/gzclose.o \
		  $(BUILD_ZLIB)/inffast.o \
		  $(BUILD_ZLIB)/inflate.o \
		  $(BUILD_ZLIB)/inftrees.o \
		  $(BUILD_ZLIB)/trees.o \
		  $(BUILD_ZLIB)/uncompr.o \
		  $(BUILD_ZLIB)/zutil.o

		  # $(BUILD_ZLIB)/gzclose.o \
		  # $(BUILD_ZLIB)/gzlib.o \
		  # $(BUILD_ZLIB)/gzread.o \
		  # $(BUILD_ZLIB)/gzwrite.o \
		  # $(BUILD_ZLIB)/infback.o \


CFLAGS+=-I./src/external/zlib/ -DZ_SOLO

build/external/zlib/%.o: src/external/zlib/%.c
	mkdir -p build/external/zlib 
	$(CC) -c -o $@ $< $(CFLAGS)

zlib_clean:
	rm -rf build/external/zlib

zlib: libc $(OBJ_ZLIB) 
	# $(CC) -o $@ $(SRC_ZLIB) $(LDFLAGS)

clean: arch_clean zlib_clean
	rm -rf deploy
	rm -rf build

.PHONY: all run arch zlib clean arch_clean zlib_clean