NASM:=nasm
CC:=gcc
SRC_NASM:=./src/init/boot.asm
SRC_C:=./src/init/boot.c ./src/init/init.c ./src/init/version.c
LINKER:=./src/init/linker.ld
DEPLOY=./deploy
BUILD:=./build
BIN:=$(DEPLOY)/boot.bin
OBJ_NASM:=$(BUILD)/boot.o
CFLAGS:=-Wall -Werror -m32 -fno-pie -ffreestanding -mno-red-zone -fno-exceptions -nostdlib -I./src/include
LDFLAGS:=-Wl,--build-id=none
OC:=objcopy
DD:=dd
ELF:=$(DEPLOY)/boot.elf

export ARCH:=i386
export ZLIB_SUPPORT:=false
export KERNEL_SUPPORT:=true

DEPENDENCIES:=$(DEPENDENCIES) libc

	
ifeq ($(KERNEL_SUPPORT),true)
DEPENDENCIES:=$(DEPENDENCIES) kernel
endif

	
ifeq ($(ZLIB_SUPPORT),true)
DEPENDENCIES:=$(DEPENDENCIES) zlib
endif

all: $(DEPENDENCIES)
	mkdir -p $(DEPLOY)
	mkdir -p $(BUILD)
	$(NASM) $(SRC_NASM) -f elf32 -o $(OBJ_NASM)
	$(CC) $(SRC_C) $(OBJ_NASM) -o $(ELF) $(CFLAGS) -T $(LINKER) $(LDFLAGS)
	$(OC) -O binary $(ELF) $(BIN)
	$(DD) if=/dev/zero of=$(BIN).tmp count=1440 bs=1024
	$(DD) if=$(BIN) of=$(BIN).tmp conv=notrunc
	mv $(BIN).tmp $(BIN)
run:
	qemu-system-i386 -fda $(BIN) -nographic -serial stdio -monitor none




#########################
######## kernel #########
#########################

#########################
######### core ##########
#########################
LIB_KERNEL:=./build/kernel/libkernel.a
LDFLAGS+=-L./build/kernel -lkernel

BUILD_KERNEL_CORE:=./build/kernel/core
OBJ_KERNEL_CORE:=$(BUILD_KERNEL_CORE)/kobj.o \
				 $(BUILD_KERNEL_CORE)/initcall.o \
				 $(BUILD_KERNEL_CORE)/task.o \
				 $(BUILD_KERNEL_CORE)/mutex.o

#########################
######### vfs ##########
#########################
BUILD_KERNEL_VFS:=./build/kernel/vfs
OBJ_KERNEL_VFS:=$(BUILD_KERNEL_VFS)/vfs.o

OBJ_KERNEL:=$(OBJ_KERNEL_CORE) $(OBJ_KERNEL_VFS)

build/kernel/core/%.o: src/kernel/core/%.c
	mkdir -p build/kernel/core
	$(CC) -c -o $@ $< $(CFLAGS)

build/kernel/vfs/%.o: src/kernel/vfs/%.c
	mkdir -p build/kernel/vfs
	$(CC) -c -o $@ $< $(CFLAGS)

kernel_clean:
	rm -rf ./build/kernel/

kernel: $(OBJ_KERNEL) libc
	ar rcs $(LIB_KERNEL) $(OBJ_KERNEL)

#########################
######### libc ##########
#########################


#########################
######### errno #########
#########################
BUILD_LIBC_ERRNO:=./build/lib/libc/errno
OBJ_LIBC_ERRNO:=$(BUILD_LIBC_ERRNO)/strerror.o \
				 $(BUILD_LIBC_ERRNO)/errno.o

