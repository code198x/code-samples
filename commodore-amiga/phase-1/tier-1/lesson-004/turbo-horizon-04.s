* turbo-horizon-04.s
* Lesson 4: Hardware Collision Detection
* Add obstacles and use Amiga's hardware collision detection

        section code,code

start:
        bsr     init_system
        bsr     init_display
        bsr     init_sprites
        bsr     init_collision
        bsr     init_game
        bsr     main_loop
        bsr     cleanup
        rts

* ------------------------------------------------------------------------------
* System Initialization
* ------------------------------------------------------------------------------
init_system:
        move.l  4.w,a6              * ExecBase
        
        * Disable interrupts and DMA
        move.w  #$7fff,INTENA(a5)   * Disable all interrupts
        move.w  #$7fff,DMACON(a5)   * Disable all DMA
        
        * Save system state
        lea     gfxname,a1
        moveq   #0,d0
        jsr     -552(a6)            * OpenLibrary
        move.l  d0,gfxbase
        beq     .error
        
        move.l  d0,a6
        move.l  34(a6),oldview      * Save current view
        sub.l   a1,a1
        jsr     -222(a6)            * LoadView(NULL)
        jsr     -270(a6)            * WaitTOF
        jsr     -270(a6)            * WaitTOF
        
        * Take over the blitter
        jsr     -456(a6)            * OwnBlitter
        jsr     -228(a6)            * WaitBlit
        
        lea     CUSTOM,a5
        move.w  #$0200,BPLCON0(a5)  * Basic playfield setup
        rts
        
.error:
        moveq   #-1,d0
        rts

* ------------------------------------------------------------------------------
* Initialize Display
* ------------------------------------------------------------------------------
init_display:
        * Set up bitplanes
        move.l  #screen1,d0
        move.w  d0,BPL1PTL(a5)
        swap    d0
        move.w  d0,BPL1PTH(a5)
        
        * Set colors
        move.w  #$0000,COLOR00(a5)  * Background - black
        move.w  #$0fff,COLOR01(a5)  * Foreground - white
        
        * Sprite colors (shared by sprites 0-7)
        move.w  #$0000,COLOR16(a5)  * Transparent
        move.w  #$00ff,COLOR17(a5)  * Cyan (ship)
        move.w  #$0ff0,COLOR18(a5)  * Yellow (bullets)
        move.w  #$0f00,COLOR19(a5)  * Red (enemies)
        
        * Second sprite palette
        move.w  #$0000,COLOR20(a5)  * Transparent
        move.w  #$0f80,COLOR21(a5)  * Orange (explosions)
        move.w  #$0ff0,COLOR22(a5)  * Yellow
        move.w  #$0fff,COLOR23(a5)  * White
        
        * Enable display DMA
        move.w  #$8380,DMACON(a5)   * DMAEN|BPLEN|SPREN
        move.w  #$3200,DDFSTRT(a5)  * Display data fetch
        move.w  #$00d0,DDFSTOP(a5)
        move.w  #$2c81,DIWSTRT(a5)  * Display window
        move.w  #$2cc1,DIWSTOP(a5)
        
        rts

* ------------------------------------------------------------------------------
* Initialize Sprites
* ------------------------------------------------------------------------------
init_sprites:
        * Initialize copper list with sprite pointers
        lea     copper_list,a0
        lea     sprite_data,a1
        
        * Sprite 0 - Player ship
        move.l  a1,d0
        move.w  d0,6(a0)            * Low word
        swap    d0
        move.w  d0,2(a0)            * High word
        
        * Sprites 1-3 - Bullets
        lea     16(a0),a0           * Next copper sprite pointer
        lea     bullet_sprite,a1
        moveq   #2,d7               * 3 bullets
.bullet_loop:
        move.l  a1,d0
        move.w  d0,6(a0)
        swap    d0
        move.w  d0,2(a0)
        lea     16(a0),a0
        dbf     d7,.bullet_loop
        
        * Sprites 4-7 - Enemies/Explosions
        lea     enemy_sprite,a1
        moveq   #3,d7               * 4 enemies
