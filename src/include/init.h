#ifndef __INIT_H__
#define __INIT_H__

#ifdef __cplusplus
extern "C" {
#endif

#include <version.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <console.h>
#include <vfs/vfs.h>

void register_drivers(void);

void do_init_mem_pool(void);

void print_banner(void);

#ifdef __cplusplus
}
#endif

#endif
