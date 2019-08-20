
#include <disk.h>
#include <partition.h>

struct disk_block_t
{
	u64_t offset;
	struct disk_t * disk;
};

// static u64_t disk_block_read(struct block_t * blk, u8_t * buf, u64_t blkno, u64_t blkcnt)
// {
// 	struct disk_block_t * dblk = (struct disk_block_t *)(blk->priv);
// 	struct disk_t * disk = dblk->disk;
// 	return (disk->read(disk, buf, blkno + dblk->offset, blkcnt));
// }

// static u64_t disk_block_write(struct block_t * blk, u8_t * buf, u64_t blkno, u64_t blkcnt)
// {
// 	struct disk_block_t * dblk = (struct disk_block_t *)(blk->priv);
// 	struct disk_t * disk = dblk->disk;
// 	return (disk->write(disk, buf, blkno + dblk->offset, blkcnt));
// }

// static void disk_block_sync(struct block_t * blk)
// {
// }

// static ssize_t partition_read_from(struct kobj_t * kobj, void * buf, size_t size)
// {
// 	struct partition_t * part = (struct partition_t *)kobj->priv;
// 	return sprintf(buf, "%lld", part->from);
// }

// static ssize_t partition_read_to(struct kobj_t * kobj, void * buf, size_t size)
// {
// 	struct partition_t * part = (struct partition_t *)kobj->priv;
// 	return sprintf(buf, "%lld", part->to);
// }

// static ssize_t partition_read_size(struct kobj_t * kobj, void * buf, size_t size)
// {
// 	struct partition_t * part = (struct partition_t *)kobj->priv;
// 	return sprintf(buf, "%lld", part->size);
// }

// static ssize_t partition_read_capacity(struct kobj_t * kobj, void * buf, size_t size)
// {
// 	struct partition_t * part = (struct partition_t *)kobj->priv;
// 	return sprintf(buf, "%lld", (part->to - part->from + 1) * part->size);
// }

struct disk_t * search_disk(const char * name)
{
	return NULL;
}

bool_t register_disk(struct disk_t * disk)
{
	return TRUE;
}

bool_t unregister_disk(struct disk_t * disk)
{
	return TRUE;
}

u64_t disk_read(struct disk_t * disk, u8_t * buf, u64_t offset, u64_t count)
{
	u64_t no, sz, cnt, capacity;
	u64_t len, tmp;
	u64_t ret = 0;
	u8_t * p;

	if(!disk || !buf || !count)
		return 0;

	sz = disk->size;
	cnt = disk->count;
	if(!sz || !cnt)
		return 0;

	capacity = sz * count;
	if(offset >= capacity)
		return 0;

	tmp = capacity - offset;
	if(count > tmp)
		count = tmp;

	p = malloc(sz);
	if(!p)
		return 0;

	no = offset / sz;
	tmp = offset % sz;
	if(tmp > 0)
	{
		len = sz - tmp;
		if(count < len)
			len = count;

		if(disk->read(disk, p, no, 1) != 1)
		{
			free(p);
			return ret;
		}

		memcpy((void *)buf, (const void *)(&p[tmp]), len);
		buf += len;
		count -= len;
		ret += len;
		no += 1;
	}

	tmp = count / sz;
	if(tmp > 0)
	{
		len = tmp * sz;

		if(disk->read(disk, buf, no, tmp) != tmp)
		{
			free(p);
			return ret;
		}

		buf += len;
		count -= len;
		ret += len;
		no += tmp;
	}

	if(count > 0)
	{
		len = count;

		if(disk->read(disk, p, no, 1) != 1)
		{
			free(p);
			return ret;
		}

		memcpy((void *)buf, (const void *)(&p[0]), len);
		ret += len;
	}

	free(p);
	return ret;
}

u64_t disk_write(struct disk_t * disk, u8_t * buf, u64_t offset, u64_t count)
{
	u64_t no, sz, cnt, capacity;
	u64_t len, tmp;
	u64_t ret = 0;
	u8_t * p;

	if(!disk || !buf || !count)
		return 0;

	sz = disk->size;
	cnt = disk->count;
	if(!sz || !cnt)
		return 0;

	capacity = sz * count;
	if(offset >= capacity)
		return 0;

	tmp = capacity - offset;
	if(count > tmp)
		count = tmp;

	p = malloc(sz);
	if(!p)
		return 0;

	no = offset / sz;
	tmp = offset % sz;
	if(tmp > 0)
	{
		len = sz - tmp;
		if(count < len)
			len = count;

		if(disk->read(disk, p, no, 1) != 1)
		{
			free(p);
			return ret;
		}

		memcpy((void *)(&p[tmp]), (const void *)buf, len);

		if(disk->write(disk, p, no, 1) != 1)
		{
			free(p);
			return ret;
		}

		buf += len;
		count -= len;
		ret += len;
		no += 1;
	}

	tmp = count / sz;
	if(tmp > 0)
	{
		len = tmp * sz;

		if(disk->write(disk, buf, no, tmp) != tmp)
		{
			free(p);
			return ret;
		}

		buf += len;
		count -= len;
		ret += len;
		no += tmp;
	}

	if(count > 0)
	{
		len = count;

		if(disk->read(disk, p, no, 1) != 1)
		{
			free(p);
			return ret;
		}

		memcpy((void *)(&p[0]), (const void *)buf, len);

		if(disk->write(disk, p, no, 1) != 1)
		{
			free(p);
			return ret;
		}

		ret += len;
	}

	free(p);
	return ret;
}

void disk_sync(struct disk_t * disk)
{
	if(disk && disk->sync)
		disk->sync(disk);
}
