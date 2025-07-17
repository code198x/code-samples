; quantum-shatter-02.asm
; Lesson 2: Adding the Player Ship
; Add controllable player ship to Quantum Shatter

        DEVICE ZXSPECTRUM48     ; Target device

        ORG     $8000           ; Start at address 32768

; System constants
ATTRS   EQU     $5800           ; Attribute memory
BORDCR  EQU     $5C48           ; Border color system variable

; Player ship constants
SHIP_CHAR   EQU     $80         ; Custom character for ship
SHIP_START_X EQU    15          ; Starting X position (middle of screen)
SHIP_START_Y EQU    20          ; Starting Y position (near bottom)
SHIP_MIN_X  EQU     1           ; Minimum X position
SHIP_MAX_X  EQU     30          ; Maximum X position
SHIP_MIN_Y  EQU     1           ; Minimum Y position
SHIP_MAX_Y  EQU     22          ; Maximum Y position

; Entry point
start:
        di                      ; Disable interrupts
        
        ; Set border to black
        xor     a               ; A = 0 (black)
        out     ($FE),a         ; Set border color
        ld      (BORDCR),a      ; Update system variable
        
        ; Set up our game world
        call    clear_screen
        call    create_starfield
        call    create_ship_character
        call    init_player
        
        ; Main game loop
game_loop:
        halt                    ; Wait for interrupt (50Hz)
        call    animate_stars
        call    handle_input
        call    update_player
        jr      game_loop

; Variables
frame_counter:  DB 0
color_index:    DB 0
player_x:       DB SHIP_START_X
player_y:       DB SHIP_START_Y
old_player_x:   DB SHIP_START_X
old_player_y:   DB SHIP_START_Y

;----------------------------------------------------------------
; Clear screen
;----------------------------------------------------------------
clear_screen:
        ; Clear display file
        ld      hl,$4000        ; Screen start
        ld      de,$4001
        ld      bc,$17FF        ; Screen size - 1
        ld      (hl),0          ; Clear first byte
        ldir                    ; Fill rest
        
        ; Clear attributes to black on black
        ld      hl,ATTRS
        ld      de,ATTRS+1
        ld      bc,767          ; 768 - 1
        ld      (hl),0          ; Black paper, black ink
        ldir
        
        ret

;----------------------------------------------------------------
; Create starfield
;----------------------------------------------------------------
create_starfield:
        ; Place stars by setting individual pixels
        
        ; Star 1
        ld      hl,$4020        ; Screen position
        ld      a,%10000000     ; Leftmost pixel
        ld      (hl),a
        
        ; Star 2
        ld      hl,$4048
        ld      a,%00100000     ; Different pixel position
        ld      (hl),a
        
        ; Star 3
        ld      hl,$4070
        ld      a,%00001000
        ld      (hl),a
        
        ; Star 4
        ld      hl,$4098
        ld      a,%01000000
        ld      (hl),a
        
        ; Star 5
        ld      hl,$40C0
        ld      a,%00000100
        ld      (hl),a
        
        ; Star 6
        ld      hl,$40E8
        ld      a,%00010000
        ld      (hl),a
        
        ; Star 7
        ld      hl,$4110
        ld      a,%00000001
        ld      (hl),a
        
        ; Star 8
        ld      hl,$4138
        ld      a,%10000000
        ld      (hl),a
        
        ; Star 9
        ld      hl,$4160
        ld      a,%00000010
        ld      (hl),a
        
        ; Star 10
        ld      hl,$4188
        ld      a,%01000000
        ld      (hl),a
        
        ; Set star colors (white on black)
        ld      a,$07           ; White ink, black paper
        ld      hl,ATTRS+33     ; Attribute positions
        ld      (hl),a
        ld      hl,ATTRS+72
        ld      (hl),a
        ld      hl,ATTRS+112
        ld      (hl),a
        ld      hl,ATTRS+152
        ld      (hl),a
        ld      hl,ATTRS+192
        ld      (hl),a
        ld      hl,ATTRS+232
        ld      (hl),a
        ld      hl,ATTRS+272
        ld      (hl),a
        ld      hl,ATTRS+312
        ld      (hl),a
        ld      hl,ATTRS+352
        ld      (hl),a
        ld      hl,ATTRS+392
        ld      (hl),a
        
        ret

