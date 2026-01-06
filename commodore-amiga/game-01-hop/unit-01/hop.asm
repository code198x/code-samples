;──────────────────────────────────────────────────────────────
; HOP - A Frogger-style game for the Commodore Amiga
; Unit 1: The Lanes
;──────────────────────────────────────────────────────────────

CUSTOM      equ $dff000

; Custom chip register offsets
DMACONR     equ $002
DMACON      equ $096
INTENA      equ $09a
INTREQ      equ $09c
COP1LC      equ $080
COPJMP1     equ $088
VPOSR       equ $004
COLOR00     equ $180

;──────────────────────────────────────────────────────────────
; Code Section
;──────────────────────────────────────────────────────────────
            section code,code

start:
            lea     CUSTOM,a5           ; Custom chip base in A5

            ; --- Take over the machine ---
            move.w  #$7fff,INTENA(a5)   ; Disable all interrupts
            move.w  #$7fff,INTREQ(a5)   ; Clear pending interrupts
            move.w  #$7fff,DMACON(a5)   ; Disable all DMA

            ; --- Install copper list ---
            lea     copperlist,a0
            move.l  a0,COP1LC(a5)       ; Point copper at our list
            move.w  d0,COPJMP1(a5)      ; Strobe to start copper

            ; --- Enable DMA ---
            move.w  #$8280,DMACON(a5)   ; Enable master + copper

            ; === Main Loop ===
mainloop:
            ; Wait for vertical blank
            move.l  #$1ff00,d1
.vbwait:
            move.l  VPOSR(a5),d0
            and.l   d1,d0
            bne.s   .vbwait

            ; Check left mouse button
            btst    #6,$bfe001
            bne.s   mainloop

            ; Button pressed - loop forever (game runs until reset)
            bra.s   mainloop

;──────────────────────────────────────────────────────────────
; Chip RAM Data (copper list must be here)
;──────────────────────────────────────────────────────────────
            section chipdata,data_c

copperlist:
            dc.w    COLOR00,$0000       ; Black border

            ; === HOME ZONE ===
            dc.w    $2c07,$fffe
            dc.w    COLOR00,$0080       ; Green

            ; === WATER ZONE (5 lanes) ===
            dc.w    $4007,$fffe
            dc.w    COLOR00,$0048       ; Dark blue - lane 1

            dc.w    $4c07,$fffe
            dc.w    COLOR00,$006b       ; Medium blue - wave

            dc.w    $5407,$fffe
            dc.w    COLOR00,$0048       ; Dark blue - lane 2

            dc.w    $5c07,$fffe
            dc.w    COLOR00,$006b       ; Medium blue - wave

            dc.w    $6407,$fffe
            dc.w    COLOR00,$0048       ; Dark blue - lane 3

            ; === MEDIAN (safe) ===
            dc.w    $6c07,$fffe
            dc.w    COLOR00,$0080       ; Green

            ; === ROAD ZONE (4 lanes) ===
            dc.w    $7807,$fffe
            dc.w    COLOR00,$0444       ; Dark grey - lane 1

            dc.w    $8407,$fffe
            dc.w    COLOR00,$0666       ; Light grey - marker

            dc.w    $8807,$fffe
            dc.w    COLOR00,$0444       ; Dark grey - lane 2

            dc.w    $9407,$fffe
            dc.w    COLOR00,$0666       ; Light grey - marker

            dc.w    $9807,$fffe
            dc.w    COLOR00,$0444       ; Dark grey - lane 3

            dc.w    $a407,$fffe
            dc.w    COLOR00,$0666       ; Light grey - marker

            dc.w    $a807,$fffe
            dc.w    COLOR00,$0444       ; Dark grey - lane 4

            ; === START ZONE ===
            dc.w    $b407,$fffe
            dc.w    COLOR00,$0080       ; Green

            dc.w    $c007,$fffe
            dc.w    COLOR00,$0070       ; Darker green border

            ; === BOTTOM BORDER ===
            dc.w    $f007,$fffe
            dc.w    COLOR00,$0000       ; Black

            ; End of list
            dc.w    $ffff,$fffe