.enemy_loop:
        move.l  a1,d0
        move.w  d0,6(a0)
        swap    d0
        move.w  d0,2(a0)
        lea     16(a0),a0
        dbf     d7,.enemy_loop
        
        * Activate copper list
        move.l  #copper_list,COP1LC(a5)
        move.w  #0,COPJMP1(a5)
        
        rts

* ------------------------------------------------------------------------------
* Initialize Collision Detection
* ------------------------------------------------------------------------------
init_collision:
        * Set up collision control
        * CLXCON: 
        * Bit 12-13: Match sprites in odd/even groups
        * Bit 6: Enable sprite 4-5 collisions
        * Bit 7: Enable sprite 6-7 collisions
        move.w  #$00c0,CLXCON(a5)   * Enable sprite collisions
        
        * Clear collision register
        move.w  CLXDAT(a5),d0       * Read to clear
        
        rts

* ------------------------------------------------------------------------------
* Initialize Game State
* ------------------------------------------------------------------------------
init_game:
        * Player position
        move.w  #50,ship_x
        move.w  #128,ship_y
        
        * Clear bullets
        lea     bullet_active,a0
        moveq   #MAX_BULLETS-1,d0
.clear_bullets:
        clr.b   (a0)+
        clr.w   (a0)+               * X
        clr.w   (a0)+               * Y
        dbf     d0,.clear_bullets
        
        * Initialize enemies
        lea     enemy_active,a0
        lea     enemy_init_x,a1
        lea     enemy_init_y,a2
        moveq   #MAX_ENEMIES-1,d0
.init_enemies:
        move.b  #1,(a0)+            * Active
        move.w  (a1)+,d1
        move.w  d1,(a0)+            * X
        move.w  (a2)+,d1
        move.w  d1,(a0)+            * Y
        dbf     d0,.init_enemies
        
        * Clear explosions
        lea     explosion_active,a0
        moveq   #MAX_ENEMIES-1,d0
.clear_explosions:
        clr.b   (a0)+
        clr.w   (a0)+               * X
        clr.w   (a0)+               * Y
        clr.b   (a0)+               * Timer
        dbf     d0,.clear_explosions
        
        * Clear variables
        clr.w   fire_cooldown
        clr.l   frame_counter
        
        rts

* ------------------------------------------------------------------------------
* Main Game Loop
* ------------------------------------------------------------------------------
main_loop:
.loop:
        bsr     wait_vblank
        bsr     read_input
        bsr     update_ship
        bsr     update_bullets
        bsr     update_enemies
        bsr     check_collisions
        bsr     update_explosions
        bsr     update_sprites
        
        btst    #6,$bfe001          * Left mouse button to exit
        bne     .loop
        rts

* ------------------------------------------------------------------------------
* Wait for Vertical Blank
* ------------------------------------------------------------------------------
wait_vblank:
.wait1:
        move.l  VPOSR(a5),d0
        and.l   #$0001ff00,d0
        cmp.l   #$00013700,d0       * Line 311
        bne     .wait1
.wait2:
        move.l  VPOSR(a5),d0
        and.l   #$0001ff00,d0
        cmp.l   #$00013700,d0
        beq     .wait2
        rts

* ------------------------------------------------------------------------------
* Read Input
* ------------------------------------------------------------------------------
read_input:
        move.w  JOY0DAT(a5),d0      * Read joystick
        
        * Check up (bit 0 XOR bit 1)
        move.w  d0,d1
        lsr.w   #1,d1
        eor.w   d0,d1
        btst    #0,d1
        beq     .check_down
        
        * Move up
        move.w  ship_y,d1
        cmp.w   #50,d1
        ble     .check_down
        subq.w  #2,d1
        move.w  d1,ship_y
        
