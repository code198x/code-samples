;
; Shadowkeep Unit 8, Stage 3 — Title to Game
;
; Stage 2 played the title theme forever. This stage gives the player a
; way in: SPACE breaks the music loop and starts the game.
;
; The trick is that the music driver is CPU-blocking — while a note is
; playing the CPU is in the play_note inner loop, deaf to the keyboard.
; We poll SPACE *between* notes, in the play_theme dispatcher. Worst-case
; response latency is one note duration (~500ms for a quarter); typical
; latency is much less. For a title-screen "press any key" gate that's
; fine.
;
; The gameplay is Unit 6's locked-until-cleared verbatim. Game ends with
; the existing victory halt-loop; Stage 4 will route victory back to
; the title.
;

            org     32768

; --- Game constants (Unit 6 verbatim) ---
WALL        equ     $48
FLOOR       equ     $08
GOLD        equ     $70
DOOR_OPEN   equ     $28
EXIT        equ     $20
HERO_ATTR   equ     $3A
STONE       equ     $08

KBD_Q       equ     $FBFE
KBD_A       equ     $FDFE
KBD_P       equ     $DFFE
KBD_SPACE   equ     $7FFE               ; SPACE on bit 0

HERO_START_COL equ  16
HERO_START_ROW equ  10
START_ROOM     equ  0

MOVE_INTERVAL  equ  6
TOTAL_GOLD     equ  15

; --- Title constants ---
TITLE_ROW   equ     6
TITLE_COL   equ     11
TITLE_LEN   equ     10
TITLE_ATTR  equ     $07
PROMPT_ROW  equ     15
PROMPT_COL  equ     6
PROMPT_LEN  equ     20
PROMPT_ATTR equ     $05                 ; INK 5 (cyan), PAPER 0

ROM_FONT    equ     $3D00
SPEAKER     equ     $10

start:
            im      1
            ei
            xor     a
            out     ($FE), a

            call    clear_to_black
            call    draw_title
            call    draw_prompt

            ; Play title music — returns when SPACE is pressed.
            call    play_theme

            ; Transition to game.
            call    init_game
            jp      main_loop

; ----------------------------------------------------------------------------
; init_game: reset game state and render the starting room with the hero.
; ----------------------------------------------------------------------------

init_game:
            call    clear_to_stone

            ld      a, START_ROOM
            ld      (current_room), a
            call    draw_current_room

            xor     a
            ld      (gold_taken), a

            ld      a, HERO_START_COL
            ld      (hero_col), a
            ld      a, HERO_START_ROW
            ld      (hero_row), a
            xor     a
            ld      (move_tick), a

            call    save_under_hero
            call    draw_hero
            ret

; ============================================================================
; Title-screen presentation
; ============================================================================

clear_to_black:
            ld      hl, $4000
            ld      de, $4001
            ld      (hl), 0
            ld      bc, 6143
            ldir
            ld      hl, $5800
            ld      de, $5801
            ld      (hl), 0
            ld      bc, 767
            ldir
            ret

draw_title:
            ld      hl, $5800 + TITLE_ROW * 32 + TITLE_COL
            ld      b, TITLE_LEN
.tfa:
            ld      (hl), TITLE_ATTR
            inc     hl
            djnz    .tfa

            ld      hl, title_text
            ld      d, TITLE_ROW
            ld      e, TITLE_COL
            jp      draw_string

draw_prompt:
            ld      hl, $5800 + PROMPT_ROW * 32 + PROMPT_COL
            ld      b, PROMPT_LEN
.pfa:
            ld      (hl), PROMPT_ATTR
            inc     hl
            djnz    .pfa

            ld      hl, prompt_text
            ld      d, PROMPT_ROW
            ld      e, PROMPT_COL
            jp      draw_string

draw_string:
            ld      a, (hl)
            or      a
            ret     z
            push    hl
            call    draw_char
            pop     hl
            inc     hl
            inc     e
            jr      draw_string

