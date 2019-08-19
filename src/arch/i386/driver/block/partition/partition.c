
#include <xboot.h>
#include <block/partition.h>

static struct list_head __partition_map_list = {
	.next = &__partition_map_list,
	.prev = &__partition_map_list,
};
static spinlock_t __partition_map_lock = SPIN_LOCK_INIT();

static struct kobj_t * search_class_partition_kobj(void)
{
	struct kobj_t * kclass = kobj_search_directory_with_create(kobj_get_root(), "class");
	return kobj_search_directory_with_create(kclass, "partition");
}

static struct partition_map_t * search_partition_map(const char * name)
{
	struct partition_map_t * pos, * n;

	if(!name)
		return NULL;

	list_for_each_entry_safe(pos, n, &__partition_map_list, list)
	{
		if(strcmp(pos->name, name) == 0)
			return pos;
	}
	return NULL;
}

bool_t register_partition_map(struct partition_map_t * map)
{
	irq_flags_t flags;

	if(!map || !map->name || !map->map)
		return FALSE;

	if(search_partition_map(map->name))
		return FALSE;

	map->kobj = kobj_alloc_directory(map->name);
	kobj_add(search_class_partition_kobj(), map->kobj);

	spin_lock_irqsave(&__partition_map_lock, flags);
	init_list_head(&map->list);
	list_add_tail(&map->list, &__partition_map_list);
	spin_unlock_irqrestore(&__partition_map_lock, flags);

	return TRUE;
}

bool_t unregister_partition_map(struct partition_map_t * map)
{
	irq_flags_t flags;

	if(!map || !map->name)
		return FALSE;

	spin_lock_irqsave(&__partition_map_lock, flags);
	list_del(&map->list);
	spin_unlock_irqrestore(&__partition_map_lock, flags);
	kobj_remove(search_class_partition_kobj(), map->kobj);
	kobj_remove_self(map->kobj);

	return TRUE;
}

bool_t partition_map(struct disk_t * disk)
{
	struct partition_map_t * pos, * n;
	struct partition_t * ppos, * pn;
	int i = 0;

	if(!disk || !disk->name)
		return FALSE;

	if(!disk->size || !disk->count)
		return FALSE;

	init_list_head(&(disk->part.entry));

	list_for_each_entry_safe(pos, n, &__partition_map_list, list)
	{
		if(pos->map(disk))
			break;
	}

	list_for_each_entry_safe(ppos, pn, &(disk->part.entry), entry)
	{
		if(!ppos->name || (strlen(ppos->name) == 0))
			snprintf(ppos->name, sizeof(ppos->name), "p%d", i++);
	}
	return TRUE;
}