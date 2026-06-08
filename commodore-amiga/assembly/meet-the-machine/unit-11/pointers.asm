;──────────────────────────────────────────────────────────────
; Meet the Machine (Amiga) - Unit 11: Pointers and the Address Registers
;
; An address register holds an address - and with brackets, (a0) means "the box
; a0 points at". (a0)+ reads it AND steps the pointer to the next box. Here a
; pointer walks along a table of colours, reading as it goes.
;──────────────────────────────────────────────────────────────

CUSTOM      equ $dff000
DMACON      equ $096
INTENA      equ $09a
INTREQ      equ $09c
COP1LC      equ $080
COPJMP1     equ $088
BPLCON0     equ $100
COLOR00     equ $180

            section code,code_c

start:
            lea     CUSTOM,a5
            move.w  #$7fff,INTENA(a5)
            move.w  #$7fff,INTREQ(a5)
            move.w  #$7fff,DMACON(a5)
            lea     copperlist,a0
            move.l  a0,COP1LC(a5)
            move.w  d0,COPJMP1(a5)
            move.w  #$8280,DMACON(a5)

            ; ----------------------------------------------- YOUR CODE START
            lea     colours,a0          ; a0 points at the start of the table
            move.w  (a0)+,d0            ; read colours[0], then step a0 on
            move.w  (a0)+,d0            ; read colours[1], then step on
            move.w  (a0),d0             ; read colours[2] (no step this time)
            move.w  d0,colourval        ; show it
            ; ------------------------------------------------- YOUR CODE END

forever:
            bra.s   forever

colours:    dc.w    $0f80, $00ff, $0a0f, $0ff0   ; a table of colours in memory

copperlist:
            dc.w    BPLCON0,$0200
            dc.w    COLOR00
colourval:
            dc.w    $0000
            dc.w    $ffff,$fffe
