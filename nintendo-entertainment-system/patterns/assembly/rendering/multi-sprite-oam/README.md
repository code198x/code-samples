# Pack game objects into a finished OAM page

Include oam.inc once. The complete runnable caller is ../nametable-scrolling/demo.asm; `make` there builds its cartridge. This routine packs up to 64 active, vertically visible, single-tile objects; it does not turn 64 OAM slots into 64 sprites per scanline.

The caller supplies five 64-byte arrays: obj_x, obj_y, obj_tile, obj_attr, obj_active. X is raw hardware X; Y is raw OAM Y (displayed top=Y+1). Values 0..238 are supported; >=239 is hidden. Attribute reserved bits must be zero; the caller chooses legal tiles/palettes for its cartridge and 8x8 sprite mode. A non-zero active byte includes the object.

Supply object_count (0..64), first_object, oam_used, oam_status, objects_left and object_index bytes, and a page-aligned oam_buffer[256]. RAM must not overlap the object arrays, stack or other state. Clear decimal mode; A/X/Y/flags change. The routine reads arrays unchanged and writes the owned page and scratch state. Call outside NMI while the page is exclusively owned.

`build_oam` hides all 64 Y entries first, then packs eligible objects in circular order from first_object. An out-of-range first_object normalises to zero for a non-empty list. Success gives carry clear/status0 and oam_used=number packed. Count>64 hides all entries, returns carry set/status1 and reads no object arrays. Hidden entries only promise Y=$FF; other bytes retain their previous values.

Call `advance_priority` when you want to rotate the first candidate. It changes A/flags and first_object, wrapping at object_count; empty/invalid counts reset it to zero. Rotating shares which objects lose visibility when the PPU's scanline budget is exceeded. It can flicker, changes overlap priority and moves the identity in OAM slot zero: do not combine it unchanged with a fixed sprite-zero split. A game can reserve player/HUD slots and rotate only expendable objects in a different policy.

DMA and publication are caller jobs. Build everything, publish a ready flag last, let NMI transfer the complete page, and wait for acknowledgement before reuse. See the complete scene for the exact code. No arbitrary clipping, metasprite grouping, 8x16 handling or scanline-aware admission is supplied. Those are onward techniques with additional state and costs.

## Verification

Run `scripts/verify-rendering-families.py --help` from the repository root for the released emulator paths and local firmware options. The retained record names the exact source/observer/tool hashes, independent memory checks, failing controls and complete-caller captures. A passing CPU/memory check does not establish a tear-free display, every timing standard, original hardware or a worst-case frame budget. Firmware is not distributed.