.check_down:
        * Check down (bit 8 XOR bit 9)
        move.w  d0,d1
        lsr.w   #1,d1
        eor.w   d0,d1
        btst    #8,d1
        beq     .check_fire
        
        * Move down
        move.w  ship_y,d1
        cmp.w   #230,d1
        bge     .check_fire
        addq.w  #2,d1
        move.w  d1,ship_y
        
.check_fire:
        * Check fire button
        btst    #7,$bfe001          * CIAA PRA bit 7
        bne     .done
        
        * Check cooldown
        tst.w   fire_cooldown
        bne     .done
        
        bsr     fire_bullet
        move.w  #FIRE_COOLDOWN,fire_cooldown
        
.done:
        * Update cooldown
        tst.w   fire_cooldown
        beq     .exit
        subq.w  #1,fire_cooldown
.exit:
        rts

* ------------------------------------------------------------------------------
* Fire Bullet
* ------------------------------------------------------------------------------
fire_bullet:
        * Find inactive bullet
        lea     bullet_active,a0
        moveq   #MAX_BULLETS-1,d0
.find_loop:
        tst.b   (a0)
        beq     .found
        addq.l  #5,a0               * Next bullet
        dbf     d0,.find_loop
        rts                         * No free bullets
        
.found:
        move.b  #1,(a0)+            * Activate
        move.w  ship_x,d1
        add.w   #16,d1              * In front of ship
        move.w  d1,(a0)+            * X
        move.w  ship_y,(a0)     * Y
        rts

* ------------------------------------------------------------------------------
* Update Ship
* ------------------------------------------------------------------------------
update_ship:
        * Ship sprite is always sprite 0
        * Position handled in update_sprites
        rts

* ------------------------------------------------------------------------------
* Update Bullets
* ------------------------------------------------------------------------------
update_bullets:
        lea     bullet_active,a0
        moveq   #MAX_BULLETS-1,d7
.loop:
        tst.b   (a0)
        beq     .next
        
        * Move bullet right
        move.w  1(a0),d0            * X position
        add.w   #BULLET_SPEED,d0
        cmp.w   #320,d0             * Off screen?
        bge     .deactivate
        
        move.w  d0,1(a0)            * Update X
        bra     .next
        
.deactivate:
        clr.b   (a0)                * Deactivate
        
.next:
        addq.l  #5,a0               * Next bullet
        dbf     d7,.loop
        rts

* ------------------------------------------------------------------------------
* Update Enemies
* ------------------------------------------------------------------------------
update_enemies:
        lea     enemy_active,a0
        moveq   #MAX_ENEMIES-1,d7
.loop:
        tst.b   (a0)
        beq     .next
        
        * Move enemy left
        move.w  1(a0),d0            * X position
        sub.w   #ENEMY_SPEED,d0
        cmp.w   #-16,d0             * Off screen?
        ble     .respawn
        
        move.w  d0,1(a0)            * Update X
        
        * Simple vertical movement
        move.l  frame_counter,d1
        lsr.l   #3,d1               * Slow down
        and.w   #$1f,d1             * 0-31
        add.w   d1,d0               * Use as sine offset
        
        * Calculate sine movement
        move.w  3(a0),d1            * Base Y
        move.w  d0,d2
        and.w   #$f,d2              * Simple sine approximation
        cmp.w   #8,d2
        blt     .positive
        neg.w   d2
        add.w   #16,d2
.positive:
        lsl.w   #1,d2               * Scale
        add.w   d2,d1
        move.w  d1,3(a0)            * Update Y
        
        bra     .next
        
.respawn:
        * Respawn on right
        move.w  #320,1(a0)          * X
        * Random Y position (simple pseudo-random)
        move.l  frame_counter,d0
        mulu    #31415,d0
        and.w   #$7f,d0             * 0-127
        add.w   #60,d0              * 60-187
        move.w  d0,3(a0)            * Y
        
.next:
        addq.l  #5,a0               * Next enemy
        dbf     d7,.loop
        
        addq.l  #1,frame_counter
        rts