;----------------------------------------------------------------
; Create custom character for ship
;----------------------------------------------------------------
create_ship_character:
        ; Define ship character data (8x8 pixels)
        ; This creates a simple ship sprite
        ld      hl,ship_data
        ld      de,$4000 + (SHIP_CHAR * 8) ; Character location
        ld      bc,8            ; 8 bytes per character
        ldir                    ; Copy ship data
        
        ret

ship_data:
        ; Ship character bitmap (8x8 pixels)
        ; Simple ship design - triangle with engines
        DB      %00010000       ; Row 0:    *
        DB      %00111000       ; Row 1:   ***
        DB      %01111100       ; Row 2:  *****
        DB      %11111110       ; Row 3: *******
        DB      %01111100       ; Row 4:  *****
        DB      %00111000       ; Row 5:   ***
        DB      %01000010       ; Row 6:  *   *  (engines)
        DB      %10000001       ; Row 7: *     * (engine flames)

;----------------------------------------------------------------
; Initialize player
;----------------------------------------------------------------
init_player:
        ; Set starting position
        ld      a,SHIP_START_X
        ld      (player_x),a
        ld      (old_player_x),a
        
        ld      a,SHIP_START_Y
        ld      (player_y),a
        ld      (old_player_y),a
        
        ; Draw initial ship
        call    draw_player
        
        ret

;----------------------------------------------------------------
; Handle keyboard input
;----------------------------------------------------------------
handle_input:
        ; Check Q key (Up)
        ld      bc,$FEFE        ; Row 0
        in      a,(c)
        bit     4,a             ; Q key
        jr      nz,check_a
        
        ; Move up
        ld      a,(player_y)
        cp      SHIP_MIN_Y
        jr      z,check_a       ; At top boundary
        dec     a
        ld      (player_y),a
        
check_a:
        ; Check A key (Down)
        ld      bc,$FDFE        ; Row 1
        in      a,(c)
        bit     0,a             ; A key
        jr      nz,check_o
        
        ; Move down
        ld      a,(player_y)
        cp      SHIP_MAX_Y
        jr      z,check_o       ; At bottom boundary
        inc     a
        ld      (player_y),a
        
check_o:
        ; Check O key (Left)
        ld      bc,$DFFE        ; Row 4
        in      a,(c)
        bit     1,a             ; O key
        jr      nz,check_p
        
        ; Move left
        ld      a,(player_x)
        cp      SHIP_MIN_X
        jr      z,check_p       ; At left boundary
        dec     a
        ld      (player_x),a
        
check_p:
        ; Check P key (Right)
        ld      bc,$DFFE        ; Row 4
        in      a,(c)
        bit     0,a             ; P key
        jr      nz,input_done
        
        ; Move right
        ld      a,(player_x)
        cp      SHIP_MAX_X
        jr      z,input_done    ; At right boundary
        inc     a
        ld      (player_x),a
        
input_done:
        ret

;----------------------------------------------------------------
; Update player display
;----------------------------------------------------------------
update_player:
        ; Check if player moved
        ld      a,(player_x)
        ld      b,a
        ld      a,(old_player_x)
        cp      b
        jr      nz,player_moved
        
        ld      a,(player_y)
        ld      b,a
        ld      a,(old_player_y)
        cp      b
        jr      z,no_movement
        
player_moved:
        ; Erase old position
        call    erase_player
        
        ; Update old position
        ld      a,(player_x)
        ld      (old_player_x),a
        ld      a,(player_y)
        ld      (old_player_y),a
        
        ; Draw new position
        call    draw_player
        
no_movement:
        ret

;----------------------------------------------------------------
; Draw player ship
;----------------------------------------------------------------
draw_player:
        ; Calculate screen position
        ld      a,(player_y)
        ld      h,a
        ld      a,(player_x)
        ld      l,a
        call    calc_screen_pos
        
        ; Draw ship character
        ld      a,SHIP_CHAR
        ld      (hl),a
        
        ; Set ship color (cyan on black)
        call    calc_attr_pos
        ld      a,$05           ; Cyan ink, black paper
        ld      (hl),a
        
        ret