#########################
######## string #########
#########################
BUILD_LIBC_STRING:=./build/lib/libc/string
OBJ_LIBC_STRING:=$(BUILD_LIBC_STRING)/memchr.o \
				 $(BUILD_LIBC_STRING)/strcasecmp.o \
				 $(BUILD_LIBC_STRING)/strchr.o \
				 $(BUILD_LIBC_STRING)/strcpy.o \
				 $(BUILD_LIBC_STRING)/strdup.o \
				 $(BUILD_LIBC_STRING)/strlcpy.o \
				 $(BUILD_LIBC_STRING)/strncasecmp.o \
				 $(BUILD_LIBC_STRING)/strnchr.o \
				 $(BUILD_LIBC_STRING)/strnicmp.o \
				 $(BUILD_LIBC_STRING)/strnstr.o \
				 $(BUILD_LIBC_STRING)/strrchr.o \
				 $(BUILD_LIBC_STRING)/strspn.o \
				 $(BUILD_LIBC_STRING)/memscan.o \
				 $(BUILD_LIBC_STRING)/strcat.o \
				 $(BUILD_LIBC_STRING)/strcoll.o \
				 $(BUILD_LIBC_STRING)/strcspn.o \
				 $(BUILD_LIBC_STRING)/strlcat.o \
				 $(BUILD_LIBC_STRING)/strlen.o \
				 $(BUILD_LIBC_STRING)/strncat.o \
				 $(BUILD_LIBC_STRING)/strncpy.o \
				 $(BUILD_LIBC_STRING)/strnlen.o \
				 $(BUILD_LIBC_STRING)/strpbrk.o \
				 $(BUILD_LIBC_STRING)/strsep.o \
				 $(BUILD_LIBC_STRING)/strstr.o


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
######### stdio #########
#########################
BUILD_LIBC_STDIO:=./build/lib/libc/stdio
OBJ_LIBC_STDIO:=$(BUILD_LIBC_STDIO)/vsnprintf.o \
				$(BUILD_LIBC_STDIO)/fprintf.o \
				$(BUILD_LIBC_STDIO)/vasprintf.o \
				$(BUILD_LIBC_STDIO)/asprintf.o \
				$(BUILD_LIBC_STDIO)/sprintf.o \
				$(BUILD_LIBC_STDIO)/printf.o \
				$(BUILD_LIBC_STDIO)/fputs.o \
				$(BUILD_LIBC_STDIO)/fclose.o \
				$(BUILD_LIBC_STDIO)/feof.o \
				$(BUILD_LIBC_STDIO)/ferror.o \
				$(BUILD_LIBC_STDIO)/fgetc.o \
				$(BUILD_LIBC_STDIO)/fgets.o \
				$(BUILD_LIBC_STDIO)/fgetpos.o \
				$(BUILD_LIBC_STDIO)/clearerr.o \
				$(BUILD_LIBC_STDIO)/fflush.o \
				$(BUILD_LIBC_STDIO)/__stdio_read.o \
				$(BUILD_LIBC_STDIO)/__stdio_write.o \
				$(BUILD_LIBC_STDIO)/__stdio_flush.o \
				$(BUILD_LIBC_STDIO)/__stdio.o

				# need to create a virtual file system
				# $(BUILD_LIBC_STDIO)/fopen.o


#########################
######### time ##########
#########################
BUILD_LIBC_TIME:=./build/lib/libc/time
OBJ_LIBC_TIME:=$(BUILD_LIBC_TIME)/asctime.o \
			   $(BUILD_LIBC_TIME)/clock.o \
  			   $(BUILD_LIBC_TIME)/ctime.o \
  			   $(BUILD_LIBC_TIME)/difftime.o \
   			   $(BUILD_LIBC_TIME)/gmtime.o \
   			   $(BUILD_LIBC_TIME)/localtime.o \
   			   $(BUILD_LIBC_TIME)/mktime.o \
   			   $(BUILD_LIBC_TIME)/strftime.o \
   			   $(BUILD_LIBC_TIME)/time.o \
   			   $(BUILD_LIBC_TIME)/__time_to_tm.o \
   			   $(BUILD_LIBC_TIME)/__tm_to_time.o \
   			   $(BUILD_LIBC_TIME)/gettimeofday.o 

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