draw_char:
            push    de
            sub     32
            ld      l, a
            ld      h, 0
            add     hl, hl
            add     hl, hl
            add     hl, hl
            ld      bc, ROM_FONT
            add     hl, bc

            push    hl
            ld      a, d
            and     $18
            or      $40
            ld      h, a
            ld      a, d
            and     $07
            rrca
            rrca
            rrca
            or      e
            ld      l, a
            ex      de, hl
            pop     hl

            ld      b, 8
.line:
            ld      a, (hl)
            ld      (de), a
            inc     hl
            inc     d
            djnz    .line

            pop     de
            ret

; ============================================================================
; Beeper driver with SPACE check between notes.
; ============================================================================

play_theme:
            ld      hl, melody
.next_note:
            ; Check for SPACE — return immediately if pressed.
            ld      bc, KBD_SPACE
            in      a, (c)
            bit     0, a
            ret     z                   ; SPACE down → exit music

            ld      a, (hl)
            cp      $FF
            jr      z, play_theme       ; end of melody — loop
            inc     hl
            ld      c, (hl)
            inc     hl

            cp      $00
            jr      z, .play_rest

            push    hl
            ld      d, 0
            ld      e, c
            sla     e
            rl      d
            sla     e
            rl      d
            call    play_note
            pop     hl
            jr      .next_note

.play_rest:
            push    hl
            xor     a
            out     ($FE), a
            ld      b, c
.rest_outer:
            ld      a, 150
.rest_inner:
            dec     a
            jr      nz, .rest_inner
            djnz    .rest_outer
            pop     hl
            jr      .next_note

play_note:
            ld      h, a
.cycle:
            ld      a, SPEAKER
            out     ($FE), a
            ld      b, h
.h_up:      djnz    .h_up
            xor     a
            out     ($FE), a
            ld      b, h
.h_dn:      djnz    .h_dn
            dec     de
            ld      a, d
            or      e
            jr      nz, .cycle
            ret

; ============================================================================
; Gameplay (Unit 6 verbatim).
; ============================================================================

main_loop:
            halt
            ld      a, (move_tick)
            inc     a
            ld      (move_tick), a
            cp      MOVE_INTERVAL
            jr      c, main_loop
            xor     a
            ld      (move_tick), a

            ld      bc, KBD_Q
            in      a, (c)
            bit     0, a
            jr      z, .try_up
            ld      bc, KBD_A
            in      a, (c)
            bit     0, a
            jr      z, .try_down
            ld      bc, KBD_P
            in      a, (c)
            ld      d, a
            bit     1, a
            jr      z, .try_left
            bit     0, d
            jr      z, .try_right
            jr      main_loop

.try_up:    ld      b, 0
            ld      c, $FF
            call    try_move
            jr      main_loop
.try_down:  ld      b, 0
            ld      c, 1
            call    try_move
            jr      main_loop
.try_left:  ld      b, $FF
            ld      c, 0
            call    try_move
            jr      main_loop
.try_right: ld      b, 1
            ld      c, 0
            call    try_move
            jr      main_loop

victory:
            ld      a, 4                ; green
            out     ($FE), a
.idle:
            halt
            jr      .idle

clear_to_stone:
            ld      hl, $4000
            ld      de, $4001
            ld      (hl), 0
            ld      bc, 6143
            ldir
            ld      hl, $5800
            ld      de, $5801
            ld      (hl), STONE
            ld      bc, 767
            ldir
            ret

draw_current_room:
            ld      a, (current_room)
            add     a, a
            ld      e, a
            ld      d, 0
            ld      hl, room_table
            add     hl, de
            ld      a, (hl)
            inc     hl
            ld      h, (hl)
            ld      l, a
            ld      (room_data_ptr), hl

            ld      hl, (room_data_ptr)
            ld      de, $5845
            ld      b, 16
.r1:        push    bc
            ld      b, 22
.c1:        ld      a, (hl)
            ld      (de), a
            inc     hl
            inc     de
            djnz    .c1
            ld      a, e
            add     a, 32 - 22
            ld      e, a
            jr      nc, .nc1
            inc     d
.nc1:       pop     bc
            djnz    .r1

            ld      hl, (room_data_ptr)
            ld      iy, bitmap_rows
            ld      b, 16