* ------------------------------------------------------------------------------
* Check Hardware Collisions
* ------------------------------------------------------------------------------
check_collisions:
        * Read collision register
        move.w  CLXDAT(a5),d0       * Get collision data
        
        * Check sprite collisions
        * Bit 0: Sprite 0/1 collision
        * Bit 1: Sprite 0/2 collision
        * Bit 2: Sprite 0/3 collision
        * etc...
        
        * Check bullets (sprites 1-3) vs enemies (sprites 4-7)
        moveq   #0,d1               * Bullet index
        moveq   #1,d2               * Bit mask
        
.check_bullets:
        * Check each bullet sprite
        moveq   #0,d3               * Enemy index
        moveq   #$10,d4             * Enemy bit mask (sprite 4)
        
.check_enemies:
        move.w  d2,d5
        lsl.w   #4,d5               * Shift to enemy position
        and.w   d4,d5
        and.w   d0,d5               * Test collision bit
        beq     .no_collision
        
        * Collision detected!
        bsr     handle_collision
        
.no_collision:
        lsl.w   #1,d4               * Next enemy bit
        addq.w  #1,d3               * Next enemy index
        cmp.w   #MAX_ENEMIES,d3
        blt     .check_enemies
        
        lsl.w   #1,d2               * Next bullet bit
        addq.w  #1,d1               * Next bullet index
        cmp.w   #MAX_BULLETS,d1
        blt     .check_bullets
        
        * Clear collision register for next frame
        move.w  CLXDAT(a5),d0       * Read to clear
        
        rts

* ------------------------------------------------------------------------------
* Handle Collision
* Input: d1 = bullet index, d3 = enemy index
* ------------------------------------------------------------------------------
handle_collision:
        movem.l d0-d7/a0-a6,-(sp)
        
        * Deactivate bullet
        lea     bullet_active,a0
        move.w  d1,d0
        mulu    #5,d0               * Bullet structure size
        add.w   d0,a0
        clr.b   (a0)                * Deactivate
        
        * Deactivate enemy
        lea     enemy_active,a0
        move.w  d3,d0
        mulu    #5,d0               * Enemy structure size
        add.w   d0,a0
        tst.b   (a0)                * Check if active
        beq     .done               * Already inactive
        
        clr.b   (a0)+               * Deactivate
        move.w  (a0)+,d4            * Get X
        move.w  (a0),d5             * Get Y
        
        * Start explosion
        lea     explosion_active,a0
        move.w  d3,d0
        mulu    #6,d0               * Explosion structure size
        add.w   d0,a0
        
        move.b  #EXPLOSION_TIME,(a0)+
        move.w  d4,(a0)+            * X
        move.w  d5,(a0)+            * Y
        
.done:
        movem.l (sp)+,d0-d7/a0-a6
        rts

* ------------------------------------------------------------------------------
* Update Explosions
* ------------------------------------------------------------------------------
update_explosions:
        lea     explosion_active,a0
        moveq   #MAX_ENEMIES-1,d7
.loop:
        tst.b   (a0)
        beq     .next
        
        subq.b  #1,(a0)             * Decrement timer
        bne     .next
        
        * Explosion finished
        clr.l   (a0)                * Clear all
        clr.w   4(a0)
        
.next:
        addq.l  #6,a0               * Next explosion
        dbf     d7,.loop
        rts

* ------------------------------------------------------------------------------
* Update Hardware Sprites
* ------------------------------------------------------------------------------
update_sprites:
        * Sprite 0 - Player ship
        lea     sprite_data,a0
        move.w  ship_y,d0
        move.b  d0,(a0)             * VSTART
        add.w   #16,d0              * Height
        move.b  d0,2(a0)            * VSTOP
        
        move.w  ship_x,d0
        add.w   #128,d0             * Sprite X offset
        move.w  d0,d1
        lsr.w   #1,d1               * HSTART
        move.b  d1,1(a0)
        btst    #0,d0               * Bit 0 in control word
        beq     .no_bit0
        bset    #0,3(a0)
        bra     .ship_done