OBJ_LIBC:=$(OBJ_LIBC_EXIT) $(OBJ_LIBC_MALLOC) $(OBJ_LIBC_STDIO) $(OBJ_LIBC_STDLIB) $(OBJ_LIBC_TIME) $(OBJ_LIBC_CHARSET) $(OBJ_LIBC_CRYPTO) $(OBJ_LIBC_CTYPE) $(OBJ_LIBC_STRING) $(OBJ_LIBC_ERRNO)
LIB_LIBC:=./build/lib/libc/libc.a
LDFLAGS+=-L./build/lib/libc -lc \
		 -L./build/lib/libm -lm

ifeq ($(ARCH),i386)
LDFLAGS+=-static-libgcc -L/usr/lib32 -lgcc
endif

ifeq ($(ARCH),i386)
CFLAGS+=-I./src/arch/i386/include
CFLAGS+=-I./src/arch/i386/driver/include
endif

build/lib/libc/errno/%.o: src/lib/libc/errno/%.c
	mkdir -p build/lib/libc/errno 
	$(CC) -c -o $@ $< $(CFLAGS)

build/lib/libc/string/%.o: src/lib/libc/string/%.c
	mkdir -p build/lib/libc/string 
	$(CC) -c -o $@ $< $(CFLAGS)

build/lib/libc/ctype/%.o: src/lib/libc/ctype/%.c
	mkdir -p build/lib/libc/ctype 
	$(CC) -c -o $@ $< $(CFLAGS)

build/lib/libc/crypto/%.o: src/lib/libc/crypto/%.c
	mkdir -p build/lib/libc/crypto 
	$(CC) -c -o $@ $< $(CFLAGS)

build/lib/libc/charset/%.o: src/lib/libc/charset/%.c
	mkdir -p build/lib/libc/charset 
	$(CC) -c -o $@ $< $(CFLAGS)

build/lib/libc/time/%.o: src/lib/libc/time/%.c
	mkdir -p build/lib/libc/time 
	$(CC) -c -o $@ $< $(CFLAGS)

build/lib/libc/stdio/%.o: src/lib/libc/stdio/%.c
	mkdir -p build/lib/libc/stdio 
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

libc: arch std libm $(OBJ_LIBC)
	ar rcs $(LIB_LIBC) $(OBJ_ARCH) $(OBJ_STD) $(OBJ_LIBC) \
	$(OBJ_DRIVER_SERIAL) \
	$(OBJ_DRIVER_CONSOLE) \
	$(OBJ_DRIVER_TIME) \
	$(OBJ_DRIVER_CLK_EVT) \
	$(OBJ_DRIVER_CLK_SRC)


