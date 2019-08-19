
#include <block/partition.h>

struct mbr_entry_t
{
	uint8_t flag;
	uint8_t start_head;
	uint8_t start_sector;
	uint8_t start_cylinder;
	uint8_t type;
	uint8_t end_head;
	uint8_t end_sector;
	uint8_t end_cylinder;
	uint8_t start[4];
	uint8_t length[4];
} __attribute__ ((packed));

struct mbr_header_t
{
	uint8_t code[446];
	struct mbr_entry_t entry[4];
	uint8_t signature[2];
} __attribute__ ((packed));

struct gpt_entry_t {
	uint8_t type_uuid[16];
	uint8_t unique_uuid[16];
	uint8_t first_lba[8];
	uint8_t last_lba[8];
	uint8_t attr[8];
	uint8_t name[72];
} __attribute__ ((packed));

struct gpt_header_t {
	uint8_t signature[8];
	uint8_t revision[4];
	uint8_t size[4];
	uint8_t header_crc[4];
	uint8_t reserved[4];
	uint8_t current_lba[8];
	uint8_t backup_lba[8];
	uint8_t first_lba[8];
	uint8_t last_lba[8];
	uint8_t disk_uuid[16];
	uint8_t part_lba[8];
	uint8_t list_num[4];
	uint8_t part_size[4];
	uint8_t part_crc[4];
} __attribute__ ((packed));

static bool_t gpt_map(struct disk_t * disk)
{
	struct mbr_header_t mbr;
	struct partition_t * part;

	if(!disk || !disk->name)
		return FALSE;

	if(!disk->size || !disk->count)
		return FALSE;

	if(disk_read(disk, (uint8_t *)(&mbr), 0, sizeof(struct mbr_header_t)) != sizeof(struct mbr_header_t))
		return FALSE;

	if((mbr.signature[0] != 0x55) || mbr.signature[1] != 0xaa)
		return FALSE;

	if((mbr.entry[0].type != 0xee) && (mbr.entry[1].type != 0xee) && (mbr.entry[2].type != 0xee) && (mbr.entry[3].type != 0xee))
		return FALSE;

	//TODO
	return FALSE;
}

static struct partition_map_t gpt = {
	.name	= "gpt",
	.map	= gpt_map,
};

static __init void partition_map_gpt_init(void)
{
	register_partition_map(&gpt);
}

static __exit void partition_map_gpt_exit(void)
{
	unregister_partition_map(&gpt);
}

core_initcall(partition_map_gpt_init);
core_exitcall(partition_map_gpt_exit);