.r2:        push    bc
            ld      e, (iy+0)
            ld      d, (iy+1)
            inc     iy
            inc     iy
            ld      b, 22
.c2:        ld      a, (hl)
            cp      WALL
            jr      nz, .nw
            push    hl
            push    de
            push    bc
            ex      de, hl
            call    draw_stone
            pop     bc
            pop     de
            pop     hl
.nw:        inc     hl
            inc     de
            djnz    .c2
            pop     bc
            djnz    .r2
            ret

try_move:
            ld      a, (hero_col)
            add     a, b
            ld      (target_col), a
            ld      a, (hero_row)
            add     a, c
            ld      (target_row), a

            ld      a, (target_col)
            ld      b, a
            ld      a, (target_row)
            ld      c, a
            call    get_attr_addr_bc
            ld      a, (hl)
            ld      (target_attr), a

            cp      DOOR_OPEN
            jr      z, .door
            cp      FLOOR
            jr      z, .walk
            cp      GOLD
            jr      z, .walk
            cp      EXIT
            jr      z, .walk
            ret

.walk:
            call    restore_under_hero
            ld      a, (target_col)
            ld      (hero_col), a
            ld      a, (target_row)
            ld      (hero_row), a
            call    save_under_hero

            ld      a, (target_attr)
            cp      GOLD
            jr      z, .pickup_gold
            cp      EXIT
            jr      z, .exit_step
            jr      .finish

.pickup_gold:
            ld      a, FLOOR
            ld      (player_under_attr), a
            ld      a, (gold_taken)
            inc     a
            ld      (gold_taken), a
            call    cell_addr_in_room_data
            ld      a, FLOOR
            ld      (hl), a
            jr      .finish

.exit_step:
            ld      a, (gold_taken)
            cp      TOTAL_GOLD
            jr      z, .victory_now

            ld      a, 2
            out     ($FE), a
            ld      b, 5
.flash:     halt
            djnz    .flash
            ld      a, 0
            out     ($FE), a
            jr      .finish

.victory_now:
            call    draw_hero
            jp      victory

.finish:
            call    draw_hero
            ret

.door:
            jp      do_transition

cell_addr_in_room_data:
            ld      hl, 0
            ld      a, (target_row)
            sub     2
            or      a
            jr      z, .skip_rows
            ld      b, a
            ld      de, 22
.acc:       add     hl, de
            djnz    .acc
.skip_rows:
            ld      a, (target_col)
            sub     5
            add     a, l
            ld      l, a
            jr      nc, .nc
            inc     h
.nc:
            ld      de, (room_data_ptr)
            add     hl, de
            ret

do_transition:
            ld      a, (current_room)
            xor     1
            ld      (current_room), a
            or      a
            jr      nz, .into_antechamber
            ld      a, 25
            ld      (hero_col), a
            ld      a, 10
            ld      (hero_row), a
            jr      .render
.into_antechamber:
            ld      a, 6
            ld      (hero_col), a
            ld      a, 10
            ld      (hero_row), a
.render:
            call    clear_to_stone
            call    draw_current_room
            call    save_under_hero
            call    draw_hero
            ret

get_attr_addr_bc:
            ld      a, b
            ld      hl, 0
            ld      a, c
            ld      h, 0
            ld      l, a
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            ld      a, b
            ld      e, a
            ld      d, 0
            add     hl, de
            ld      de, $5800
            add     hl, de
            ret

get_bitmap_addr_bc:
            ld      a, c
            and     $18
            or      $40
            ld      h, a
            ld      a, c
            and     $07
            rrca
            rrca
            rrca
            or      b
            ld      l, a
            ret

save_under_hero:
            ld      a, (hero_col)
            ld      b, a
            ld      a, (hero_row)
            ld      c, a
            call    get_attr_addr_bc
            ld      a, (hl)
            ld      (player_under_attr), a

            ld      a, (hero_col)
            ld      b, a
            ld      a, (hero_row)
            ld      c, a
            call    get_bitmap_addr_bc
            ld      de, player_under_bitmap
            ld      b, 8
.sl:        ld      a, (hl)
            ld      (de), a
            inc     h
            inc     de
            djnz    .sl
            ret