.no_bit0:
        bclr    #0,3(a0)
.ship_done:
        
        * Sprites 1-3 - Bullets
        lea     bullet_sprite,a0
        lea     bullet_active,a1
        moveq   #MAX_BULLETS-1,d7
        moveq   #1,d6               * Sprite number
        
.bullet_loop:
        tst.b   (a1)
        beq     .hide_bullet
        
        * Position bullet sprite
        move.w  3(a1),d0            * Y
        move.b  d0,(a0)             * VSTART
        addq.w  #8,d0               * Height
        move.b  d0,2(a0)            * VSTOP
        
        move.w  1(a1),d0            * X
        add.w   #128,d0             * Sprite X offset
        move.w  d0,d1
        lsr.w   #1,d1               * HSTART
        move.b  d1,1(a0)
        btst    #0,d0
        beq     .no_bit0_bullet
        bset    #0,3(a0)
        bra     .next_bullet
.no_bit0_bullet:
        bclr    #0,3(a0)
        bra     .next_bullet
        
.hide_bullet:
        * Hide sprite off screen
        move.b  #0,(a0)             * VSTART = 0
        move.b  #0,2(a0)            * VSTOP = 0
        
.next_bullet:
        * Move to next sprite control in copper list
        move.w  d6,d0
        lsl.w   #3,d0               * 8 bytes per sprite
        lea     copper_sprite_ptrs,a2
        add.w   d0,a2
        add.w   d0,a2               * 16 bytes per pointer pair
        move.l  a0,d0
        move.w  d0,6(a2)            * Low word
        swap    d0
        move.w  d0,2(a2)            * High word
        
        addq.l  #5,a1               * Next bullet data
        addq.w  #1,d6               * Next sprite number
        dbf     d7,.bullet_loop
        
        * Sprites 4-7 - Enemies or Explosions
        lea     enemy_sprite,a0
        lea     enemy_active,a1
        lea     explosion_active,a2
        moveq   #MAX_ENEMIES-1,d7
        moveq   #4,d6               * Starting sprite number
        
.enemy_loop:
        * Check if explosion active
        tst.b   (a2)
        beq     .check_enemy
        
        * Show explosion
        lea     explosion_sprite,a0
        move.w  1(a2),d0            * X
        move.w  3(a2),d1            * Y
        
        * Animate explosion
        move.b  (a2),d2             * Timer
        and.b   #4,d2               * Alternate frames
        beq     .explosion_frame2
        lea     explosion_sprite,a0
        bra     .position_explosion
.explosion_frame2:
        lea     explosion_sprite2,a0
        
.position_explosion:
        move.b  d1,(a0)             * VSTART
        add.w   #16,d1
        move.b  d1,2(a0)            * VSTOP
        
        add.w   #128,d0             * Sprite X offset
        move.w  d0,d1
        lsr.w   #1,d1
        move.b  d1,1(a0)
        btst    #0,d0
        beq     .no_bit0_expl
        bset    #0,3(a0)
        bra     .next_enemy
.no_bit0_expl:
        bclr    #0,3(a0)
        bra     .next_enemy
        
.check_enemy:
        tst.b   (a1)
        beq     .hide_enemy
        
        * Show enemy
        lea     enemy_sprite,a0
        move.w  3(a1),d0            * Y
        move.b  d0,(a0)             * VSTART
        add.w   #16,d0
        move.b  d0,2(a0)            * VSTOP
        
        move.w  1(a1),d0            * X
        add.w   #128,d0             * Sprite X offset
        move.w  d0,d1
        lsr.w   #1,d1
        move.b  d1,1(a0)
        btst    #0,d0
        beq     .no_bit0_enemy
        bset    #0,3(a0)
        bra     .next_enemy
.no_bit0_enemy:
        bclr    #0,3(a0)
        bra     .next_enemy
        
