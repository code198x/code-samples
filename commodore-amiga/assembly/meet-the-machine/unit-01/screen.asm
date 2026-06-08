;──────────────────────────────────────────────────────────────
; Meet the Machine (Amiga) - Unit 1: Assemble and Run
;
; Everything outside the YOUR CODE block is the harness: the ceremony the Amiga
; needs before it will show a single colour. You take the machine away from the
; operating system, hand the Copper a tiny list of instructions, and switch the
; display on. You type it once and treat it as a black box; later units open
; each part up. For now, the one line that matters is the colour.
;──────────────────────────────────────────────────────────────

CUSTOM      equ $dff000         ; base address of the custom chips

DMACON      equ $096            ; DMA control
INTENA      equ $09a            ; interrupt enable
INTREQ      equ $09c            ; interrupt request
COP1LC      equ $080            ; Copper list address
COPJMP1     equ $088            ; Copper restart strobe
BPLCON0     equ $100            ; bitplane control
COLOR00     equ $180            ; background colour register

            section code,code_c   ; code_c = Chip RAM (the Copper reads from here)

start:
            lea     CUSTOM,a5           ; a5 = $DFF000, the custom-chip base

            ; --- take the machine away from the OS ---
            move.w  #$7fff,INTENA(a5)   ; disable all interrupts
            move.w  #$7fff,INTREQ(a5)   ; clear any pending ones
            move.w  #$7fff,DMACON(a5)   ; disable all DMA

            ; --- hand the Copper our list, then switch the display on ---
            lea     copperlist,a0
            move.l  a0,COP1LC(a5)       ; tell Agnus where the list is
            move.w  d0,COPJMP1(a5)      ; strobe: start the Copper
            move.w  #$8280,DMACON(a5)   ; DMA on: master + Copper

forever:
            bra.s   forever             ; hold the picture (nothing to do)

;──────────────────────────────────────────────────────────────
; The Copper list: a tiny program the display co-processor runs.
; It sets up a screen with no bitplanes, so the whole display is
; just the background colour.
;──────────────────────────────────────────────────────────────
copperlist:
            dc.w    BPLCON0,$0200       ; 0 bitplanes - show only the background

            ; ----------------------------------------------- YOUR CODE START
            dc.w    COLOR00,$0f00       ; background colour = red ($0RGB)
            ; ------------------------------------------------- YOUR CODE END

            dc.w    $ffff,$fffe         ; end of the Copper list
