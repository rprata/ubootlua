
#include <clocksource/clocksource.h>

/*
 * Dummy clocksource, 10us - 100KHZ
 */
static u64_t __cs_dummy_read(struct clocksource_t * cs)
{
	static volatile u64_t __cs_dummy_cycle = 0;
	return __cs_dummy_cycle++;
}

static struct clocksource_t __cs_dummy = {
	.keeper = {
		.interval = 35184372083832,
		.last = 0,
		.nsec = 0,
		.lock = { 0 },
	},
	.name = "cs-dummy",
	.mask = CLOCKSOURCE_MASK(64),
	.mult = 2621440000,
	.shift = 18,
	.read = __cs_dummy_read,
};
static struct clocksource_t * __clocksource = &__cs_dummy;
static spinlock_t __clocksource_lock = SPIN_LOCK_INIT();

ssize_t clocksource_read_mult(struct kobj_t * kobj, void * buf, size_t size)
{
	struct clocksource_t * cs = (struct clocksource_t *)kobj->priv;
	return sprintf(buf, "%u", cs->mult);
}

ssize_t clocksource_read_shift(struct kobj_t * kobj, void * buf, size_t size)
{
	struct clocksource_t * cs = (struct clocksource_t *)kobj->priv;
	return sprintf(buf, "%u", cs->shift);
}

ssize_t clocksource_read_period(struct kobj_t * kobj, void * buf, size_t size)
{
	struct clocksource_t * cs = (struct clocksource_t *)kobj->priv;
	u64_t period = ((u64_t)cs->mult) >> cs->shift;
	return sprintf(buf, "%llu.%09llu", period / 1000000000ULL, period % 1000000000ULL);
}

ssize_t clocksource_read_deferment(struct kobj_t * kobj, void * buf, size_t size)
{
	struct clocksource_t * cs = (struct clocksource_t *)kobj->priv;
	u64_t max = clocksource_deferment(cs);
	return sprintf(buf, "%llu.%09llu", max / 1000000000ULL, max % 1000000000ULL);
}

ssize_t clocksource_read_cycle(struct kobj_t * kobj, void * buf, size_t size)
{
	struct clocksource_t * cs = (struct clocksource_t *)kobj->priv;
	return sprintf(buf, "%llu", clocksource_cycle(cs));
}

ssize_t clocksource_read_time(struct kobj_t * kobj, void * buf, size_t size)
{
	struct clocksource_t * cs = (struct clocksource_t *)kobj->priv;
	u64_t cycle = clocksource_cycle(cs);
	u64_t time = clocksource_delta2ns(cs, cycle);
	return sprintf(buf, "%llu.%09llu", time / 1000000000ULL, time % 1000000000ULL);
}

static int clocksource_keeper_timer_function(struct timer_t * timer, void * data)
{
	struct clocksource_t * cs = (struct clocksource_t *)(data);
	u64_t now, delta, offset;
	irq_flags_t flags;

	write_seqlock_irqsave(&cs->keeper.lock, flags);
	now = clocksource_cycle(cs);
	delta = clocksource_delta(cs, cs->keeper.last, now);
	offset = clocksource_delta2ns(cs, delta);
	cs->keeper.nsec += offset;
	cs->keeper.last = now;
	write_sequnlock_irqrestore(&cs->keeper.lock, flags);

	timer_forward_now(timer, ns_to_ktime(cs->keeper.interval));
	return 1;
}

void register_clocksource_driver(struct clocksource_t * cs)
{
	irq_flags_t flags;

	if(!cs || !cs->name || !cs->read)
		return;

	cs->keeper.interval = clocksource_deferment(cs) >> 1;
	cs->keeper.last = clocksource_cycle(cs);
	cs->keeper.nsec = 0;
	seqlock_init(&cs->keeper.lock);
	timer_init(&cs->keeper.timer, clocksource_keeper_timer_function, cs);

	if(__clocksource == &__cs_dummy)
	{
		spin_lock_irqsave(&__clocksource_lock, flags);
		__clocksource = cs;
		spin_unlock_irqrestore(&__clocksource_lock, flags);
	}
	timer_start_now(&cs->keeper.timer, ns_to_ktime(cs->keeper.interval));

	return;
}

void unregister_clocksource_driver(struct clocksource_t * cs)
{
	if(!cs || !cs->name || !cs->read)
		return;

	timer_cancel(&cs->keeper.timer);
	return;
}

ktime_t clocksource_ktime_get(struct clocksource_t * cs)
{
	if(cs)
		return clocksource_keeper_read(cs);
	return ns_to_ktime(0);
}

ktime_t ktime_get(void)
{
	return clocksource_keeper_read(__clocksource);
}
