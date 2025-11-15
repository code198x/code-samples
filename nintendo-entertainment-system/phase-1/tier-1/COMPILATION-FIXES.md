# NES Lesson Compilation Fixes

## Summary
Fixed all 36 NES lesson compilation errors. Status changed from 7/36 compiled to 36/36 compiled.

## Issues Fixed

### 1. Missing Linker Configuration (nes.cfg)
**Problem:** No linker configuration file existed, causing "Missing memory area assignment for segment 'RODATA'" errors.

**Solution:** Created `/nes.cfg` with proper memory layout:
- HEADER segment for iNES header
- ZEROPAGE, RAM, BSS segments for runtime memory
- PRG segment for program code (32KB total for mapper 0)
- **RODATA segment** mapped to PRG ROM (critical for data tables)
- CHR segment for graphics data (8KB)
- VECTORS segment at $FFFA-$FFFF

**Affected Lessons:** 026-030 (number-to-tiles, score-display, game-states, two-player, sound-effects)

### 2. CHR-ROM Overflow
**Problem:** Segment 'CHARS' overflowed memory by 32 bytes (8224 bytes used, 8192 limit).

**Pattern Found:**
```asm
.res 256*16, $00    ; 4096 bytes (tiles 0-255)
; 64 bytes of explicit tile data
.res 254*16, $00    ; 4064 bytes
; Total: 8224 bytes (32 over limit)
```

**Solution:** Changed final `.res 254*16` to `.res 252*16` (removes 32 bytes).

**Affected Lessons:** 011-025 (15 lessons from oam-dma through score-variables)

### 3. Byte Range Errors
**Problem:** `.byte 256` exceeds valid byte range [0..255].

**Location:** Sine table data in visual effects code.

**Solution:** Changed `256` to `255` (correct max value).

**Affected Lessons:** 
- lesson-031/visual-polish.asm (line 854)
- lesson-032/pong-complete.asm (line 966)

## Files Modified

### Created
- `nes.cfg` - Linker configuration file

### Modified (17 files)
- lesson-011/oam-dma.asm
- lesson-012/moving-paddle.asm
- lesson-013/controller-read.asm
- lesson-014/button-detection.asm
- lesson-015/paddle-control.asm
- lesson-016/complete-control.asm
- lesson-017/ball-entity.asm
- lesson-018/ball-movement.asm
- lesson-019/ball-boundaries.asm
- lesson-020/physics-angles.asm
- lesson-021/paddle-collision.asm
- lesson-022/angle-control.asm
- lesson-023/momentum-transfer.asm
- lesson-024/collision-cooldown.asm
- lesson-025/score-variables.asm
- lesson-031/visual-polish.asm
- lesson-032/pong-complete.asm

## Verification

All 36 ASM files (from 32 lesson directories) now compile successfully:
```bash
ca65 lesson-NNN/file.asm -o test.o
ld65 test.o -C nes.cfg -o test.nes
```

**Final test results: 36/36 files compile successfully (100%)**

Sample ROM validation (lesson-001/hello-nes.asm):
- Generated ROM file: 41KB (correct for 2×16KB PRG + 1×8KB CHR)
- iNES header: `4E 45 53 1A 02 01 01 00` (correct magic and configuration)

## Technical Details

### CHR-ROM Size Calculation
- NES CHR-ROM bank = 8192 bytes (8KB)
- Each tile = 16 bytes (8 bytes pattern + 8 bytes pattern)
- 8192 ÷ 16 = 512 tiles maximum per bank
- Lessons use tiles 0-1 for paddle/ball, rest filled with zeros

### Memory Layout (Mapper 0/NROM)
- PRG-ROM: $8000-$FFFF (32KB total)
  - $8000-$BFFF: Code/data bank 0
  - $C000-$FFF9: Code/data bank 1
  - $FFFA-$FFFF: Interrupt vectors
- CHR-ROM: 8KB pattern tables (no address space, accessed via PPU)

### RODATA Segment
The RODATA segment is essential for read-only data tables (sine tables, lookup tables, palette data, etc.). Without it in the linker config, ca65 can't determine where to place `.rodata` segment declarations.

## Date
2025-10-27
