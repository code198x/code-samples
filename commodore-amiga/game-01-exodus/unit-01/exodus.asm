;──────────────────────────────────────────────────────────────
; EXODUS - A terrain puzzle for the Commodore Amiga
; Unit 1: Copper Landscape
;
; A Copper list paints a landscape on screen: sky gradient,
; grass, terrain layers, underground. No CPU rendering —
; the custom chipset does it all.
;──────────────────────────────────────────────────────────────

;══════════════════════════════════════════════════════════════
; TWEAKABLE VALUES — Change these and see what happens!
;══════════════════════════════════════════════════════════════

; Colours are $0RGB (4 bits per component, values 0-F)
COLOUR_SKY_DEEP     equ $0016       ; Deep navy at the top
COLOUR_SKY_UPPER    equ $0038       ; Dark blue
COLOUR_SKY_MID      equ $005B       ; Medium blue
COLOUR_SKY_LOWER    equ $007D       ; Light blue
COLOUR_SKY_HORIZON  equ $009E       ; Pale horizon

COLOUR_GRASS        equ $0080       ; Green surface

COLOUR_EARTH_TOP    equ $0850       ; Light brown earth
COLOUR_EARTH_MID    equ $0630       ; Medium brown
COLOUR_EARTH_DEEP   equ $0420       ; Dark brown

COLOUR_ROCK         equ $0310       ; Deep rock
COLOUR_ROCK_DEEP    equ $0200       ; Near-black

COLOUR_VOID         equ $0000       ; The void

;══════════════════════════════════════════════════════════════
; HARDWARE REGISTERS
;══════════════════════════════════════════════════════════════

CUSTOM      equ $dff000

; Custom chip register offsets
DMACON      equ $096        ; DMA control (write)
INTENA      equ $09a        ; Interrupt enable (write)
INTREQ      equ $09c        ; Interrupt request (write)
COP1LC      equ $080        ; Copper list pointer
COPJMP1     equ $088        ; Copper restart strobe
BPLCON0     equ $100        ; Bitplane control
COLOR00     equ $180        ; Background colour
VPOSR       equ $004        ; Beam position

;══════════════════════════════════════════════════════════════
; CODE (must be in Chip RAM — the Copper reads from here)
;══════════════════════════════════════════════════════════════

            section code,code_c

start:
            lea     CUSTOM,a5           ; A5 = custom chip base ($DFF000)

            ; --- Take over the machine ---
            move.w  #$7fff,INTENA(a5)   ; Disable all interrupts
            move.w  #$7fff,INTREQ(a5)   ; Clear pending interrupts
            move.w  #$7fff,DMACON(a5)   ; Disable all DMA

            ; --- Install Copper list ---
            lea     copperlist,a0       ; A0 = address of our Copper list
            move.l  a0,COP1LC(a5)       ; Tell Agnus where the list is
            move.w  d0,COPJMP1(a5)      ; Strobe: restart Copper from COP1LC

            ; --- Enable DMA ---
            move.w  #$8280,DMACON(a5)   ; SET + DMAEN + COPEN
                                        ;  bit 15 = SET (turn bits ON)
                                        ;  bit  9 = DMAEN (master enable)
                                        ;  bit  7 = COPEN (Copper DMA)

            ; === Main Loop ===
mainloop:
            ; Wait for vertical blank (beam reaches line 0)
            move.l  #$1ff00,d1          ; Mask: bits 8-16 of beam position
.vbwait:
            move.l  VPOSR(a5),d0        ; Read beam position
            and.l   d1,d0               ; Isolate line number
            bne.s   .vbwait             ; Loop until line 0

            ; Check left mouse button (active low at CIAA)
            btst    #6,$bfe001          ; CIAA Port A, bit 6
            bne.s   mainloop            ; Not pressed — keep going

            ; Button pressed — halt
.halt:
            bra.s   .halt

;══════════════════════════════════════════════════════════════
; COPPER LIST — Landscape
;
; The Copper is a coprocessor inside Agnus. It executes its
; own instruction stream in sync with the video beam.
; Two instructions:
;   WAIT  — pause until the beam reaches a position
;   MOVE  — write a value to a custom chip register
;
; Format:
;   WAIT: dc.w $VVHH,$FFFE   (VV=line, HH=position)
;   MOVE: dc.w register,value
;══════════════════════════════════════════════════════════════

copperlist:
            ; --- Display setup ---
            dc.w    BPLCON0,$0200       ; 0 bitplanes, colour burst on

            ; --- SKY GRADIENT (5 bands, deep to pale) ---
            dc.w    COLOR00,COLOUR_SKY_DEEP     ; Deep navy from top of frame

            dc.w    $3401,$fffe                 ; Wait for line $34
            dc.w    COLOR00,COLOUR_SKY_UPPER    ; Dark blue

            dc.w    $4401,$fffe                 ; Wait for line $44
            dc.w    COLOR00,COLOUR_SKY_MID      ; Medium blue

            dc.w    $5401,$fffe                 ; Wait for line $54
            dc.w    COLOR00,COLOUR_SKY_LOWER    ; Light blue

            dc.w    $6001,$fffe                 ; Wait for line $60
            dc.w    COLOR00,COLOUR_SKY_HORIZON  ; Pale horizon

            ; --- GROUND SURFACE ---
            dc.w    $6801,$fffe                 ; Wait for line $68
            dc.w    COLOR00,COLOUR_GRASS        ; Green grass

            ; --- TERRAIN CROSS-SECTION ---
            dc.w    $7401,$fffe                 ; Wait for line $74
            dc.w    COLOR00,COLOUR_EARTH_TOP    ; Light brown

            dc.w    $8c01,$fffe                 ; Wait for line $8C
            dc.w    COLOR00,COLOUR_EARTH_MID    ; Medium brown

            dc.w    $a401,$fffe                 ; Wait for line $A4
            dc.w    COLOR00,COLOUR_EARTH_DEEP   ; Dark brown

            ; --- UNDERGROUND ---
            dc.w    $bc01,$fffe                 ; Wait for line $BC
            dc.w    COLOR00,COLOUR_ROCK         ; Rock

            dc.w    $d401,$fffe                 ; Wait for line $D4
            dc.w    COLOR00,COLOUR_ROCK_DEEP    ; Deep rock

            dc.w    $e801,$fffe                 ; Wait for line $E8
            dc.w    COLOR00,COLOUR_VOID         ; Black void

            ; --- END OF COPPER LIST ---
            dc.w    $ffff,$fffe                 ; Wait for impossible position
