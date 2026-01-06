;──────────────────────────────────────────────────────────────
; HOP - A Frogger-style game for the Commodore Amiga
; Unit 2: The Frog
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
SPR0PTH     equ $120
SPR0PTL     equ $122

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

            ; --- Set sprite pointer in copper list ---
            lea     frog_data,a0        ; A0 = sprite data address
            lea     sprpt+2,a1          ; A1 = SPR0PTH value field
            move.l  a0,d0               ; D0 = address
            swap    d0                  ; High word first
            move.w  d0,(a1)             ; Write to SPR0PTH value
            swap    d0                  ; Low word
            move.w  d0,4(a1)            ; Write to SPR0PTL value

            ; --- Install copper list ---
            lea     copperlist,a0
            move.l  a0,COP1LC(a5)       ; Point copper at our list
            move.w  d0,COPJMP1(a5)      ; Strobe to start copper

            ; --- Enable DMA ---
            move.w  #$8320,DMACON(a5)   ; Master + copper + sprites

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
; Chip RAM Data
;──────────────────────────────────────────────────────────────
            section chipdata,data_c

copperlist:
            dc.w    COLOR00,$0000       ; Black border

            ; --- Sprite 0 palette ---
            dc.w    $01a2,$00f0         ; Colour 17: Green (body)
            dc.w    $01a4,$0ff0         ; Colour 18: Yellow (eyes)
            dc.w    $01a6,$0000         ; Colour 19: Black (outline)

            ; --- Sprite 0 pointer (filled by CPU) ---
sprpt:
            dc.w    $0120,$0000         ; SPR0PTH
            dc.w    $0122,$0000         ; SPR0PTL

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

            ; End of copper list
            dc.w    $ffff,$fffe

;──────────────────────────────────────────────────────────────
; Sprite Data
;──────────────────────────────────────────────────────────────
            even
frog_data:
            ; Control words: Y=180 ($B4), X=192 ($60)
            dc.w    $b460           ; VSTART=$B4, HSTART=$60
            dc.w    $c400           ; VSTOP=$C4, control=0

            ; 16 lines of sprite data (plane0, plane1)
            dc.w    $0000,$0000     ; ................
            dc.w    $07e0,$0000     ; .....XXXXXX.....
            dc.w    $1ff8,$0420     ; ...XXXXXXXXXXX..
            dc.w    $3ffc,$0a50     ; ..XXXXXXXXXXXXX.
            dc.w    $7ffe,$1248     ; .XXXXXXXXXXXXXXX
            dc.w    $7ffe,$1008     ; .XXXXXXXXXXXXXXX
            dc.w    $ffff,$2004     ; XXXXXXXXXXXXXXXX
            dc.w    $ffff,$0000     ; XXXXXXXXXXXXXXXX
            dc.w    $ffff,$0000     ; XXXXXXXXXXXXXXXX
            dc.w    $7ffe,$2004     ; .XXXXXXXXXXXXXXX
            dc.w    $7ffe,$1008     ; .XXXXXXXXXXXXXXX
            dc.w    $3ffc,$0810     ; ..XXXXXXXXXXXXX.
            dc.w    $1ff8,$0420     ; ...XXXXXXXXXXX..
            dc.w    $07e0,$0000     ; .....XXXXXX.....
            dc.w    $0000,$0000     ; ................
            dc.w    $0000,$0000     ; ................

            ; End marker
            dc.w    $0000,$0000
