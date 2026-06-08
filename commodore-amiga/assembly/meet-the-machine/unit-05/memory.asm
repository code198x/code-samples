;──────────────────────────────────────────────────────────────
; Meet the Machine (Amiga) - Unit 5: A Vast Street of Memory
;
; The 68000 can address a vast street of memory. You store a value at an address
; and read it back, exactly as you'd expect. Here a colour goes out to a spare
; word of memory and comes back before it reaches the screen.
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
            move.w  #$00ff,scratch      ; store a cyan at the address 'scratch'
            move.w  scratch,d0          ; read it back from memory into d0
            move.w  d0,colourval        ; show it
            ; ------------------------------------------------- YOUR CODE END

forever:
            bra.s   forever

scratch:    dc.w    $0000               ; a spare word of memory to borrow

copperlist:
            dc.w    BPLCON0,$0200
            dc.w    COLOR00
colourval:
            dc.w    $0000
            dc.w    $ffff,$fffe
