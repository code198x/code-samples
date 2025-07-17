; turbo-horizon-02.s
; Lesson 2: Adding the Player Ship
; Add hardware sprite-based player ship to Turbo Horizon

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

; Sprite registers
SPR0PTH         EQU     $120
SPR0PTL         EQU     $122
SPR0POS         EQU     $140
SPR0CTL         EQU     $142
SPR0DATA        EQU     $144
SPR0DATB        EQU     $146

; Joystick/mouse
JOY0DAT         EQU     $00A
JOY1DAT         EQU     $00C
POTGOR          EQU     $016

CUSTOM          EQU     $DFF000

; Screen dimensions
SCREEN_WIDTH    EQU     320
SCREEN_HEIGHT   EQU     256
SCREEN_BPL      EQU     1       ; 1 bitplane for now
SCREEN_BROW     EQU     SCREEN_WIDTH/8

; Player ship constants
PLAYER_START_X  EQU     160     ; Starting X position (middle)
PLAYER_START_Y  EQU     200     ; Starting Y position (near bottom)
PLAYER_MIN_X    EQU     16      ; Minimum X position
PLAYER_MAX_X    EQU     304     ; Maximum X position
PLAYER_MIN_Y    EQU     32      ; Minimum Y position
PLAYER_MAX_Y    EQU     240     ; Maximum Y position
PLAYER_SPEED    EQU     2       ; Movement speed

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
        
        ; Initialize player sprite
        bsr     initPlayer
        
        ; Set up copper list
        lea     copperList,a0
        move.l  a0,COP1LCH(a5)
        
        ; Set up bitplane pointer in copper list
        lea     screen,a0
        move.l  a0,d0
        move.w  d0,bp1l
        swap    d0
        move.w  d0,bp1h
        
        ; Set up sprite pointer in copper list
        lea     playerSprite,a0
        move.l  a0,d0
        move.w  d0,spr0l
        swap    d0
        move.w  d0,spr0h
        
        ; Enable DMA
        move.w  #$83A0,DMACON(a5)       ; COPPER, BITPLANE, SPRITE, MASTER
        
        ; Main loop
mainLoop:
        ; Wait for vertical blank
        bsr     waitVBlank
        
        ; Handle input
        bsr     handleInput
        
        ; Update animation
        bsr     animateStars
        
        ; Check for exit (left mouse button)
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
; Initialize player sprite
;----------------------------------------------------------------
initPlayer:
        ; Set starting position
        move.w  #PLAYER_START_X,playerX
        move.w  #PLAYER_START_Y,playerY
        
        ; Update sprite position
        bsr     updatePlayerSprite
        
        rts

;----------------------------------------------------------------
; Update player sprite position
;----------------------------------------------------------------
updatePlayerSprite:
        ; Calculate sprite position values
        move.w  playerX,d0
        move.w  playerY,d1
        
        ; Create SPR0POS value (VSTART in upper 8 bits, HSTART in lower 8 bits)
        move.w  d1,d2
        lsl.w   #8,d2                   ; VSTART in upper 8 bits
        move.w  d0,d3
        lsr.w   #1,d3                   ; HSTART/2 in lower 8 bits
        or.w    d3,d2
        move.w  d2,spr0pos
        
        ; Create SPR0CTL value
        move.w  d1,d2
        add.w   #16,d2                  ; VSTOP = VSTART + 16 (sprite height)
        lsl.w   #8,d2                   ; VSTOP in upper 8 bits
        move.w  d0,d3
        and.w   #1,d3                   ; HSTART LSB
        or.w    d3,d2
        move.w  d2,spr0ctl
        
        rts

;----------------------------------------------------------------
; Handle joystick input
;----------------------------------------------------------------
handleInput:
        ; Read joystick 1
        move.w  JOY1DAT(a5),d0
        
        ; Check for up (bit 8 XOR bit 9)
        move.w  d0,d1
        lsr.w   #8,d1
        eor.w   d0,d1
        lsr.w   #1,d1
        and.w   #1,d1
        beq.s   checkDown
        
        ; Move up
        move.w  playerY,d0
        cmp.w   #PLAYER_MIN_Y,d0
        ble.s   checkDown
        sub.w   #PLAYER_SPEED,d0
        move.w  d0,playerY
        
checkDown:
        ; Check for down (bit 8 XOR bit 9, inverted)
        move.w  JOY1DAT(a5),d0
        move.w  d0,d1
        lsr.w   #8,d1
        eor.w   d0,d1
        lsr.w   #1,d1
        and.w   #1,d1
        bne.s   checkLeft
        
        ; Move down
        move.w  playerY,d0
        cmp.w   #PLAYER_MAX_Y,d0
        bge.s   checkLeft
        add.w   #PLAYER_SPEED,d0
        move.w  d0,playerY
        
