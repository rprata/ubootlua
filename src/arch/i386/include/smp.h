#ifndef __SMP_H__
#define __SMP_H__

#ifdef __cplusplus
extern "C" {
#endif

static inline int smp_processor_id(void)
{
	return 0;
}

#ifdef __cplusplus
}
#endif

#endif /* __SMP_H__ */
