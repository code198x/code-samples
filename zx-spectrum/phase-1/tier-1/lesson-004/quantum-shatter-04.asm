; quantum-shatter-04.asm
; Lesson 4: Collision Detection
; Add enemy ships and collision detection

                device  zxspectrum48
                
                org     32768           ; Start at 32768

; -----------------------------------------------------------------------------
; System Constants
; -----------------------------------------------------------------------------
SCREEN_START    equ     16384          ; Screen memory start
ATTR_START      equ     22528          ; Attribute memory start
SCREEN_WIDTH    equ     32             ; Screen width in characters
SCREEN_HEIGHT   equ     24             ; Screen height in characters

; Colors (PAPER * 8 + INK)
BLACK           equ     0
BLUE            equ     1
RED             equ     2
MAGENTA         equ     3
GREEN           equ     4
CYAN            equ     5
YELLOW          equ     6
WHITE           equ     7
BRIGHT_BIT      equ     64             ; Add for bright colors

; Characters
CHAR_SPACE      equ     0              ; Space character
CHAR_STAR       equ     42             ; '*' for stars
CHAR_PLAYER     equ     62             ; '>' for player ship
CHAR_BULLET     equ     45             ; '-' for bullets
CHAR_ENEMY      equ     60             ; '<' for enemy ships
CHAR_EXPLOSION  equ     79             ; 'O' for explosions

; Game constants
MAX_BULLETS     equ     6
MAX_ENEMIES     equ     5
FIRE_COOLDOWN   equ     12
BULLET_SPEED    equ     2
ENEMY_SPEED     equ     1
EXPLOSION_TIME  equ     8

; -----------------------------------------------------------------------------
; Entry Point
; -----------------------------------------------------------------------------
start:
                call    clear_screen
                call    init_starfield
                call    init_player
                call    init_bullets
                call    init_enemies
                call    init_explosions
                call    draw_starfield
                
game_loop:
                halt                    ; Wait for interrupt (50Hz)
                
                call    update_starfield
                call    read_keyboard
                call    update_player
                call    update_bullets
                call    update_enemies
                call    check_collisions
                call    update_explosions
                
                jr      game_loop

; -----------------------------------------------------------------------------
; Clear Screen
; -----------------------------------------------------------------------------
clear_screen:
                ld      hl, SCREEN_START
                ld      de, SCREEN_START + 1
                ld      bc, 6144 - 1    ; Screen size - 1
                ld      (hl), 0
                ldir                    ; Clear screen
                
                ; Clear attributes
                ld      hl, ATTR_START
                ld      de, ATTR_START + 1
                ld      bc, 768 - 1     ; Attribute size - 1
                ld      (hl), 7         ; Black paper, white ink
                ldir
                ret

; -----------------------------------------------------------------------------
; Initialize Starfield
; -----------------------------------------------------------------------------
init_starfield:
                ld      hl, star_positions
                ld      b, 20           ; Number of stars
                
init_star_loop:
                ; Random Y position (0-23)
                call    random
                and     31              ; 0-31
                cp      24              ; Check if >= 24
                jr      c, star_y_ok
                and     15              ; Limit to 0-15 if too high
star_y_ok:
                ld      (hl), a
                inc     hl
                
                ; Random X position (0-31)
                call    random
                and     31
                ld      (hl), a
                inc     hl
                
                djnz    init_star_loop
                ret

; -----------------------------------------------------------------------------
; Initialize Player
; -----------------------------------------------------------------------------
init_player:
                ld      a, 12           ; Middle of screen
                ld      (player_y), a
                ld      a, 2            ; Left side
                ld      (player_x), a
                xor     a
                ld      (fire_cooldown), a
                ret

; -----------------------------------------------------------------------------
; Initialize Bullets
; -----------------------------------------------------------------------------
init_bullets:
                ld      hl, bullet_active
                ld      b, MAX_BULLETS
                xor     a
init_bullet_loop:
                ld      (hl), a         ; Set inactive
                inc     hl
                ld      (hl), a         ; Clear X
                inc     hl
                ld      (hl), a         ; Clear Y
                inc     hl
                djnz    init_bullet_loop
                ret

