/*
 * driver/clockevent/clockevent.c
 *
 * Copyright(c) 2007-2017 Jianjun Jiang <8192542@qq.com>
 * Official site: http://xboot.org
 * Mobile phone: +86-18665388956
 * QQ: 8192542
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */

#include <clockevent/clockevent.h>

/*
 * Dummy clockevent, 1us - 1MHZ
 */
static void __ce_dummy_handler(struct clockevent_t * ce, void * data)
{
}

static bool_t __ce_dummy_next(struct clockevent_t * ce, u64_t evt)
{
	return TRUE;
}

static struct clockevent_t __ce_dummy = {
	.name = "ce-dummy",
	.mult = 4294967,
	.shift = 32,
	.min_delta_ns = 1000,
	.max_delta_ns = 4294967591000,
	.data = NULL,
	.handler = __ce_dummy_handler,
	.next = __ce_dummy_next,
};
static struct clockevent_t * __clockevent = &__ce_dummy;
static spinlock_t __clockevent_lock = SPIN_LOCK_INIT();

ssize_t clockevent_read_mult(struct kobj_t * kobj, void * buf, size_t size)
{
	struct clockevent_t * ce = (struct clockevent_t *)kobj->priv;
	return sprintf(buf, "%u", ce->mult);
}

ssize_t clockevent_read_shift(struct kobj_t * kobj, void * buf, size_t size)
{
	struct clockevent_t * ce = (struct clockevent_t *)kobj->priv;
	return sprintf(buf, "%u", ce->shift);
}

ssize_t clockevent_read_frequency(struct kobj_t * kobj, void * buf, size_t size)
{
	struct clockevent_t * ce = (struct clockevent_t *)kobj->priv;
	u64_t freq = ((u64_t)1000000000ULL * ce->mult) >> ce->shift;
	return sprintf(buf, "%llu", freq);
}

ssize_t clockevent_read_min_delta(struct kobj_t * kobj, void * buf, size_t size)
{
	struct clockevent_t * ce = (struct clockevent_t *)kobj->priv;
	return sprintf(buf, "%llu.%09llu", ce->min_delta_ns / 1000000000ULL, ce->min_delta_ns % 1000000000ULL);
}

ssize_t clockevent_read_max_delta(struct kobj_t * kobj, void * buf, size_t size)
{
	struct clockevent_t * ce = (struct clockevent_t *)kobj->priv;
	return sprintf(buf, "%llu.%09llu", ce->max_delta_ns / 1000000000ULL, ce->max_delta_ns % 1000000000ULL);
}

void register_clockevent_driver(struct clockevent_t * ce)
{
	irq_flags_t flags;

	if(!ce || !ce->name || !ce->next)
		return;

	ce->data = NULL;
	ce->handler = __ce_dummy_handler;

	if(__clockevent == &__ce_dummy)
	{
		spin_lock_irqsave(&__clockevent_lock, flags);
		__clockevent = ce;
		timer_bind_clockevent(__clockevent);
		spin_unlock_irqrestore(&__clockevent_lock, flags);
	}
	return;
}

void unregister_clockevent_driver(struct clockevent_t * ce)
{
	if(!ce || !ce->name || !ce->next)
		return;

	return;
}

bool_t clockevent_set_event_handler(struct clockevent_t * ce, void (*handler)(struct clockevent_t *, void *), void * data)
{
	if(!ce)
		return FALSE;
	ce->data = data;
	ce->handler = handler ? handler : __ce_dummy_handler;
	return TRUE;
}

bool_t clockevent_set_event_next(struct clockevent_t * ce, ktime_t now, ktime_t expires)
{
	u64_t delta;

	if(!ce)
		return FALSE;

	if(ktime_before(expires, now))
		return FALSE;

	delta = ktime_to_ns(ktime_sub(expires, now));
	if(delta > ce->max_delta_ns)
		delta = ce->max_delta_ns;
	if(delta < ce->min_delta_ns)
		delta = ce->min_delta_ns;
	return ce->next(ce, ((u64_t)delta * ce->mult) >> ce->shift);
}
