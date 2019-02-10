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
LDFLAGS:=
export ARCH:=i386

all: zlib
	mkdir -p $(DEPLOY)
	mkdir -p $(BUILD)
	$(NASM) $(SRC_NASM) -f elf32 -o $(OBJ_NASM) 
	$(CC) $(SRC_C) $(OBJ_NASM) -o $(BIN) $(CFLAGS) -T $(LINKER) $(LDFLAGS)
run:
	qemu-system-i386 -fda $(BIN)


#########################
######### libc ##########
#########################

#########################
######### ctype #########
#########################
BUILD_LIBC_CTYPE:=./build/lib/libc/ctype
OBJ_LIBC_CTYPE:=$(BUILD_LIBC_CTYPE)/isalnum.o \
				$(BUILD_LIBC_CTYPE)/isalpha.o \
				$(BUILD_LIBC_CTYPE)/isascii.o \
				$(BUILD_LIBC_CTYPE)/isblank.o \
				$(BUILD_LIBC_CTYPE)/iscntrl.o \
				$(BUILD_LIBC_CTYPE)/isdigit.o \
				$(BUILD_LIBC_CTYPE)/isgraph.o \
				$(BUILD_LIBC_CTYPE)/islower.o \
				$(BUILD_LIBC_CTYPE)/isprint.o \
				$(BUILD_LIBC_CTYPE)/ispunct.o \
				$(BUILD_LIBC_CTYPE)/isspace.o \
				$(BUILD_LIBC_CTYPE)/isupper.o \
				$(BUILD_LIBC_CTYPE)/isxdigit.o \
				$(BUILD_LIBC_CTYPE)/toascii.o \
				$(BUILD_LIBC_CTYPE)/tolower.o \
				$(BUILD_LIBC_CTYPE)/toupper.o

#########################
######## crypto #########
#########################
BUILD_LIBC_CRYPTO:=./build/lib/libc/crypto
OBJ_LIBC_CRYPTO:=$(BUILD_LIBC_CRYPTO)/aes128.o \
				 $(BUILD_LIBC_CRYPTO)/crc16.o \
				 $(BUILD_LIBC_CRYPTO)/crc32.o \
				 $(BUILD_LIBC_CRYPTO)/crc8.o \
				 $(BUILD_LIBC_CRYPTO)/sha1.o \
				 $(BUILD_LIBC_CRYPTO)/sha256.o

#########################
######## charset ########
#########################
BUILD_LIBC_CHARSET:=./build/lib/libc/charset
OBJ_LIBC_CHARSET:=$(BUILD_LIBC_CHARSET)/charset.o

#########################
######## stdlib #########
#########################
BUILD_LIBC_STDLIB:=./build/lib/libc/stdlib
OBJ_LIBC_STDLIB:=$(BUILD_LIBC_STDLIB)/abs.o \
				 $(BUILD_LIBC_STDLIB)/atoi.o \
				 $(BUILD_LIBC_STDLIB)/atoll.o \
				 $(BUILD_LIBC_STDLIB)/div.o \
				 $(BUILD_LIBC_STDLIB)/ldiv.o \
				 $(BUILD_LIBC_STDLIB)/lldiv.o \
				 $(BUILD_LIBC_STDLIB)/strntoumax.o \
 				 $(BUILD_LIBC_STDLIB)/strtoimax.o \
				 $(BUILD_LIBC_STDLIB)/strtoll.o \
				 $(BUILD_LIBC_STDLIB)/strtoull.o \
				 $(BUILD_LIBC_STDLIB)/atof.o \
				 $(BUILD_LIBC_STDLIB)/atol.o \
				 $(BUILD_LIBC_STDLIB)/bsearch.o \
				 $(BUILD_LIBC_STDLIB)/labs.o \
				 $(BUILD_LIBC_STDLIB)/llabs.o \
				 $(BUILD_LIBC_STDLIB)/qsort.o \
				 $(BUILD_LIBC_STDLIB)/strntoimax.o \
				 $(BUILD_LIBC_STDLIB)/strtod.o \
				 $(BUILD_LIBC_STDLIB)/strtol.o \
				 $(BUILD_LIBC_STDLIB)/strtoul.o \
				 $(BUILD_LIBC_STDLIB)/strtoumax.o
				 # Its necessary to implement clock driver
 				 #$(BUILD_LIBC_STDLIB)/rand.o 

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