; -----------------------------------------------------------------------------
; Initialize Enemies
; -----------------------------------------------------------------------------
init_enemies:
                ld      hl, enemy_active
                ld      b, MAX_ENEMIES
                ld      c, 0            ; Enemy index
                
init_enemy_loop:
                ld      a, 1
                ld      (hl), a         ; Set active
                inc     hl
                
                ; X position - start from right
                ld      a, 30
                sub     c               ; Stagger positions
                sub     c
                ld      (hl), a
                inc     hl
                
                ; Y position - spread vertically
                ld      a, c
                add     a, a            ; * 2
                add     a, a            ; * 4
                add     a, 4            ; Offset from top
                ld      (hl), a
                inc     hl
                
                inc     c
                djnz    init_enemy_loop
                ret

; -----------------------------------------------------------------------------
; Initialize Explosions
; -----------------------------------------------------------------------------
init_explosions:
                ld      hl, explosion_active
                ld      b, MAX_ENEMIES  ; One explosion per enemy
                xor     a
init_expl_loop:
                ld      (hl), a         ; Set inactive
                inc     hl
                inc     hl              ; Skip X
                inc     hl              ; Skip Y
                inc     hl              ; Skip timer
                djnz    init_expl_loop
                ret

; -----------------------------------------------------------------------------
; Draw Initial Starfield
; -----------------------------------------------------------------------------
draw_starfield:
                ld      hl, star_positions
                ld      b, 20
                
draw_star_loop:
                push    bc
                push    hl
                
                ld      a, (hl)         ; Get Y
                inc     hl
                ld      c, (hl)         ; Get X
                
                call    draw_star
                
                pop     hl
                inc     hl
                inc     hl
                pop     bc
                djnz    draw_star_loop
                ret

; -----------------------------------------------------------------------------
; Update Scrolling Starfield
; -----------------------------------------------------------------------------
update_starfield:
                ld      hl, star_positions
                ld      b, 20
                
update_star_loop:
                push    bc
                push    hl
                
                ; Clear old position
                ld      a, (hl)         ; Y
                inc     hl
                ld      c, (hl)         ; X
                push    hl
                call    clear_char
                pop     hl
                
                ; Move star left
                ld      a, (hl)
                dec     a
                jp      p, star_x_ok    ; If positive, still on screen
                ld      a, 31           ; Wrap to right
star_x_ok:
                ld      (hl), a
                ld      c, a
                dec     hl
                ld      a, (hl)         ; Get Y
                
                ; Draw at new position
                call    draw_star
                
                pop     hl
                inc     hl
                inc     hl
                pop     bc
                djnz    update_star_loop
                ret

; -----------------------------------------------------------------------------
; Read Keyboard
; -----------------------------------------------------------------------------
read_keyboard:
                ; Check Q (up)
                ld      bc, 0xfbfe      ; Q-T row
                in      a, (c)
                bit     0, a            ; Q key
                call    z, move_up
                
                ; Check A (down)
                ld      bc, 0xfdfe      ; A-G row
                in      a, (c)
                bit     0, a            ; A key
                call    z, move_down
                
                ; Check SPACE (fire)
                ld      bc, 0x7ffe      ; SPACE-B row
                in      a, (c)
                bit     0, a            ; SPACE key
                call    z, fire_bullet
                
                ; Update cooldown
                ld      a, (fire_cooldown)
                or      a
                ret     z
                dec     a
                ld      (fire_cooldown), a
                ret

; -----------------------------------------------------------------------------
; Movement Subroutines
; -----------------------------------------------------------------------------
move_up:
                ld      a, (player_y)
                or      a
                ret     z               ; At top
                dec     a
                ld      (player_y), a
                ret

move_down:
                ld      a, (player_y)
                cp      23              ; Bottom row
                ret     z               ; At bottom
                inc     a
                ld      (player_y), a
                ret

