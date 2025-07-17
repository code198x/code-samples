; turbo-horizon-01.s
; Lesson 1: Creating Your First Game World
; Create animated starfield for Turbo Horizon

        SECTION code,CODE

;----------------------------------------------------------------
; Constants
;----------------------------------------------------------------
DMACONR         EQU     $002
ADKCONR         EQU     $010
INTENAR         EQU     $01C
INTREQR         EQU     $01E
DMACON          EQU     $096
ADKCON          EQU     $09E
INTENA          EQU     $09A
INTREQ          EQU     $09C
BPLCON0         EQU     $100
BPLCON1         EQU     $102
BPL1PTH         EQU     $0E0
BPL1PTL         EQU     $0E2
DIWSTRT         EQU     $08E
DIWSTOP         EQU     $090
DDFSTRT         EQU     $092
DDFSTOP         EQU     $094
COP1LCH         EQU     $080
COP1LCL         EQU     $082
COPJMP1         EQU     $088
COLOR00         EQU     $180

CUSTOM          EQU     $DFF000

; Screen dimensions
SCREEN_WIDTH    EQU     320
SCREEN_HEIGHT   EQU     256
SCREEN_BPL      EQU     1       ; 1 bitplane for now
SCREEN_BROW     EQU     SCREEN_WIDTH/8

;----------------------------------------------------------------
; Entry point
;----------------------------------------------------------------
start:
        ; Save system state
        move.l  4.w,a6                  ; ExecBase
        jsr     -132(a6)                ; Forbid()
        
        lea     CUSTOM,a5               ; Custom chip base
        
        ; Save DMA/interrupt state
        move.w  DMACONR(a5),d0
        or.w    #$8000,d0
        move.w  d0,oldDMA
        move.w  INTENAR(a5),d0
        or.w    #$8000,d0
        move.w  d0,oldInt
        
        ; Disable interrupts and DMA
        move.w  #$7FFF,INTENA(a5)
        move.w  #$7FFF,INTREQ(a5)
        move.w  #$7FFF,DMACON(a5)
        
        ; Set up display
        move.w  #$1200,BPLCON0(a5)      ; 1 bitplane, color enabled
        move.w  #$0000,BPLCON1(a5)      ; No scroll
        move.w  #$0024,DDFSTRT(a5)      ; Display data fetch start
        move.w  #$00D0,DDFSTOP(a5)      ; Display data fetch stop
        move.w  #$2C81,DIWSTRT(a5)      ; Display window start
        move.w  #$2CC1,DIWSTOP(a5)      ; Display window stop
        
        ; Clear screen
        bsr     clearScreen
        
        ; Create starfield
        bsr     createStarfield
        
        ; Set up copper list
        lea     copperList,a0
        move.l  a0,COP1LCH(a5)
        
        ; Set up bitplane pointer in copper list
        lea     screen,a0
        move.l  a0,d0
        move.w  d0,bp1l
        swap    d0
        move.w  d0,bp1h
        
        ; Enable DMA
        move.w  #$8380,DMACON(a5)       ; COPPER, BITPLANE, MASTER
        
        ; Main loop
mainLoop:
        ; Wait for vertical blank
        bsr     waitVBlank
        
        ; Update animation
        bsr     animateStars
        
        ; Check for mouse button (exit)
        btst    #6,$BFE001              ; Left mouse button
        bne.s   mainLoop
        
        ; Restore system
        move.w  #$7FFF,DMACON(a5)
        move.w  oldDMA,DMACON(a5)
        move.w  #$7FFF,INTENA(a5)
        move.w  oldInt,INTENA(a5)
        
        move.l  4.w,a6
        jsr     -138(a6)                ; Permit()
        
        moveq   #0,d0
        rts

;----------------------------------------------------------------
; Clear screen
;----------------------------------------------------------------
clearScreen:
        lea     screen,a0
        move.w  #(SCREEN_HEIGHT*SCREEN_BROW/4)-1,d0
.loop:
        move.l  #0,(a0)+
        dbf     d0,.loop
        rts

