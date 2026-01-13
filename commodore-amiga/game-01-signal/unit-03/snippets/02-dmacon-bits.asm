; DMACON - DMA Control Register
; Controls which DMA channels are active
;
; $83a0 = %1000 0011 1010 0000
;         │    │  │ │  │
;         │    │  │ │  └─ Bit 5:  SPREN (sprite DMA)
;         │    │  │ └──── Bit 7:  COPEN (Copper DMA)
;         │    │  └────── Bit 8:  BPLEN (bitplane DMA)
;         │    └───────── Bit 9:  DMAEN (master enable)
;         └────────────── Bit 15: SET/CLR (1=enable, 0=disable)

; Disable everything (bit 15 = 0 means "clear these bits")
            move.w  #$7fff,DMACON(a5)   ; Clear bits 0-14

; Enable what we need (bit 15 = 1 means "set these bits")
            move.w  #$83a0,DMACON(a5)   ; Master + Copper + Sprites + Bitplanes

; IMPORTANT: Sprites need BPLEN enabled even with no bitplanes!
; This is a hardware quirk - without it, sprites don't render.