fire_bullet:
                ld      a, (fire_cooldown)
                or      a
                ret     nz              ; Still cooling down
                
                ; Find inactive bullet
                ld      hl, bullet_active
                ld      b, MAX_BULLETS
                ld      c, 0            ; Bullet index
                
find_bullet:
                ld      a, (hl)
                or      a
                jr      z, found_bullet
                inc     hl
                inc     hl
                inc     hl
                inc     c
                djnz    find_bullet
                ret                     ; No free bullets
                
found_bullet:
                ld      a, 1
                ld      (hl), a         ; Activate bullet
                inc     hl
                
                ; Set position
                ld      a, (player_x)
                add     a, 1            ; Start in front of ship
                ld      (hl), a         ; X
                inc     hl
                ld      a, (player_y)
                ld      (hl), a         ; Y
                
                ; Set cooldown
                ld      a, FIRE_COOLDOWN
                ld      (fire_cooldown), a
                ret

; -----------------------------------------------------------------------------
; Update Player
; -----------------------------------------------------------------------------
update_player:
                ; Clear old position
                ld      a, (old_player_y)
                ld      hl, old_player_x
                ld      c, (hl)
                call    clear_char
                
                ; Draw at new position
                ld      a, (player_y)
                ld      hl, player_x
                ld      c, (hl)
                ld      b, CHAR_PLAYER
                ld      d, CYAN + BRIGHT_BIT
                call    draw_char
                
                ; Update old position
                ld      a, (player_x)
                ld      (old_player_x), a
                ld      a, (player_y)
                ld      (old_player_y), a
                ret

; -----------------------------------------------------------------------------
; Update Bullets
; -----------------------------------------------------------------------------
update_bullets:
                ld      hl, bullet_active
                ld      b, MAX_BULLETS
                
update_bullet_loop:
                push    bc
                push    hl
                
                ld      a, (hl)         ; Check if active
                or      a
                jr      z, next_bullet
                
                inc     hl
                ld      c, (hl)         ; Get X
                inc     hl
                ld      a, (hl)         ; Get Y
                
                ; Clear old position
                push    hl
                call    clear_char
                pop     hl
                
                ; Move bullet right
                dec     hl
                ld      a, (hl)         ; Get X
                add     a, BULLET_SPEED
                cp      32              ; Check right edge
                jr      c, bullet_on_screen
                
                ; Deactivate bullet
                dec     hl
                xor     a
                ld      (hl), a
                jr      next_bullet
                
bullet_on_screen:
                ld      (hl), a         ; Store new X
                ld      c, a
                inc     hl
                ld      a, (hl)         ; Get Y
                
                ; Draw bullet
                ld      b, CHAR_BULLET
                ld      d, YELLOW + BRIGHT_BIT
                call    draw_char
                
next_bullet:
                pop     hl
                inc     hl
                inc     hl
                inc     hl
                pop     bc
                djnz    update_bullet_loop
                ret

; -----------------------------------------------------------------------------
; Update Enemies
; -----------------------------------------------------------------------------
update_enemies:
                ld      hl, enemy_active
                ld      b, MAX_ENEMIES
                
update_enemy_loop:
                push    bc
                push    hl
                
                ld      a, (hl)         ; Check if active
                or      a
                jr      z, next_enemy
                
                inc     hl
                ld      c, (hl)         ; Get X
                inc     hl
                ld      a, (hl)         ; Get Y
                
                ; Clear old position
                push    hl
                call    clear_char
                pop     hl
                
                ; Move enemy left
                dec     hl
                ld      a, (hl)         ; Get X
                sub     ENEMY_SPEED
                jp      m, enemy_off_screen ; If negative, off screen
                
                ld      (hl), a         ; Store new X
                ld      c, a
                inc     hl
                ld      a, (hl)         ; Get Y
                
                ; Draw enemy
                ld      b, CHAR_ENEMY
                ld      d, RED + BRIGHT_BIT
                call    draw_char
                jr      next_enemy
                
enemy_off_screen:
                ; Respawn on right
                ld      a, 31
                ld      (hl), a         ; New X
                
                ; Random Y position
                push    hl
                call    random
                and     15              ; 0-15
                add     a, 4            ; 4-19
                pop     hl
                inc     hl
                ld      (hl), a         ; New Y
                