checkLeft:
        ; Check for left (bit 9 XOR bit 1)
        move.w  JOY1DAT(a5),d0
        move.w  d0,d1
        lsr.w   #8,d1
        eor.w   d0,d1
        and.w   #1,d1
        beq.s   checkRight
        
        ; Move left
        move.w  playerX,d0
        cmp.w   #PLAYER_MIN_X,d0
        ble.s   checkRight
        sub.w   #PLAYER_SPEED,d0
        move.w  d0,playerX
        
checkRight:
        ; Check for right (bit 9 XOR bit 1, inverted)
        move.w  JOY1DAT(a5),d0
        move.w  d0,d1
        lsr.w   #8,d1
        eor.w   d0,d1
        and.w   #1,d1
        bne.s   inputDone
        
        ; Move right
        move.w  playerX,d0
        cmp.w   #PLAYER_MAX_X,d0
        bge.s   inputDone
        add.w   #PLAYER_SPEED,d0
        move.w  d0,playerX
        
inputDone:
        ; Update sprite position
        bsr     updatePlayerSprite
        
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
playerX:        dc.w    PLAYER_START_X
playerY:        dc.w    PLAYER_START_Y
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
        dc.w    COLOR00+4,$0F80 ; Color 2 orange (player ship)
        dc.w    COLOR00+6,$08F0 ; Color 3 green (player ship details)
        
        dc.w    BPL1PTH
bp1h:   dc.w    0
        dc.w    BPL1PTL
bp1l:   dc.w    0
        
        dc.w    SPR0PTH
spr0h:  dc.w    0
        dc.w    SPR0PTL
spr0l:  dc.w    0
        
        dc.w    SPR0POS
spr0pos: dc.w   0
        dc.w    SPR0CTL
spr0ctl: dc.w   0
        
        dc.w    $FFFF,$FFFE     ; End of copper list

;----------------------------------------------------------------
; Player sprite data
;----------------------------------------------------------------
        SECTION sprite,DATA_C

playerSprite:
        ; 16x16 sprite data (2 words per line, 16 lines)
        ; First bitplane (orange parts)
        dc.w    %0000000110000000,%0000000000000000  ; Row 0
        dc.w    %0000001111000000,%0000000000000000  ; Row 1
        dc.w    %0000011111100000,%0000000000000000  ; Row 2
        dc.w    %0000111111110000,%0000000000000000  ; Row 3
        dc.w    %0001111111111000,%0000000000000000  ; Row 4
        dc.w    %0011111111111100,%0000000000000000  ; Row 5
        dc.w    %0111111111111110,%0000000000000000  ; Row 6
        dc.w    %1111111111111111,%0000000000000000  ; Row 7
        dc.w    %1111111111111111,%0000000000000000  ; Row 8
        dc.w    %0111111111111110,%0000000000000000  ; Row 9
        dc.w    %0011111111111100,%0000000000000000  ; Row 10
        dc.w    %0001111111111000,%0000000000000000  ; Row 11
        dc.w    %0000111111110000,%0000000000000000  ; Row 12
        dc.w    %0000011111100000,%0000000000000000  ; Row 13
        dc.w    %0100000110000010,%0000000000000000  ; Row 14 (engines)
        dc.w    %1000000000000001,%0000000000000000  ; Row 15 (engine flames)
        
        ; Second bitplane (green details)
        dc.w    %0000000000000000,%0000000110000000  ; Row 0
        dc.w    %0000000000000000,%0000001001000000  ; Row 1
        dc.w    %0000000000000000,%0000010000100000  ; Row 2
        dc.w    %0000000000000000,%0000100000010000  ; Row 3
        dc.w    %0000000000000000,%0001000000001000  ; Row 4
        dc.w    %0000000000000000,%0010000000000100  ; Row 5
        dc.w    %0000000000000000,%0100000000000010  ; Row 6
        dc.w    %0000000000000000,%1000000000000001  ; Row 7
        dc.w    %0000000000000000,%1000000000000001  ; Row 8
        dc.w    %0000000000000000,%0100000000000010  ; Row 9
        dc.w    %0000000000000000,%0010000000000100  ; Row 10
        dc.w    %0000000000000000,%0001000000001000  ; Row 11
        dc.w    %0000000000000000,%0000100000010000  ; Row 12
        dc.w    %0000000000000000,%0000010000100000  ; Row 13
        dc.w    %0000000000000000,%0100000000000010  ; Row 14
        dc.w    %0000000000000000,%1000000000000001  ; Row 15
        
        ; Sprite control words (end of sprite)
        dc.w    $0000,$0000

;----------------------------------------------------------------
; Screen buffer
;----------------------------------------------------------------
        SECTION screen_mem,BSS_C

screen: ds.b    SCREEN_HEIGHT*SCREEN_BROW

        END