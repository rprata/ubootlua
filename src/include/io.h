#ifndef __IO_H__
#define __IO_H__

#ifdef __cplusplus
extern "C" {
#endif

#include <types.h>

static inline u8_t read8(virtual_addr_t addr)
{
	return( *((volatile u8_t *)(int)(addr)) );
}

static inline u16_t read16(virtual_addr_t addr)
{
	return( *((volatile u16_t *)(int)(addr)) );
}

static inline u32_t read32(virtual_addr_t addr)
{
	return( *((volatile u32_t *)(int)(addr)) );
}

static inline u64_t read64(virtual_addr_t addr)
{
	return( *((volatile u64_t *)(int)(addr)) );
}

static inline void write8(virtual_addr_t addr, u8_t value)
{
	*((volatile u8_t *)(int)(addr)) = value;
}

static inline void write16(virtual_addr_t addr, u16_t value)
{
	*((volatile u16_t *)(int)(addr)) = value;
}

static inline void write32(virtual_addr_t addr, u32_t value)
{
	*((volatile u32_t *)(int)(addr)) = value;
}

static inline void write64(virtual_addr_t addr, u64_t value)
{
	*((volatile u64_t *)(int)(addr)) = value;
}

virtual_addr_t phys_to_virt(physical_addr_t phys);
physical_addr_t virt_to_phys(virtual_addr_t virt);

#ifdef __cplusplus
}
#endif

#endif /* __IO_H__ */