next_enemy:
                pop     hl
                inc     hl
                inc     hl
                inc     hl
                pop     bc
                djnz    update_enemy_loop
                ret

; -----------------------------------------------------------------------------
; Check Collisions
; -----------------------------------------------------------------------------
check_collisions:
                ; Check each bullet against each enemy
                ld      ix, bullet_active
                ld      b, MAX_BULLETS
                
check_bullet_loop:
                push    bc
                
                ld      a, (ix+0)       ; Check if bullet active
                or      a
                jr      z, check_next_bullet
                
                ; Get bullet position
                ld      d, (ix+1)       ; Bullet X
                ld      e, (ix+2)       ; Bullet Y
                
                ; Check against enemies
                ld      iy, enemy_active
                ld      c, MAX_ENEMIES
                
check_enemy_loop:
                ld      a, (iy+0)       ; Check if enemy active
                or      a
                jr      z, check_next_enemy
                
                ; Check X collision
                ld      a, (iy+1)       ; Enemy X
                sub     d               ; Enemy X - Bullet X
                jr      c, no_x_collision
                cp      2               ; Within 2 chars?
                jr      nc, no_x_collision
                
                ; Check Y collision
                ld      a, (iy+2)       ; Enemy Y
                sub     e               ; Enemy Y - Bullet Y
                jr      c, no_y_collision
                cp      2               ; Within 2 chars?
                jr      nc, no_y_collision
                
                ; Collision detected!
                xor     a
                ld      (ix+0), a       ; Deactivate bullet
                ld      (iy+0), a       ; Deactivate enemy
                
                ; Start explosion
                ld      a, (iy+1)       ; Enemy X
                ld      b, a
                ld      a, (iy+2)       ; Enemy Y
                call    start_explosion
                
                jr      check_next_bullet ; This bullet is done
                
no_x_collision:
no_y_collision:
check_next_enemy:
                ld      de, 3
                add     iy, de          ; Next enemy
                dec     c
                jr      nz, check_enemy_loop
                
check_next_bullet:
                ld      de, 3
                add     ix, de          ; Next bullet
                pop     bc
                djnz    check_bullet_loop
                ret

; -----------------------------------------------------------------------------
; Start Explosion
; Input: B = X, A = Y
; -----------------------------------------------------------------------------
start_explosion:
                push    hl
                push    bc
                push    af
                
                ; Find inactive explosion slot
                ld      hl, explosion_active
                ld      c, MAX_ENEMIES
                
find_explosion:
                ld      a, (hl)
                or      a
                jr      z, found_explosion
                inc     hl
                inc     hl
                inc     hl
                inc     hl
                dec     c
                jr      nz, find_explosion
                
                ; No free slot
                pop     af
                pop     bc
                pop     hl
                ret
                
found_explosion:
                ld      a, EXPLOSION_TIME
                ld      (hl), a         ; Set timer
                inc     hl
                ld      (hl), b         ; Set X
                inc     hl
                pop     af              ; Get Y
                ld      (hl), a         ; Set Y
                
                pop     bc
                pop     hl
                ret

; -----------------------------------------------------------------------------
; Update Explosions
; -----------------------------------------------------------------------------
update_explosions:
                ld      hl, explosion_active
                ld      b, MAX_ENEMIES
                
update_expl_loop:
                push    bc
                push    hl
                
                ld      a, (hl)         ; Get timer
                or      a
                jr      z, next_explosion
                
                ; Get position
                inc     hl
                ld      c, (hl)         ; X
                inc     hl
                ld      a, (hl)         ; Y
                
                ; Clear old explosion
                push    hl
                call    clear_char
                pop     hl
                
                ; Decrement timer
                dec     hl
                dec     hl
                ld      a, (hl)
                dec     a
                ld      (hl), a
                jr      z, next_explosion ; Explosion finished
                
                ; Draw explosion frame
                inc     hl
                ld      c, (hl)         ; X
                inc     hl
                ld      a, (hl)         ; Y
                ld      b, CHAR_EXPLOSION
                
                ; Cycle colors based on timer
                dec     hl
                dec     hl
                ld      a, (hl)         ; Timer
                and     3
                add     a, YELLOW
                or      BRIGHT_BIT
                ld      d, a
                
                inc     hl
                ld      c, (hl)         ; X
                inc     hl
                ld      a, (hl)         ; Y
                call    draw_char
                
