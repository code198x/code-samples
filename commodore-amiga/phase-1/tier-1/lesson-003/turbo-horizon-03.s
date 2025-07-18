; turbo-horizon-03.s
; Lesson 3: Quantum Blasters
; Add hardware sprite-based shooting mechanics to Turbo Horizon

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

SPR1PTH         EQU     $124
SPR1PTL         EQU     $126
SPR1POS         EQU     $148
SPR1CTL         EQU     $14A

SPR2PTH         EQU     $128
SPR2PTL         EQU     $12A
SPR2POS         EQU     $150
SPR2CTL         EQU     $152

SPR3PTH         EQU     $12C
SPR3PTL         EQU     $12E
SPR3POS         EQU     $158
SPR3CTL         EQU     $15A

SPR4PTH         EQU     $130
SPR4PTL         EQU     $132
SPR4POS         EQU     $160
SPR4CTL         EQU     $162

SPR5PTH         EQU     $134
SPR5PTL         EQU     $136
SPR5POS         EQU     $168
SPR5CTL         EQU     $16A

SPR6PTH         EQU     $138
SPR6PTL         EQU     $13A
SPR6POS         EQU     $170
SPR6CTL         EQU     $172

SPR7PTH         EQU     $13C
SPR7PTL         EQU     $13E
SPR7POS         EQU     $178
SPR7CTL         EQU     $17A

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

; Bullet system constants
MAX_BULLETS     EQU     7       ; Maximum simultaneous bullets (sprites 1-7)
BULLET_SPEED    EQU     3       ; Bullet movement speed per frame
BULLET_COOLDOWN_TIME EQU 12    ; Frames between shots
BULLET_HEIGHT   EQU     8       ; Height of bullet sprite

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
        
        ; Initialize bullet system
        bsr     initBullets
        
        ; Set up copper list
        lea     copperList,a0
        move.l  a0,COP1LCH(a5)
        
        ; Set up bitplane pointer in copper list
        lea     screen,a0
        move.l  a0,d0
        move.w  d0,bp1l
        swap    d0
        move.w  d0,bp1h
        
        ; Set up player sprite pointer in copper list
        lea     playerSprite,a0
        move.l  a0,d0
        move.w  d0,spr0l
        swap    d0
        move.w  d0,spr0h
        
        ; Set up bullet sprite pointers in copper list
        bsr     setupBulletSprites
        
        ; Enable DMA
        move.w  #$83FF,DMACON(a5)       ; COPPER, BITPLANE, SPRITE, MASTER (all sprites)
        
        ; Main loop
mainLoop:
        ; Wait for vertical blank
        bsr     waitVBlank
        
        ; Handle input
        bsr     handleInput
        
        ; Update bullets
        bsr     updateBullets
        
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
; Initialize bullet system
;----------------------------------------------------------------
initBullets:
        ; Clear bullet data
        lea     bulletActive,a0
        moveq   #MAX_BULLETS-1,d0
.clearLoop:
        clr.b   (a0)+
        clr.w   (a0)+                   ; bulletX
        clr.w   (a0)+                   ; bulletY
        dbf     d0,.clearLoop
        
        ; Initialize cooldown
        clr.w   bulletCooldown
        
        rts

;----------------------------------------------------------------
; Setup bullet sprite pointers
;----------------------------------------------------------------
setupBulletSprites:
        ; Set up bullet sprite pointers (sprites 1-7)
        lea     bulletSprite,a0
        move.l  a0,d0
        
        ; Sprite 1
        move.w  d0,spr1l
        swap    d0
        move.w  d0,spr1h
        swap    d0
        
        ; Sprite 2
        move.w  d0,spr2l
        swap    d0
        move.w  d0,spr2h
        swap    d0
        
        ; Sprite 3
        move.w  d0,spr3l
        swap    d0
        move.w  d0,spr3h
        swap    d0
        
        ; Sprite 4
        move.w  d0,spr4l
        swap    d0
        move.w  d0,spr4h
        swap    d0
        
        ; Sprite 5
        move.w  d0,spr5l
        swap    d0
        move.w  d0,spr5h
        swap    d0
        
        ; Sprite 6
        move.w  d0,spr6l
        swap    d0
        move.w  d0,spr6h
        swap    d0
        
        ; Sprite 7
        move.w  d0,spr7l
        swap    d0
        move.w  d0,spr7h
        
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
        bne.s   checkFire
        
        ; Move right
        move.w  playerX,d0
        cmp.w   #PLAYER_MAX_X,d0
        bge.s   checkFire
        add.w   #PLAYER_SPEED,d0
        move.w  d0,playerX

