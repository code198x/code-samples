; Caller owns the blitter and enables master+blitter DMA before entry.
; A1 points into a word-aligned Chip RAM bitplane with 40-byte rows.
; D0=major delta 0..1023, D1=minor delta 0..D0, D2=octant bits4..2 only,
; D3=start X modulo16. The whole line must fit allocated plane memory.
; Changes A5/D2/D4-D7/CCR; starts an asynchronous blit. Wait before reusing
; blitter registers, reading the result, or freeing source/destination memory.
; =============================================================================
; BLITTER LINE DRAW - AMIGA (blitter line mode)
; Draw a Bresenham line into one bitplane.
; Inputs, already reduced to an octant so dx (major) >= dy (minor):
;   d0 = dx    d1 = dy
;   d2 = octant, as SUD/SUL/AUL already in BLTCON1 bits 4-2
;   a1 = address of the bitplane word holding (x0,y0)
;   d3 = x0 AND 15   (start column inside that word)
; =============================================================================

DMACONR  equ $002
BLTCON0  equ $040
BLTCON1  equ $042
BLTAFWM  equ $044
BLTALWM  equ $046
BLTCPT   equ $048
BLTAPTL  equ $052            ; A pointer, low word = the accumulator in line mode
BLTDPT   equ $054
BLTSIZE  equ $058
BLTCMOD  equ $060
BLTBMOD  equ $062
BLTAMOD  equ $064
BLTDMOD  equ $066
BLTBDAT  equ $072
BLTADAT  equ $074

SCR_BYTES equ 40             ; bitplane row = 320 px = 40 bytes

line_draw:
            lea     $dff000,a5
            bsr     wait_blit

            ; --- Bresenham accumulator seed and the two step modulos ---
            move.w  d1,d4
            add.w   d4,d4
            add.w   d4,d4                    ; d4 = 4*dy
            move.w  d4,BLTBMOD(a5)           ; the step taken on every pixel
            move.w  d4,d5
            sub.w   d0,d5
            sub.w   d0,d5                    ; d5 = 4*dy - 2*dx  (the seed)
            move.w  d5,BLTAPTL(a5)
            sub.w   d0,d4
            sub.w   d0,d4
            sub.w   d0,d4
            sub.w   d0,d4                    ; d4 = 4*dy - 4*dx = 4*(dy-dx)
            move.w  d4,BLTAMOD(a5)           ; the extra step when error turns over

            move.w  #$8000,BLTADAT(a5)       ; the single accumulator bit
            move.w  #$ffff,BLTBDAT(a5)       ; texture = a solid line
            move.w  #$ffff,BLTAFWM(a5)       ; line mode: both masks MUST be $FFFF
            move.w  #$ffff,BLTALWM(a5)

            ; --- Control words: start column, channels, minterm, octant, LINE ---
            move.w  d3,d6
            ror.w   #4,d6                    ; x0&15 -> START (bits 12-15)
            or.w    #$0bca,d6                ; USEA+USEC+USED (fixed) + minterm $CA
            move.w  d6,BLTCON0(a5)

            or.w    #$0001,d2                ; LINE = 1
            tst.w   d5
            bpl.s   .nosign
            or.w    #$0040,d2                ; seed negative -> set SIGN (bit 6)
.nosign:    move.w  d2,BLTCON1(a5)

            move.l  a1,BLTCPT(a5)            ; read the bitplane...
            move.l  a1,BLTDPT(a5)            ; ...and write it back
            move.w  #SCR_BYTES,BLTCMOD(a5)
            move.w  #SCR_BYTES,BLTDMOD(a5)

            ; --- height = dx+1 pixels, width fixed at 2 words: this STARTS it ---
            move.w  d0,d7
            addq.w  #1,d7
            lsl.w   #6,d7
            addq.w  #2,d7
            move.w  d7,BLTSIZE(a5)
            rts

wait_blit:
            btst    #6,DMACONR(a5)
.wb:        btst    #6,DMACONR(a5)
            bne.s   .wb
            rts