restore_under_hero:
            ld      a, (hero_col)
            ld      b, a
            ld      a, (hero_row)
            ld      c, a
            call    get_attr_addr_bc
            ld      a, (player_under_attr)
            ld      (hl), a

            ld      a, (hero_col)
            ld      b, a
            ld      a, (hero_row)
            ld      c, a
            call    get_bitmap_addr_bc
            ld      de, player_under_bitmap
            ld      b, 8
.rl:        ld      a, (de)
            ld      (hl), a
            inc     h
            inc     de
            djnz    .rl
            ret

draw_hero:
            ld      a, (hero_col)
            ld      b, a
            ld      a, (hero_row)
            ld      c, a
            call    get_attr_addr_bc
            ld      (hl), HERO_ATTR

            ld      a, (hero_col)
            ld      b, a
            ld      a, (hero_row)
            ld      c, a
            call    get_bitmap_addr_bc
            ld      de, hero
            ld      b, 8
.dh:        ld      a, (de)
            ld      (hl), a
            inc     h
            inc     de
            djnz    .dh
            ret

draw_stone:
            ld      de, stone_block
            ld      b, 8
.ds:        ld      a, (de)
            ld      (hl), a
            inc     h
            inc     de
            djnz    .ds
            ret

stone_block:
            defb    %11111111, %10000001, %10000001, %10000001
            defb    %10000001, %10000001, %10000001, %11111111

hero:
            defb    %00011000, %00111100, %01111110, %01111110
            defb    %00111100, %00111100, %01100110, %01100110

bitmap_rows:
            defw    $4045, $4065, $4085, $40A5, $40C5, $40E5, $4805, $4825
            defw    $4845, $4865, $4885, $48A5, $48C5, $48E5, $5005, $5025

; ============================================================================
; Text and music data
; ============================================================================

title_text:   defm    "SHADOWKEEP", 0
prompt_text:  defm    "PRESS SPACE TO BEGIN", 0      ; 20 chars actually

melody:
            defb    227, 64
            defb    191, 64
            defb    151, 64
            defb    112, 128
            defb    126, 64
            defb    151, 64
            defb    191, 64
            defb    202, 64
            defb    227, 128
            defb    $00, 32
            defb    227, 255
            defb    $FF

; ============================================================================
; Game state (RAM-backed; values set by init_game).
; ============================================================================

room_table:
            defw    room_data_great_hall
            defw    room_data_antechamber

current_room:       defb 0
hero_col:           defb 0
hero_row:           defb 0
target_col:         defb 0
target_row:         defb 0
target_attr:        defb 0
move_tick:          defb 0
gold_taken:         defb 0
room_data_ptr:      defw 0
player_under_attr:  defb 0
player_under_bitmap:
            defb 0, 0, 0, 0, 0, 0, 0, 0

room_data_great_hall:
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            defb    WALL, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    GOLD, GOLD, GOLD, WALL, WALL, WALL, GOLD, GOLD, GOLD
            defb    FLOOR, FLOOR, FLOOR, FLOOR, WALL
            defb    WALL, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    GOLD, GOLD, WALL, WALL, WALL, GOLD, GOLD
            defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, WALL
            defb    WALL, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    GOLD, WALL, GOLD, WALL, GOLD, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, WALL
            defb    WALL, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    WALL, FLOOR, WALL, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, WALL
            rept 3
                defb    WALL, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    FLOOR, WALL
            endm
            defb    WALL, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    FLOOR, DOOR_OPEN
            rept 6
                defb    WALL, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    FLOOR, WALL
            endm
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL

room_data_antechamber:
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            defb    WALL
            defb    FLOOR, FLOOR, FLOOR, GOLD
            defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    GOLD, FLOOR, FLOOR, FLOOR
            defb    WALL
            rept 2
                defb    WALL
                defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    WALL
            endm
            rept 4
                defb    WALL
                defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    WALL
                defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    WALL
                defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    WALL
            endm
            defb    DOOR_OPEN
            defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
            defb    EXIT
            rept 6
                defb    WALL
                defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR, FLOOR
                defb    WALL
            endm
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL
            defb    WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL

            end     start