;----------------------------------------------------------------
; Erase player ship
;----------------------------------------------------------------
erase_player:
        ; Calculate old screen position
        ld      a,(old_player_y)
        ld      h,a
        ld      a,(old_player_x)
        ld      l,a
        call    calc_screen_pos
        
        ; Erase ship character
        ld      a,0
        ld      (hl),a
        
        ; Reset color
        call    calc_attr_pos
        ld      a,0             ; Black ink, black paper
        ld      (hl),a
        
        ret

;----------------------------------------------------------------
; Calculate screen position from X,Y coordinates
; Input: H = Y, L = X
; Output: HL = screen address
;----------------------------------------------------------------
calc_screen_pos:
        ; Convert Y,X to screen address
        ; Screen starts at $4000
        ; Each row is 32 bytes
        push    de
        
        ld      a,h             ; Y coordinate
        ld      h,0
        ld      d,h
        ld      e,a
        ; DE = Y
        
        ; Multiply Y by 32 (shift left 5 times)
        sla     e
        rl      d
        sla     e
        rl      d
        sla     e
        rl      d
        sla     e
        rl      d
        sla     e
        rl      d
        
        ; Add X coordinate
        ld      a,l             ; X coordinate
        add     a,e
        ld      e,a
        jr      nc,no_carry
        inc     d
no_carry:
        
        ; Add screen base address
        ld      hl,$4000
        add     hl,de
        
        pop     de
        ret

;----------------------------------------------------------------
; Calculate attribute position from X,Y coordinates
; Input: H = Y, L = X
; Output: HL = attribute address
;----------------------------------------------------------------
calc_attr_pos:
        ; Convert Y,X to attribute address
        ; Attributes start at $5800
        ; Each row is 32 bytes
        push    de
        
        ld      a,h             ; Y coordinate
        ld      h,0
        ld      d,h
        ld      e,a
        ; DE = Y
        
        ; Multiply Y by 32 (shift left 5 times)
        sla     e
        rl      d
        sla     e
        rl      d
        sla     e
        rl      d
        sla     e
        rl      d
        sla     e
        rl      d
        
        ; Add X coordinate
        ld      a,l             ; X coordinate
        add     a,e
        ld      e,a
        jr      nc,no_carry2
        inc     d
no_carry2:
        
        ; Add attribute base address
        ld      hl,ATTRS
        add     hl,de
        
        pop     de
        ret

;----------------------------------------------------------------
; Animate stars (from lesson 1)
;----------------------------------------------------------------
animate_stars:
        ; Increment frame counter
        ld      a,(frame_counter)
        inc     a
        and     15              ; Every 16 frames
        ld      (frame_counter),a
        ret     nz              ; Only update every 16th frame
        
        ; Cycle through star colors
        call    update_star_colors
        ret

update_star_colors:
        ; Get current color index
        ld      a,(color_index)
        inc     a
        and     3               ; Keep in range 0-3
        ld      (color_index),a
        
        ; Select color based on index
        cp      0
        jr      z,use_white
        cp      1
        jr      z,use_bright_white
        cp      2
        jr      z,use_cyan
        
        ; Use yellow for variety
        ld      e,$46           ; Bright yellow on black
        jr      apply_colors
        
use_white:
        ld      e,$07           ; White on black
        jr      apply_colors
        
use_bright_white:
        ld      e,$47           ; Bright white on black
        jr      apply_colors
        
use_cyan:
        ld      e,$45           ; Bright cyan on black
        
apply_colors:
        ; Update all star attributes
        ld      hl,ATTRS+33
        ld      (hl),e
        ld      hl,ATTRS+72
        ld      (hl),e
        ld      hl,ATTRS+112
        ld      (hl),e
        ld      hl,ATTRS+152
        ld      (hl),e
        ld      hl,ATTRS+192
        ld      (hl),e
        ld      hl,ATTRS+232
        ld      (hl),e
        ld      hl,ATTRS+272
        ld      (hl),e
        ld      hl,ATTRS+312
        ld      (hl),e
        ld      hl,ATTRS+352
        ld      (hl),e
        ld      hl,ATTRS+392
        ld      (hl),e
        ret

program_end:

; Create TAP file
        EMPTYTAP "build/quantum-shatter-02.tap"
        SAVETAP "build/quantum-shatter-02.tap", BASIC, "loader", 10, 1, 10
        SAVETAP "build/quantum-shatter-02.tap", CODE, "quantum", start, program_end-start, start