checkFire:
        ; Check fire button (joystick button = bit 7 of POTGOR)
        move.w  POTGOR(a5),d0
        btst    #7,d0                   ; Fire button
        bne.s   inputDone               ; Button not pressed (active low)
        
        ; Fire bullet
        bsr     fireBullet
        
inputDone:
        ; Update sprite position
        bsr     updatePlayerSprite
        
        rts

;----------------------------------------------------------------
; Fire bullet
;----------------------------------------------------------------
fireBullet:
        ; Check cooldown
        move.w  bulletCooldown,d0
        bne.s   .done
        
        ; Find inactive bullet slot
        lea     bulletActive,a0
        moveq   #MAX_BULLETS-1,d0
        moveq   #0,d1                   ; Bullet index
        
.findSlot:
        tst.b   (a0)
        beq.s   .foundSlot
        addq.l  #5,a0                   ; Next bullet (1 byte active + 2 word positions)
        addq.w  #1,d1
        dbf     d0,.findSlot
        rts                             ; No free slots
        
.foundSlot:
        ; Activate bullet
        move.b  #1,(a0)+
        
        ; Set bullet position (centered on player)
        move.w  playerX,d0
        add.w   #6,d0                   ; Center horizontally
        move.w  d0,(a0)+                ; bulletX
        
        move.w  playerY,d0
        sub.w   #8,d0                   ; Start above player
        move.w  d0,(a0)                 ; bulletY
        
        ; Set cooldown
        move.w  #BULLET_COOLDOWN_TIME,bulletCooldown
        
.done:
        rts

;----------------------------------------------------------------
; Update bullets
;----------------------------------------------------------------
updateBullets:
        ; Update cooldown
        move.w  bulletCooldown,d0
        beq.s   .updatePositions
        subq.w  #1,d0
        move.w  d0,bulletCooldown
        
.updatePositions:
        ; Process each bullet
        lea     bulletActive,a0
        moveq   #MAX_BULLETS-1,d0
        moveq   #0,d1                   ; Bullet index
        
.bulletLoop:
        ; Check if bullet is active
        tst.b   (a0)
        beq.s   .nextBullet
        
        ; Move bullet up
        move.w  2(a0),d2                ; bulletY
        sub.w   #BULLET_SPEED,d2
        cmp.w   #16,d2                  ; Check if off screen
        blt.s   .deactivate
        
        ; Update position
        move.w  d2,2(a0)                ; bulletY
        bra.s   .nextBullet
        
.deactivate:
        ; Deactivate bullet
        clr.b   (a0)
        
.nextBullet:
        addq.l  #5,a0                   ; Next bullet
        addq.w  #1,d1
        dbf     d0,.bulletLoop
        
        ; Update sprite positions
        bsr     updateBulletSprites
        
        rts

;----------------------------------------------------------------
; Update bullet sprite positions
;----------------------------------------------------------------
updateBulletSprites:
        lea     bulletActive,a0
        lea     spr1pos,a1              ; Start with sprite 1 position
        moveq   #MAX_BULLETS-1,d0
        
.spriteLoop:
        ; Check if bullet is active
        tst.b   (a0)
        beq.s   .hideSprite
        
        ; Get bullet position
        move.w  1(a0),d1                ; bulletX
        move.w  3(a0),d2                ; bulletY
        
        ; Create sprite position value
        move.w  d2,d3
        lsl.w   #8,d3                   ; VSTART in upper 8 bits
        move.w  d1,d4
        lsr.w   #1,d4                   ; HSTART/2 in lower 8 bits
        or.w    d4,d3
        move.w  d3,(a1)                 ; SPRnPOS
        
        ; Create sprite control value
        move.w  d2,d3
        add.w   #BULLET_HEIGHT,d3       ; VSTOP = VSTART + height
        lsl.w   #8,d3                   ; VSTOP in upper 8 bits
        move.w  d1,d4
        and.w   #1,d4                   ; HSTART LSB
        or.w    d4,d3
        move.w  d3,8(a1)                ; SPRnCTL (8 bytes after POS)
        
        bra.s   .nextSprite
        
.hideSprite:
        ; Hide sprite (move off screen)
        move.w  #$0000,(a1)             ; SPRnPOS
        move.w  #$0000,8(a1)            ; SPRnCTL
        
.nextSprite:
        addq.l  #5,a0                   ; Next bullet
        add.l   #16,a1                  ; Next sprite registers (16 bytes apart)
        dbf     d0,.spriteLoop
        
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
bulletCooldown: dc.w    0
                even

