; cosmic-harvester-lesson-04.asm
; Add collision detection between bullets and asteroids
; Cosmic Harvester: Lesson 4 - Collision Detection

        * = $0801           ; BASIC start address

        ; BASIC header: 10 SYS 2064
        !byte $0c,$08,$0a,$00,$9e
        !text "2064"
        !byte $00,$00,$00

        * = $0810           ; Our code starts here

start:
        jsr clear_screen
        jsr create_starfield
        jsr setup_ship
        jsr setup_bullets
        jsr setup_asteroids
        jmp game_loop       ; Main game loop

; Screen and color constants
SCREEN_RAM = $0400
COLOR_RAM = $d800
CHAR_SPACE = 32
CHAR_STAR = 46      ; Period character for stars
CHAR_SHIP = 62      ; '>' character for ship
CHAR_BULLET = 124   ; '|' character for bullet
CHAR_ASTEROID = 79  ; 'O' character for asteroid
CHAR_EXPLOSION = 42 ; '*' character for explosion

; Colors
COLOR_BLACK = 0
COLOR_WHITE = 1
COLOR_CYAN = 3
COLOR_PURPLE = 4
COLOR_YELLOW = 7
COLOR_ORANGE = 8
COLOR_BROWN = 9
COLOR_LIGHT_GREY = 15

; Sprite/object constants
MAX_BULLETS = 6
MAX_ASTEROIDS = 8
FIRE_COOLDOWN = 10
BULLET_SPEED = 2
ASTEROID_SPEED = 1

; Zero page variables for pointers
screen_ptr = $fb        ; 2 bytes ($fb-$fc)
color_ptr = $fd         ; 2 bytes ($fd-$fe)
temp_byte = $ff

; Zero page collision detection variables
collision_x = $f0
collision_y = $f1
object1_x = $f2
object1_y = $f3
object2_x = $f4
object2_y = $f5
temp_x = $f6
temp_y = $f7

; Clear the screen
clear_screen:
        ldx #0
.loop:
        lda #CHAR_SPACE
        sta SCREEN_RAM,x
        sta SCREEN_RAM+256,x
        sta SCREEN_RAM+512,x
        sta SCREEN_RAM+768,x
        lda #COLOR_BLACK
        sta COLOR_RAM,x
        sta COLOR_RAM+256,x
        sta COLOR_RAM+512,x
        sta COLOR_RAM+768,x
        inx
        bne .loop
        rts

; Create random starfield
create_starfield:
        ldx #30             ; Number of stars
.star_loop:
        ; Get random position
        lda $d012           ; Use raster line as random
        adc starfield_seed
        sta starfield_seed
        and #3              ; Limit to 0-3
        tay
        lda star_pos_lo,y
        sta screen_ptr
        lda star_pos_hi,y
        sta screen_ptr+1
        
        ; Random offset within section
        lda $d012
        and #$7f            ; 0-127
        tay
        
        ; Place star
        lda #CHAR_STAR
        sta (screen_ptr),y
        
        ; Set star color (white or light grey)
        lda screen_ptr
        sta color_ptr
        lda screen_ptr+1
        clc
        adc #$d8-$04
        sta color_ptr+1
        
        lda $d012
        and #1
        beq .white_star
        lda #COLOR_LIGHT_GREY
        jmp .set_star_color
.white_star:
        lda #COLOR_WHITE
.set_star_color:
        sta (color_ptr),y
        
        dex
        bne .star_loop
        rts

; Setup player ship
setup_ship:
        lda #12             ; Starting Y position
        sta ship_y
        lda #5              ; Starting X position
        sta ship_x
        rts

; Setup bullet system
setup_bullets:
        ldx #0
        lda #0
.init_loop:
        sta bullet_active,x
        sta bullet_x,x
        sta bullet_y,x
        inx
        cpx #MAX_BULLETS
        bne .init_loop
        sta fire_cooldown
        rts

; Setup asteroids
setup_asteroids:
        ldx #0