OBJ_LIBC:=$(OBJ_LIBC_EXIT) $(OBJ_LIBC_MALLOC) $(OBJ_LIBC_STDLIB) $(OBJ_LIBC_CHARSET) $(OBJ_LIBC_CRYPTO) $(OBJ_LIBC_CTYPE)
LIB_LIBC:=./build/lib/libc/libc.a
LDFLAGS+=-L./build/lib/libc -lc
ifeq ($(ARCH),i386)
CFLAGS+=-I./src/arch/i386/include
endif


build/lib/libc/ctype/%.o: src/lib/libc/ctype/%.c
	mkdir -p build/lib/libc/ctype 
	$(CC) -c -o $@ $< $(CFLAGS)

build/lib/libc/crypto/%.o: src/lib/libc/crypto/%.c
	mkdir -p build/lib/libc/crypto 
	$(CC) -c -o $@ $< $(CFLAGS)

build/lib/libc/charset/%.o: src/lib/libc/charset/%.c
	mkdir -p build/lib/libc/charset 
	$(CC) -c -o $@ $< $(CFLAGS)

build/lib/libc/stdlib/%.o: src/lib/libc/stdlib/%.c
	mkdir -p build/lib/libc/stdlib 
	$(CC) -c -o $@ $< $(CFLAGS)

build/lib/libc/malloc/%.o: src/lib/libc/malloc/%.c
	mkdir -p build/lib/libc/malloc 
	$(CC) -c -o $@ $< $(CFLAGS)

build/lib/libc/exit/%.o: src/lib/libc/exit/%.c
	mkdir -p build/lib/libc/exit 
	$(CC) -c -o $@ $< $(CFLAGS)

libc_clean:
	rm -rf build/lib/libc

libc: arch $(OBJ_LIBC)
	ar rcs $(LIB_LIBC) $(OBJ_LIBC) $(OBJ_ARCH)

#########################
######### arch ###### ###
#########################

BUILD_ARCH:=./build/arch
OBJ_ARCH:=$(BUILD_ARCH)/memcpy.o \
		  $(BUILD_ARCH)/memset.o \
		  $(BUILD_ARCH)/memcmp.o \
		  $(BUILD_ARCH)/setjmp.o

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
		  $(BUILD_ZLIB)/infback.o \
		  $(BUILD_ZLIB)/inffast.o \
		  $(BUILD_ZLIB)/inflate.o \
		  $(BUILD_ZLIB)/inftrees.o \
		  $(BUILD_ZLIB)/trees.o \
		  $(BUILD_ZLIB)/uncompr.o \
		  $(BUILD_ZLIB)/zutil.o 

		  # it's necessary to implement close(), open(), read(), write() and lseek()
		  #$(BUILD_ZLIB)/gzclose.o 
		  #$(BUILD_ZLIB)/gzlib.o \
		  #$(BUILD_ZLIB)/gzread.o \
		  #$(BUILD_ZLIB)/gzwrite.o 

LIB_ZLIB:=./build/external/zlib/libz.a
CFLAGS+=-I./src/external/zlib
LDFLAGS+=-L./build/external/zlib -lz

build/external/zlib/%.o: src/external/zlib/%.c
	mkdir -p build/external/zlib 
	$(CC) -c -o $@ $< $(CFLAGS)

zlib_clean:
	rm -rf build/external/zlib

zlib: libc $(OBJ_ZLIB) 
	ar rcs $(LIB_ZLIB) $(OBJ_ZLIB)

clean: arch_clean zlib_clean
	rm -rf deploy
	rm -rf build

.PHONY: all run arch zlib clean arch_clean zlib_clean