.hide_enemy:
        * Hide sprite
        move.b  #0,(a0)
        move.b  #0,2(a0)
        
.next_enemy:
        * Update copper sprite pointer
        move.w  d6,d0
        lsl.w   #3,d0
        lea     copper_sprite_ptrs,a3
        add.w   d0,a3
        add.w   d0,a3
        move.l  a0,d0
        move.w  d0,6(a3)
        swap    d0
        move.w  d0,2(a3)
        
        addq.l  #5,a1               * Next enemy
        addq.l  #6,a2               * Next explosion
        addq.w  #1,d6               * Next sprite
        dbf     d7,.enemy_loop
        
        rts

* ------------------------------------------------------------------------------
* Cleanup
* ------------------------------------------------------------------------------
cleanup:
        * Restore system
        move.l  gfxbase,a6
        move.l  oldview,a1
        jsr     -222(a6)            * LoadView
        jsr     -270(a6)            * WaitTOF
        jsr     -270(a6)
        
        * Release blitter
        jsr     -228(a6)            * WaitBlit
        jsr     -462(a6)            * DisownBlitter
        
        * Close graphics library
        move.l  4.w,a6
        move.l  gfxbase,a1
        jsr     -414(a6)            * CloseLibrary
        
        * Enable system DMA
        move.w  #$83e0,DMACON(a5)
        
        rts

* ------------------------------------------------------------------------------
* Data Section
* ------------------------------------------------------------------------------
        section data,data

* Copper list
copper_list:
copper_sprite_ptrs:
        dc.w    SPR0PTH,$0000       * Sprite 0 pointer high
        dc.w    SPR0PTL,$0000       * Sprite 0 pointer low
        dc.w    SPR1PTH,$0000       * Sprite 1 pointer high
        dc.w    SPR1PTL,$0000       * Sprite 1 pointer low
        dc.w    SPR2PTH,$0000
        dc.w    SPR2PTL,$0000
        dc.w    SPR3PTH,$0000
        dc.w    SPR3PTL,$0000
        dc.w    SPR4PTH,$0000
        dc.w    SPR4PTL,$0000
        dc.w    SPR5PTH,$0000
        dc.w    SPR5PTL,$0000
        dc.w    SPR6PTH,$0000
        dc.w    SPR6PTL,$0000
        dc.w    SPR7PTH,$0000
        dc.w    SPR7PTL,$0000
        
        dc.w    BPLCON0,$0200       * 1 bitplane
        dc.w    BPL1MOD,$0000       * No modulo
        
        dc.w    $ffff,$fffe         * End of copper list

* Sprite data - Player ship
sprite_data:
        dc.w    $6050,$7200         * VSTART=96, HSTART=80, VSTOP=114
        dc.w    $0180,$03c0         * Ship shape line 1-2
        dc.w    $07e0,$0ff0
        dc.w    $1ff8,$3ffc
        dc.w    $7ffe,$ffff
        dc.w    $ffff,$7ffe
        dc.w    $3ffc,$1ff8
        dc.w    $0ff0,$07e0
        dc.w    $03c0,$0180
        dc.w    $0000,$0000         * End of sprite

* Bullet sprite
bullet_sprite:
        dc.w    $6050,$6800         * Smaller height
        dc.w    $0000,$3c00
        dc.w    $7e00,$ff00
        dc.w    $ff00,$7e00
        dc.w    $3c00,$0000
        dc.w    $0000,$0000

* Enemy sprite
enemy_sprite:
        dc.w    $6050,$7200
        dc.w    $0810,$1c38
        dc.w    $3e7c,$7ffe
        dc.w    $ffff,$ffff
        dc.w    $7ffe,$3ffc
        dc.w    $1ff8,$0ff0
        dc.w    $07e0,$03c0
        dc.w    $0180,$0000
        dc.w    $0000,$0000