.asteroid_init_loop:
        ; Random Y position
        lda $d012
        and #$0f            ; 0-15
        clc
        adc #4              ; 4-19
        sta asteroid_y,x
        
        ; Start from right side
        lda #39
        sta asteroid_x,x
        
        ; Mark as active
        lda #1
        sta asteroid_active,x
        
        ; Stagger initial positions
        txa
        asl
        asl
        asl                 ; x * 8
        clc
        adc asteroid_x,x
        sta asteroid_x,x
        
        inx
        cpx #MAX_ASTEROIDS
        bne .asteroid_init_loop
        
        ; Initialize explosion animation
        lda #0
        sta explosion_frame
        sta explosion_active
        rts

; Main game loop
game_loop:
        ; Wait for raster
        lda #250
.wait_raster:
        cmp $d012
        bne .wait_raster
        
        ; Update game state
        jsr update_starfield
        jsr handle_input
        jsr update_ship
        jsr update_bullets
        jsr update_asteroids
        jsr check_collisions
        jsr update_explosions
        
        jmp game_loop

; Update scrolling starfield
update_starfield:
        ; Simple effect - update a few random stars
        ldx #3
.update_loop:
        lda $d012
        sta screen_ptr
        lda $d012
        and #3
        clc
        adc #>SCREEN_RAM
        sta screen_ptr+1
        
        ldy #0
        lda (screen_ptr),y
        cmp #CHAR_STAR
        bne .next_star
        
        ; Clear old star
        lda #CHAR_SPACE
        sta (screen_ptr),y
        
        ; Move star left
        dey
        cpy #255
        beq .next_star
        
        ; Place new star
        lda #CHAR_STAR
        sta (screen_ptr),y
        
.next_star:
        dex
        bne .update_loop
        rts

; Handle keyboard input
handle_input:
        ; Check Q (up)
        lda #$7f
        sta $dc00
        lda $dc01
        and #$08
        beq .move_up
        
        ; Check A (down)  
        lda #$fd
        sta $dc00
        lda $dc01
        and #$20
        beq .move_down
        
        ; Check SPACE (fire)
        lda #$7f
        sta $dc00
        lda $dc01
        and #$10
        beq .fire
        
        jmp .input_done
        
.move_up:
        lda ship_y
        cmp #1
        beq .input_done
        dec ship_y
        jmp .input_done
        
.move_down:
        lda ship_y
        cmp #23
        beq .input_done
        inc ship_y
        jmp .input_done
        
.fire:
        lda fire_cooldown
        bne .input_done
        jsr fire_bullet
        lda #FIRE_COOLDOWN
        sta fire_cooldown
        
.input_done:
        lda fire_cooldown
        beq .no_cooldown
        dec fire_cooldown
.no_cooldown:
        rts

; Fire a bullet
fire_bullet:
        ldx #0
.find_inactive:
        lda bullet_active,x
        beq .found_slot
        inx
        cpx #MAX_BULLETS
        bne .find_inactive
        rts                 ; No free bullet slots
        
.found_slot:
        lda #1
        sta bullet_active,x
        lda ship_x
        clc
        adc #1              ; Start bullet in front of ship
        sta bullet_x,x
        lda ship_y
        sta bullet_y,x
        rts

; Update ship display
update_ship:
        ; Clear old ship position
        lda old_ship_y
        jsr get_screen_address
        ldy old_ship_x
        lda #CHAR_SPACE
        sta (screen_ptr),y
        
        ; Draw ship at new position
        lda ship_y
        jsr get_screen_address
        ldy ship_x
        lda #CHAR_SHIP
        sta (screen_ptr),y
        
        ; Set ship color
        lda screen_ptr
        sta color_ptr
        lda screen_ptr+1
        clc
        adc #$d8-$04       ; COLOR_RAM - SCREEN_RAM
        sta color_ptr+1
        lda #COLOR_CYAN
        sta (color_ptr),y
        
        ; Update old position
        lda ship_x
        sta old_ship_x
        lda ship_y
        sta old_ship_y
        rts