#########################
######### libm  #########
#########################
LIB_LIBM:=./build/lib/libm/libm.a
BUILD_LIBM:=./build/lib/libm
OBJ_LIBM:=$(BUILD_LIBM)/truncf.o \
		  $(BUILD_LIBM)/trunc.o \
		  $(BUILD_LIBM)/tanhf.o \
		  $(BUILD_LIBM)/tanh.o \
		  $(BUILD_LIBM)/tanf.o \
		  $(BUILD_LIBM)/tan.o \
		  $(BUILD_LIBM)/sqrtf.o \
		  $(BUILD_LIBM)/sqrt.o \
		  $(BUILD_LIBM)/sinhf.o \
		  $(BUILD_LIBM)/sinh.o \
		  $(BUILD_LIBM)/sinf.o \
		  $(BUILD_LIBM)/sin.o \
		  $(BUILD_LIBM)/scalbnf.o \
		  $(BUILD_LIBM)/scalbn.o \
		  $(BUILD_LIBM)/scalblnf.o \
		  $(BUILD_LIBM)/scalbln.o \
		  $(BUILD_LIBM)/roundf.o \
		  $(BUILD_LIBM)/round.o \
		  $(BUILD_LIBM)/rintf.o \
		  $(BUILD_LIBM)/rint.o \
		  $(BUILD_LIBM)/powf.o \
		  $(BUILD_LIBM)/pow.o \
		  $(BUILD_LIBM)/modf.o \
		  $(BUILD_LIBM)/modff.o \
		  $(BUILD_LIBM)/logf.o \
		  $(BUILD_LIBM)/log2f.o \
		  $(BUILD_LIBM)/log2.o \
		  $(BUILD_LIBM)/log1pf.o \
		  $(BUILD_LIBM)/log1p.o \
		  $(BUILD_LIBM)/log10f.o \
		  $(BUILD_LIBM)/log10.o \
		  $(BUILD_LIBM)/ldexp.o \
		  $(BUILD_LIBM)/ldexpf.o \
		  $(BUILD_LIBM)/hypotf.o \
		  $(BUILD_LIBM)/hypot.o \
		  $(BUILD_LIBM)/frexpf.o \
		  $(BUILD_LIBM)/frexp.o \
		  $(BUILD_LIBM)/fmodf.o \
		  $(BUILD_LIBM)/fmod.o \
		  $(BUILD_LIBM)/floorf.o \
		  $(BUILD_LIBM)/fdimf.o \
		  $(BUILD_LIBM)/fdim.o \
		  $(BUILD_LIBM)/fabsf.o \
		  $(BUILD_LIBM)/fabs.o \
		  $(BUILD_LIBM)/expm1f.o \
		  $(BUILD_LIBM)/expm1.o \
		  $(BUILD_LIBM)/expf.o \
		  $(BUILD_LIBM)/exp2f.o \
		  $(BUILD_LIBM)/exp2.o \
		  $(BUILD_LIBM)/exp.o \
		  $(BUILD_LIBM)/coshf.o \
		  $(BUILD_LIBM)/cosh.o \
		  $(BUILD_LIBM)/cosf.o \
		  $(BUILD_LIBM)/cos.o \
		  $(BUILD_LIBM)/ceilf.o \
		  $(BUILD_LIBM)/ceil.o \
		  $(BUILD_LIBM)/cbrtf.o \
		  $(BUILD_LIBM)/cbrt.o \
		  $(BUILD_LIBM)/atanhf.o \
		  $(BUILD_LIBM)/atanh.o \
		  $(BUILD_LIBM)/atanf.o \
		  $(BUILD_LIBM)/atan2f.o \
		  $(BUILD_LIBM)/atan2.o \
		  $(BUILD_LIBM)/atan.o \
		  $(BUILD_LIBM)/asinhf.o \
		  $(BUILD_LIBM)/asinhf.o\
		  $(BUILD_LIBM)/asinf.o \
		  $(BUILD_LIBM)/asin.o \
		  $(BUILD_LIBM)/acoshf.o \
		  $(BUILD_LIBM)/acosh.o \
		  $(BUILD_LIBM)/acosf.o \
		  $(BUILD_LIBM)/acos.o \
		  $(BUILD_LIBM)/__cos.o \
		  $(BUILD_LIBM)/__cosdf.o \
		  $(BUILD_LIBM)/__expo2.o \
		  $(BUILD_LIBM)/__expo2f.o \
		  $(BUILD_LIBM)/__fpclassify.o \
		  $(BUILD_LIBM)/__fpclassifyf.o \
		  $(BUILD_LIBM)/__rem_pio2.o \
		  $(BUILD_LIBM)/__rem_pio2f.o \
		  $(BUILD_LIBM)/__rem_pio2_large.o \
		  $(BUILD_LIBM)/__sin.o \
		  $(BUILD_LIBM)/__sindf.o \
		  $(BUILD_LIBM)/__tan.o \
		  $(BUILD_LIBM)/__tandf.o

build/lib/libm/%.o: src/lib/libm/%.c
	mkdir -p build/lib/libm 
	$(CC) -c -o $@ $< $(CFLAGS)

libm_clean:
	rm -rf build/lib/libm

libm: $(OBJ_LIBM)
	ar rcs $(LIB_LIBM) $(OBJ_LIBM)


#########################
######### arch ##########
#########################

