# Lesson 011: Sprite DMA

Efficient sprite updates using DMA (Direct Memory Access).

## Files

- `oam-dma.asm` - Complete sprite update system with DMA

## Concepts

- **OAM DMA**: Hardware copies 256 bytes from RAM to OAM in 513 cycles
- **$4014 register**: Write high byte of source address to trigger DMA
- **VBlank timing**: DMA must occur during VBlank for clean updates
- **Update pattern**: Main loop modifies OAM buffer, NMI triggers DMA

## DMA Performance

Manual copy (loop): ~2560 cycles
OAM DMA: 513 cycles
**Speedup: 5× faster**

## VBlank Budget

Total available: ~2273 cycles
- OAM DMA: 513 cycles (22.5%)
- Remaining: 1760 cycles for other updates

## Usage Pattern

```asm
; Main loop: Update OAM buffer
JSR UpdateOAM

; NMI handler: Trigger DMA
LDA #$02
STA $4014
```