; Update all bullets
update_bullets:
        ldx #0
.bullet_update_loop:
        lda bullet_active,x
        beq .next_bullet
        
        ; Clear old bullet position
        lda bullet_y,x
        jsr get_screen_address
        ldy bullet_x,x
        lda #CHAR_SPACE
        sta (screen_ptr),y
        
        ; Move bullet right
        lda bullet_x,x
        clc
        adc #BULLET_SPEED
        sta bullet_x,x
        
        ; Check if bullet went off screen
        cmp #40
        bcc .draw_bullet
        
        ; Deactivate bullet
        lda #0
        sta bullet_active,x
        jmp .next_bullet
        
.draw_bullet:
        ; Draw bullet at new position
        lda bullet_y,x
        jsr get_screen_address
        ldy bullet_x,x
        lda #CHAR_BULLET
        sta (screen_ptr),y
        
        ; Set bullet color
        lda screen_ptr
        sta color_ptr
        lda screen_ptr+1
        clc
        adc #$d8-$04
        sta color_ptr+1
        lda #COLOR_YELLOW
        sta (color_ptr),y
        
.next_bullet:
        inx
        cpx #MAX_BULLETS
        bne .bullet_update_loop
        rts

; Update all asteroids
update_asteroids:
        ldx #0
.asteroid_update_loop:
        lda asteroid_active,x
        beq .next_asteroid
        
        ; Clear old asteroid position
        lda asteroid_y,x
        jsr get_screen_address
        ldy asteroid_x,x
        lda #CHAR_SPACE
        sta (screen_ptr),y
        
        ; Move asteroid left
        lda asteroid_x,x
        sec
        sbc #ASTEROID_SPEED
        sta asteroid_x,x
        
        ; Check if asteroid went off screen
        cmp #255            ; Wrapped around
        bne .draw_asteroid
        
        ; Respawn asteroid on right side
        lda #39
        sta asteroid_x,x
        
        ; New random Y position
        lda $d012
        and #$0f            ; 0-15
        clc
        adc #4              ; 4-19
        sta asteroid_y,x
        
.draw_asteroid:
        ; Draw asteroid at new position
        lda asteroid_y,x
        jsr get_screen_address
        ldy asteroid_x,x
        lda #CHAR_ASTEROID
        sta (screen_ptr),y
        
        ; Set asteroid color
        lda screen_ptr
        sta color_ptr
        lda screen_ptr+1
        clc
        adc #$d8-$04
        sta color_ptr+1
        lda #COLOR_BROWN
        sta (color_ptr),y
        
.next_asteroid:
        inx
        cpx #MAX_ASTEROIDS
        bne .asteroid_update_loop
        rts

; Check for collisions between bullets and asteroids
check_collisions:
        ldx #0              ; Bullet index
.collision_bullet_loop:
        lda bullet_active,x
        beq .collision_next_bullet
        
        ; Store bullet position
        lda bullet_x,x
        sta object1_x
        lda bullet_y,x
        sta object1_y
        
        ; Check against all asteroids
        ldy #0              ; Asteroid index
.collision_asteroid_loop:
        lda asteroid_active,y
        beq .collision_next_asteroid
        
        ; Store asteroid position
        lda asteroid_x,y
        sta object2_x
        lda asteroid_y,y
        sta object2_y
        
        ; Check collision
        jsr check_object_collision
        bcc .collision_next_asteroid  ; No collision
        
        ; Collision detected!
        ; Deactivate bullet
        lda #0
        sta bullet_active,x
        
        ; Deactivate asteroid
        lda #0
        sta asteroid_active,y
        
        ; Start explosion at asteroid position
        lda asteroid_x,y
        sta explosion_x
        lda asteroid_y,y
        sta explosion_y
        lda #1
        sta explosion_active
        lda #0
        sta explosion_frame
        
        ; Could add score here
        
        jmp .collision_next_bullet    ; This bullet is done
        