BUILD_ARCH:=./build/arch
OBJ_ARCH:=$(BUILD_ARCH)/memcpy.o \
		  $(BUILD_ARCH)/memset.o \
		  $(BUILD_ARCH)/memmove.o \
		  $(BUILD_ARCH)/memcmp.o \
		  $(BUILD_ARCH)/strcmp.o \
		  $(BUILD_ARCH)/strncmp.o \
		  $(BUILD_ARCH)/setjmp.o

#########################
######## driver #########
#########################

#########################
######## serial #########
#########################

BUILD_DRIVER_SERIAL:=./build/arch/driver/serial
OBJ_DRIVER_SERIAL:=$(BUILD_DRIVER_SERIAL)/serial.o

#########################
######## console ########
#########################

BUILD_DRIVER_CONSOLE:=./build/arch/driver/console
OBJ_DRIVER_CONSOLE:=$(BUILD_DRIVER_CONSOLE)/console.o

#########################
######### time ##########
#########################

BUILD_DRIVER_TIME:=./build/arch/driver/time
OBJ_DRIVER_TIME:=$(BUILD_DRIVER_TIME)/timer.o

#########################
######## clock ##########
######## event ##########
#########################

BUILD_DRIVER_CLK_EVT:=./build/arch/driver/clockevent
OBJ_DRIVER_CLK_EVT:=$(BUILD_DRIVER_CLK_EVT)/clockevent.o

#########################
######## clock ##########
######## source #########
#########################

BUILD_DRIVER_CLK_SRC:=./build/arch/driver/clocksource
OBJ_DRIVER_CLK_SRC:=$(BUILD_DRIVER_CLK_SRC)/clocksource.o

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

build/arch/driver/serial/%.o: src/arch/i386/driver/serial/%.c
	mkdir -p build/arch/driver/serial 
	$(CC) -c -o $@ $< $(CFLAGS)

build/arch/driver/console/%.o: src/arch/i386/driver/console/%.c
	mkdir -p build/arch/driver/console 
	$(CC) -c -o $@ $< $(CFLAGS)

build/arch/driver/time/%.o: src/arch/i386/driver/time/%.c
	mkdir -p build/arch/driver/time 
	$(CC) -c -o $@ $< $(CFLAGS)

build/arch/driver/clockevent/%.o: src/arch/i386/driver/clockevent/%.c
	mkdir -p build/arch/driver/clockevent 
	$(CC) -c -o $@ $< $(CFLAGS)

build/arch/driver/clocksource/%.o: src/arch/i386/driver/clocksource/%.c
	mkdir -p build/arch/driver/clocksource 
	$(CC) -c -o $@ $< $(CFLAGS)

endif

arch_clean:
	rm -rf build/arch

arch: serial console time clk_evt clk_src $(OBJ_ARCH)

serial_clean:
	rm -rf build/arch/driver/serial

serial: $(OBJ_DRIVER_SERIAL)

console_clean:
	rm -rf build/arch/driver/console

console: $(OBJ_DRIVER_CONSOLE)

time_clean:
	rm -rf build/arch/driver/time

time: $(OBJ_DRIVER_TIME)

clk_evt_clean:
	rm -rf build/arch/driver/clockevent

clk_evt: $(OBJ_DRIVER_CLK_EVT)

clk_src_clean:
	rm -rf build/arch/driver/clocksource

clk_src: $(OBJ_DRIVER_CLK_SRC)

#########################
####### lib std #########
#########################
BUILD_STD:=./build/lib/std
OBJ_STD:=$(BUILD_STD)/fifo.o \
		 $(BUILD_STD)/queue.o \
		 $(BUILD_STD)/rbtree.o

build/lib/std/%.o: src/lib/std/%.c
	mkdir -p build/lib/std 
	$(CC) -c -o $@ $< $(CFLAGS)

std_clean:
	rm -rf build/lib/std

std: $(OBJ_STD)

#########################
####### external ########
#########################

ifeq ($(ZLIB_SUPPORT),true)
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
endif 

clean:
	rm -rf deploy
	rm -rf build

.PHONY: all run arch zlib clean arch_clean zlib_clean