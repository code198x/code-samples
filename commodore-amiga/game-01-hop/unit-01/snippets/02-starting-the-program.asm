;──────────────────────────────────────────────────────────────
; HOP - A Frogger-style game for the Commodore Amiga
; Unit 1: The Lanes
;──────────────────────────────────────────────────────────────

CUSTOM      equ $dff000

DMACONR     equ $002
DMACON      equ $096
INTENA      equ $09a
INTREQ      equ $09c
COP1LC      equ $080
COPJMP1     equ $088
VPOSR       equ $004
COLOR00     equ $180

;──────────────────────────────────────────────────────────────
            section code,code
;──────────────────────────────────────────────────────────────

start:
            lea     CUSTOM,a5           ; A5 = custom chip base

            ; Disable all interrupts
            move.w  #$7fff,INTENA(a5)   ; Clear all interrupt bits
            move.w  #$7fff,INTREQ(a5)   ; Clear pending interrupts

            ; Disable all DMA
            move.w  #$7fff,DMACON(a5)   ; Turn off all DMA channels