.collision_next_asteroid:
        iny
        cpy #MAX_ASTEROIDS
        bne .collision_asteroid_loop
        
.collision_next_bullet:
        inx
        cpx #MAX_BULLETS
        bne .collision_bullet_loop
        rts

; Check collision between two objects
; Input: object1_x/y, object2_x/y
; Output: Carry set if collision
check_object_collision:
        ; Check X collision
        lda object1_x
        sec
        sbc object2_x
        bcs .positive_x
        ; Make positive
        eor #$ff
        clc
        adc #1
.positive_x:
        cmp #2              ; Within 2 characters
        bcs .no_collision
        
        ; Check Y collision
        lda object1_y
        sec
        sbc object2_y
        bcs .positive_y
        ; Make positive
        eor #$ff
        clc
        adc #1
.positive_y:
        cmp #2              ; Within 2 characters
        bcs .no_collision
        
        ; Collision!
        sec
        rts
        
.no_collision:
        clc
        rts

; Update explosion animation
update_explosions:
        lda explosion_active
        beq .done
        
        ; Clear old explosion
        lda explosion_y
        jsr get_screen_address
        ldy explosion_x
        lda #CHAR_SPACE
        sta (screen_ptr),y
        
        ; Update animation frame
        inc explosion_frame
        lda explosion_frame
        cmp #8              ; Animation length
        bcc .draw_explosion
        
        ; End explosion
        lda #0
        sta explosion_active
        rts
        
.draw_explosion:
        ; Draw explosion
        lda explosion_y
        jsr get_screen_address
        ldy explosion_x
        lda #CHAR_EXPLOSION
        sta (screen_ptr),y
        
        ; Set explosion color (cycle through colors)
        lda screen_ptr
        sta color_ptr
        lda screen_ptr+1
        clc
        adc #$d8-$04
        sta color_ptr+1
        
        lda explosion_frame
        and #3
        tax
        lda explosion_colors,x
        sta (color_ptr),y
        
.done:
        rts

; Get screen address for row in A
; Returns address in screen_ptr
get_screen_address:
        sta temp_byte       ; Save row number
        lda #0
        sta screen_ptr+1
        
        ; Multiply by 40
        lda temp_byte
        asl                 ; x2
        asl                 ; x4
        asl                 ; x8
        sta screen_ptr
        
        lda temp_byte
        asl                 ; x2
        asl                 ; x4
        asl                 ; x8
        asl                 ; x16
        asl                 ; x32
        clc
        adc screen_ptr      ; x8 + x32 = x40
        sta screen_ptr
        
        lda screen_ptr+1
        adc #0              ; Add carry
        clc
        adc #>SCREEN_RAM
        sta screen_ptr+1
        
        rts

; Data tables
star_pos_lo:
        !byte <SCREEN_RAM, <SCREEN_RAM+256, <SCREEN_RAM+512, <SCREEN_RAM+768
star_pos_hi:
        !byte >SCREEN_RAM, >SCREEN_RAM+256, >SCREEN_RAM+512, >SCREEN_RAM+768

explosion_colors:
        !byte COLOR_YELLOW, COLOR_ORANGE, COLOR_PURPLE, COLOR_WHITE

; Variables
starfield_seed:    !byte 42
ship_x:            !byte 5
ship_y:            !byte 12
old_ship_x:        !byte 5
old_ship_y:        !byte 12
fire_cooldown:     !byte 0

; Bullet arrays
bullet_active:     !fill MAX_BULLETS, 0
bullet_x:          !fill MAX_BULLETS, 0
bullet_y:          !fill MAX_BULLETS, 0

; Asteroid arrays
asteroid_active:   !fill MAX_ASTEROIDS, 0
asteroid_x:        !fill MAX_ASTEROIDS, 0
asteroid_y:        !fill MAX_ASTEROIDS, 0

; Explosion animation
explosion_active:  !byte 0
explosion_x:       !byte 0
explosion_y:       !byte 0
explosion_frame:   !byte 0