next_explosion:
                pop     hl
                inc     hl
                inc     hl
                inc     hl
                inc     hl
                pop     bc
                djnz    update_expl_loop
                ret

; -----------------------------------------------------------------------------
; Character Drawing Routines
; -----------------------------------------------------------------------------

; Draw character at position
; Input: A = Y, C = X, B = char, D = attr
draw_char:
                push    af
                push    bc
                push    de
                push    hl
                
                ; Calculate screen address
                call    calc_screen_addr
                ld      (hl), b         ; Draw character
                
                ; Calculate attribute address
                pop     hl
                pop     de
                push    de
                push    hl
                call    calc_attr_addr
                ld      (hl), d         ; Set attribute
                
                pop     hl
                pop     de
                pop     bc
                pop     af
                ret

; Clear character at position
; Input: A = Y, C = X
clear_char:
                push    af
                push    bc
                push    hl
                
                call    calc_screen_addr
                ld      (hl), CHAR_SPACE
                
                pop     hl
                pop     bc
                pop     af
                ret

; Draw star at position
; Input: A = Y, C = X
draw_star:
                push    de
                ld      b, CHAR_STAR
                ld      d, WHITE        ; Dim white star
                call    draw_char
                pop     de
                ret

; Calculate screen address
; Input: A = Y, C = X
; Output: HL = screen address
calc_screen_addr:
                push    af
                push    bc
                push    de
                
                ld      l, a            ; Y to L
                ld      h, 0
                add     hl, hl          ; Y * 2
                add     hl, hl          ; Y * 4
                add     hl, hl          ; Y * 8
                add     hl, hl          ; Y * 16
                add     hl, hl          ; Y * 32
                
                ld      b, 0
                add     hl, bc          ; Add X
                
                ld      bc, SCREEN_START
                add     hl, bc
                
                pop     de
                pop     bc
                pop     af
                ret

; Calculate attribute address
; Input: A = Y, C = X
; Output: HL = attribute address
calc_attr_addr:
                push    af
                push    bc
                push    de
                
                ld      l, a            ; Y to L
                ld      h, 0
                add     hl, hl          ; Y * 2
                add     hl, hl          ; Y * 4
                add     hl, hl          ; Y * 8
                add     hl, hl          ; Y * 16
                add     hl, hl          ; Y * 32
                
                ld      b, 0
                add     hl, bc          ; Add X
                
                ld      bc, ATTR_START
                add     hl, bc
                
                pop     de
                pop     bc
                pop     af
                ret

; -----------------------------------------------------------------------------
; Random Number Generator
; -----------------------------------------------------------------------------
random:
                push    hl
                ld      hl, (random_seed)
                ld      a, h
                rrca
                rrca
                rrca
                xor     $1f
                add     a, l
                ld      l, a
                ld      a, h
                rrca
                xor     l
                ld      h, a
                ld      (random_seed), hl
                pop     hl
                ret

; -----------------------------------------------------------------------------
; Data Section
; -----------------------------------------------------------------------------

; Player data
player_x:       db      2
player_y:       db      12
old_player_x:   db      2
old_player_y:   db      12
fire_cooldown:  db      0

; Star data (Y, X pairs)
star_positions:
                ds      40              ; 20 stars * 2 bytes

; Bullet data (active, x, y)
bullet_active:  ds      MAX_BULLETS * 3

; Enemy data (active, x, y)
enemy_active:   ds      MAX_ENEMIES * 3

; Explosion data (timer, x, y, unused)
explosion_active: ds    MAX_ENEMIES * 4

; Random seed
random_seed:    dw      12345

; TAP file creation
                savetap "quantum-shatter-04.tap", start

                end     start