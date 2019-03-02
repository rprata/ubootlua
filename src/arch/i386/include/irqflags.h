#ifndef __I386_IRQFLAGS_H__
#define __I386_IRQFLAGS_H__

#ifdef __cplusplus
extern "C" {
#endif

#include <types.h>

static inline void arch_local_irq_enable(void)
{
}

static inline void arch_local_irq_disable(void)
{
}

static inline irq_flags_t arch_local_irq_save(void)
{
	irq_flags_t flags = 0;
	return flags;
}

static inline void arch_local_irq_restore(irq_flags_t flags)
{
}

#ifndef local_irq_enable
#define local_irq_enable()			do { arch_local_irq_enable(); } while(0)
#endif 
#ifndef local_irq_disable
#define local_irq_disable()			do { arch_local_irq_disable(); } while(0)
#endif
#ifndef local_irq_save
#define local_irq_save(flags)		do { flags = arch_local_irq_save(); } while(0)
#endif
#ifndef local_irq_restore
#define local_irq_restore(flags)	do { arch_local_irq_restore(flags); } while(0)
#endif

#ifdef __cplusplus
}
#endif

#endif /* __I386_IRQFLAGS_H__ */