;----------------------------------------------------------------
; Create starfield
;----------------------------------------------------------------
createStarfield:
        lea     screen,a0
        
        ; Star 1 - row 20, column 5 (byte)
        move.l  a0,a1
        add.w   #20*SCREEN_BROW+5,a1
        bset    #7,(a1)                 ; Leftmost pixel
        
        ; Star 2 - row 40, column 15
        move.l  a0,a1
        add.w   #40*SCREEN_BROW+15,a1
        bset    #5,(a1)
        
        ; Star 3 - row 60, column 8
        move.l  a0,a1
        add.w   #60*SCREEN_BROW+8,a1
        bset    #3,(a1)
        
        ; Star 4 - row 80, column 25
        move.l  a0,a1
        add.w   #80*SCREEN_BROW+25,a1
        bset    #6,(a1)
        
        ; Star 5 - row 100, column 12
        move.l  a0,a1
        add.w   #100*SCREEN_BROW+12,a1
        bset    #2,(a1)
        
        ; Star 6 - row 120, column 30
        move.l  a0,a1
        add.w   #120*SCREEN_BROW+30,a1
        bset    #4,(a1)
        
        ; Star 7 - row 140, column 3
        move.l  a0,a1
        add.w   #140*SCREEN_BROW+3,a1
        bset    #1,(a1)
        
        ; Star 8 - row 160, column 20
        move.l  a0,a1
        add.w   #160*SCREEN_BROW+20,a1
        bset    #7,(a1)
        
        ; Star 9 - row 180, column 18
        move.l  a0,a1
        add.w   #180*SCREEN_BROW+18,a1
        bset    #0,(a1)
        
        ; Star 10 - row 200, column 10
        move.l  a0,a1
        add.w   #200*SCREEN_BROW+10,a1
        bset    #5,(a1)
        
        rts

;----------------------------------------------------------------
; Wait for vertical blank
;----------------------------------------------------------------
waitVBlank:
.wait1:
        move.l  $DFF004,d0
        and.l   #$1FF00,d0
        cmp.l   #$13700,d0              ; Line 311
        bne.s   .wait1
.wait2:
        move.l  $DFF004,d0
        and.l   #$1FF00,d0
        cmp.l   #$13700,d0
        beq.s   .wait2
        rts

;----------------------------------------------------------------
; Animate stars
;----------------------------------------------------------------
animateStars:
        ; Increment frame counter
        addq.b  #1,frameCounter
        move.b  frameCounter,d0
        and.b   #$0F,d0                 ; Every 16 frames
        bne.s   .done
        
        ; Cycle color index
        addq.b  #1,colorIndex
        move.b  colorIndex,d0
        and.b   #$03,d0                 ; Keep in range 0-3
        move.b  d0,colorIndex
        
        ; Update color in copper list
        lea     starColors,a0
        moveq   #0,d0
        move.b  colorIndex,d0
        add.w   d0,d0                   ; Word offset
        move.w  (a0,d0.w),col1
        
.done:
        rts

;----------------------------------------------------------------
; Data
;----------------------------------------------------------------
        SECTION data,DATA

oldDMA:         dc.w    0
oldInt:         dc.w    0
frameCounter:   dc.b    0
colorIndex:     dc.b    0
                even

starColors:
        dc.w    $0FFF   ; White
        dc.w    $0AAA   ; Light gray
        dc.w    $088F   ; Light blue
        dc.w    $0F8F   ; Light purple

;----------------------------------------------------------------
; Copper list
;----------------------------------------------------------------
        SECTION copper,DATA_C

copperList:
        dc.w    COLOR00,$0000   ; Background black
col1:   dc.w    COLOR00+2,$0FFF ; Color 1 white (stars)
        
        dc.w    BPL1PTH
bp1h:   dc.w    0
        dc.w    BPL1PTL
bp1l:   dc.w    0
        
        dc.w    $FFFF,$FFFE     ; End of copper list

;----------------------------------------------------------------
; Screen buffer
;----------------------------------------------------------------
        SECTION screen_mem,BSS_C

screen: ds.b    SCREEN_HEIGHT*SCREEN_BROW

        END