; Bullet data arrays (parallel arrays)
bulletActive:   ds.b    MAX_BULLETS     ; Active flags
bulletX:        ds.w    MAX_BULLETS     ; X positions
bulletY:        ds.w    MAX_BULLETS     ; Y positions
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
        dc.w    COLOR00+8,$0FF0 ; Color 4 bright yellow (bullets)
        dc.w    COLOR00+10,$0F00 ; Color 5 bright red (bullet core)
        
        dc.w    BPL1PTH
bp1h:   dc.w    0
        dc.w    BPL1PTL
bp1l:   dc.w    0
        
        ; Player sprite (sprite 0)
        dc.w    SPR0PTH
spr0h:  dc.w    0
        dc.w    SPR0PTL
spr0l:  dc.w    0
        dc.w    SPR0POS
spr0pos: dc.w   0
        dc.w    SPR0CTL
spr0ctl: dc.w   0
        
        ; Bullet sprites (sprites 1-7)
        dc.w    SPR1PTH
spr1h:  dc.w    0
        dc.w    SPR1PTL
spr1l:  dc.w    0
        dc.w    SPR1POS
spr1pos: dc.w   0
        dc.w    SPR1CTL
spr1ctl: dc.w   0
        
        dc.w    SPR2PTH
spr2h:  dc.w    0
        dc.w    SPR2PTL
spr2l:  dc.w    0
        dc.w    SPR2POS
spr2pos: dc.w   0
        dc.w    SPR2CTL
spr2ctl: dc.w   0
        
        dc.w    SPR3PTH
spr3h:  dc.w    0
        dc.w    SPR3PTL
spr3l:  dc.w    0
        dc.w    SPR3POS
spr3pos: dc.w   0
        dc.w    SPR3CTL
spr3ctl: dc.w   0
        
        dc.w    SPR4PTH
spr4h:  dc.w    0
        dc.w    SPR4PTL
spr4l:  dc.w    0
        dc.w    SPR4POS
spr4pos: dc.w   0
        dc.w    SPR4CTL
spr4ctl: dc.w   0
        
        dc.w    SPR5PTH
spr5h:  dc.w    0
        dc.w    SPR5PTL
spr5l:  dc.w    0
        dc.w    SPR5POS
spr5pos: dc.w   0
        dc.w    SPR5CTL
spr5ctl: dc.w   0
        
        dc.w    SPR6PTH
spr6h:  dc.w    0
        dc.w    SPR6PTL
spr6l:  dc.w    0
        dc.w    SPR6POS
spr6pos: dc.w   0
        dc.w    SPR6CTL
spr6ctl: dc.w   0
        
        dc.w    SPR7PTH
spr7h:  dc.w    0
        dc.w    SPR7PTL
spr7l:  dc.w    0
        dc.w    SPR7POS
spr7pos: dc.w   0
        dc.w    SPR7CTL
spr7ctl: dc.w   0
        
        dc.w    $FFFF,$FFFE     ; End of copper list

;----------------------------------------------------------------
; Sprite data
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

bulletSprite:
        ; 8x8 bullet sprite data (quantum energy bolt)
        ; First bitplane (bright yellow core)
        dc.w    %0001100000000000,%0000000000000000  ; Row 0
        dc.w    %0011110000000000,%0000000000000000  ; Row 1
        dc.w    %0111111000000000,%0000000000000000  ; Row 2
        dc.w    %1111111100000000,%0000000000000000  ; Row 3
        dc.w    %1111111100000000,%0000000000000000  ; Row 4
        dc.w    %0111111000000000,%0000000000000000  ; Row 5
        dc.w    %0011110000000000,%0000000000000000  ; Row 6
        dc.w    %0001100000000000,%0000000000000000  ; Row 7
        
        ; Second bitplane (bright red outer glow)
        dc.w    %0000000000000000,%0001100000000000  ; Row 0
        dc.w    %0000000000000000,%0001100000000000  ; Row 1
        dc.w    %0000000000000000,%0001100000000000  ; Row 2
        dc.w    %0000000000000000,%0001100000000000  ; Row 3
        dc.w    %0000000000000000,%0001100000000000  ; Row 4
        dc.w    %0000000000000000,%0001100000000000  ; Row 5
        dc.w    %0000000000000000,%0001100000000000  ; Row 6
        dc.w    %0000000000000000,%0001100000000000  ; Row 7
        
        ; Sprite control words (end of sprite)
        dc.w    $0000,$0000

;----------------------------------------------------------------
; Screen buffer
;----------------------------------------------------------------
        SECTION screen_mem,BSS_C

screen: ds.b    SCREEN_HEIGHT*SCREEN_BROW

        END