* Explosion sprites
explosion_sprite:
        dc.w    $6050,$7200
        dc.w    $1008,$3018
        dc.w    $783c,$fc7e
        dc.w    $fe7f,$ffff
        dc.w    $ffff,$fe7f
        dc.w    $fc7e,$783c
        dc.w    $3018,$1008
        dc.w    $0000,$0000
        dc.w    $0000,$0000

explosion_sprite2:
        dc.w    $6050,$7200
        dc.w    $0420,$0e70
        dc.w    $1ff8,$3ffc
        dc.w    $7ffe,$ffff
        dc.w    $ffff,$7ffe
        dc.w    $3ffc,$1ff8
        dc.w    $0e70,$0420
        dc.w    $0000,$0000
        dc.w    $0000,$0000

* Enemy initial positions
enemy_init_x:  dc.w    280,300,320,340
enemy_init_y:  dc.w    80,120,160,200

* String constants
gfxname:        dc.b    'graphics.library',0
                even

* ------------------------------------------------------------------------------
* BSS Section
* ------------------------------------------------------------------------------
        section bss,bss

* System variables
gfxbase:        ds.l    1
oldview:        ds.l    1

* Game variables
ship_x:         ds.w    1
ship_y:         ds.w    1
fire_cooldown:  ds.w    1
frame_counter:  ds.l    1

* Bullet data (active, x, y)
bullet_active:  ds.b    MAX_BULLETS
                even
bullet_x:       ds.w    MAX_BULLETS
bullet_y:       ds.w    MAX_BULLETS

* Enemy data (active, x, y)
enemy_active:   ds.b    MAX_ENEMIES
                even
enemy_x:        ds.w    MAX_ENEMIES
enemy_y:        ds.w    MAX_ENEMIES

* Explosion data (timer, x, y)
explosion_active: ds.b  MAX_ENEMIES
                even
explosion_x:    ds.w    MAX_ENEMIES
explosion_y:    ds.w    MAX_ENEMIES

* Screen buffer
screen1:        ds.b    320*256/8

* ------------------------------------------------------------------------------
* Constants
* ------------------------------------------------------------------------------
CUSTOM          equ     $dff000
INTENA          equ     $09a
DMACON          equ     $096
VPOSR           equ     $004
VHPOSR          equ     $006
JOY0DAT         equ     $00a
JOY1DAT         equ     $00c
CLXDAT          equ     $00e
CLXCON          equ     $098

BPLCON0         equ     $100
BPLCON1         equ     $102
BPL1MOD         equ     $108
DDFSTRT         equ     $092
DDFSTOP         equ     $094
DIWSTRT         equ     $08e
DIWSTOP         equ     $090

BPL1PTH         equ     $0e0
BPL1PTL         equ     $0e2

SPR0PTH         equ     $120
SPR0PTL         equ     $122
SPR1PTH         equ     $124
SPR1PTL         equ     $126
SPR2PTH         equ     $128
SPR2PTL         equ     $12a
SPR3PTH         equ     $12c
SPR3PTL         equ     $12e
SPR4PTH         equ     $130
SPR4PTL         equ     $132
SPR5PTH         equ     $134
SPR5PTL         equ     $136
SPR6PTH         equ     $138
SPR6PTL         equ     $13a
SPR7PTH         equ     $13c
SPR7PTL         equ     $13e

COLOR00         equ     $180
COLOR01         equ     $182
COLOR16         equ     $1a0
COLOR17         equ     $1a2
COLOR18         equ     $1a4
COLOR19         equ     $1a6
COLOR20         equ     $1a8
COLOR21         equ     $1aa
COLOR22         equ     $1ac
COLOR23         equ     $1ae

COP1LC          equ     $080
COP2LC          equ     $084
COPJMP1         equ     $088
COPJMP2         equ     $08a

* Game constants
MAX_BULLETS     equ     3
MAX_ENEMIES     equ     4
BULLET_SPEED    equ     4
ENEMY_SPEED     equ     1
FIRE_COOLDOWN   equ     10
EXPLOSION_TIME  equ     16

        end