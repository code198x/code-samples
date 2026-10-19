# A scrolling NES scene with an overloaded sprite row

`make` produces `build/demo.nes`: an original NROM-256/CHR-ROM NTSC scene with vertical mirroring. Two physical nametables form a repeating 512-pixel horizontal world. Twelve objects share one scanline; round-robin OAM ordering shares the hardware dropout. Reset to leave. No controller or firmware is required.

`scroll.inc` needs caller-owned bytes scroll_x, scroll_y, nametable and ppu_ctrl_shadow. Y must be 0..239; nametable is 0..3. `scroll_right` increments horizontal position, toggles only the horizontal nametable bit on 255->0, and changes A/flags. It performs no PPU writes or column streaming. Use a private snapshot while computing it.

`set_scroll` changes A/flags and writes $2000/$2005 after resetting the shared write latch through $2002. Call it during vblank AFTER all $2006/$2007 writes. The shadow byte preserves NMI, pattern-table, sprite-size and increment settings. Cartridge mirroring determines whether neighbouring logical tables have distinct storage; vertical mirroring does for $2000/$2400.

```asm
    jsr scroll_right       ; main, while ready=0
    jsr build_oam          ; complete the staging page
    lda #1
    sta ready              ; publish LAST
    ; NMI: when ready=1, DMA finished OAM, set_scroll, then clear ready.
```

The complete demo includes the reusable OAM builder from ../multi-sprite-oam/oam.inc. Main waits for acknowledgement before touching published state. NMI saves A/X/Y, transfers page $0200 with $2003=0, applies the matching scroll snapshot and acknowledges it. Main may take more than a frame: NMI leaves the previous picture intact until a complete new snapshot exists. This is one owned staging page, not permission for concurrent writes. The demo owns NMI, all OAM, the two nametables, CHR and palettes; no DMC or audio service is installed.

The caller reloads both nametables once with rendering off. It wraps this finite world rather than streaming an endless level. The existing column-feeding article describes the further step, including attribute-quadrant updates; those are not implemented here. Test PAL separately before claiming it.

## Verification

Run `scripts/verify-rendering-families.py --help` from the repository root for the released emulator paths and local firmware options. The retained record names the exact source/observer/tool hashes, independent memory checks, failing controls and complete-caller captures. A passing CPU/memory check does not establish a tear-free display, every timing standard, original hardware or a worst-case frame budget. Firmware is not distributed.
