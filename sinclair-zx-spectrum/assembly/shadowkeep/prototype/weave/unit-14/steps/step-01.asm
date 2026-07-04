; Shadowkeep — Unit 14: Furnishings
; Cumulative build; every step runs on its own. Narrative: the unit page.
; step-01 dresses the rooms — a statue, banners, rubble — scenery that makes a place.

            org     32768

WALL_ATTR   equ     %01001000
FLOOR_ATTR  equ     %00001000
MARK_ATTR   equ     %00001111
TORCH_ATTR  equ     %01001110         ; BRIGHT, blue paper, yellow ink — a lit sconce
STATUE_ATTR equ     %01001111         ; BRIGHT white on blue — pale stone (solid)
BANNER_ATTR equ     %01001011         ; BRIGHT magenta on blue — a hanging (solid)
RUBBLE_ATTR equ     %00001000         ; dim, like floor — walkable broken stone
NO_TORCH    equ     $FF
MAX_SHADE   equ     4
THIEF       equ     %01001010
GOLD_ATTR   equ     %00000110         ; yellow ink, no BRIGHT -> walkable gold
TOTAL_GOLD  equ     6
WARDEN      equ     %01000101         ; BRIGHT cyan on black — the sentinel
WARDEN_COL0 equ     26                ; the Hall's gold column
WARDEN_ROW0 equ     11
WARDEN_SPEED equ    10                ; frames between patrol steps
WARDEN_GATHER equ   50                ; a beat before it begins to move
AXIS_HORIZ  equ     0                 ; the Warden varies its column (walks a row)
AXIS_VERT   equ     1                 ; the Warden varies its row (walks a column)
WALL_BIT    equ     6

START_COL   equ     15
START_ROW   equ     11
NO_EXIT     equ     $FF

KEYS_OP     equ     $DFFE
KEYS_Q      equ     $FBFE
KEYS_A      equ     $FDFE
KEYS_SPACE  equ     $7FFE

start:
            ld      a, 0
            out     ($FE), a
            im      1

; --- TITLE -> PLAY -> WIN -> TITLE ------------------------------------------
main_title:
            call    show_title       ; returns (interrupts off) when SPACE pressed
            call    new_game         ; reset the keep, place the gold, draw
            ei
.game_loop:
            halt
            ld      a, (won)
            or      a
            jr      nz, .won
            call    player_step
            call    warden_step      ; every room has its Warden now
            ld      a, (caught)
            or      a
            jr      nz, .lost
            call    mark_step
            jr      .game_loop
.lost:
            call    show_lose        ; "THE KEEP SLEEPS", the sting, wait for SPACE
            jr      main_title
.won:
            call    show_win         ; "THE KEEP STANDS", flourish, wait for SPACE
            jr      main_title       ; round again

; new_game — copy the room templates back into working state (so collected gold
; returns), reset the thief, the gold counter and the win flag, draw the keep.
new_game:
            ld      hl, room0_template
            ld      de, room0_state
            ld      bc, 768
            ldir
            ld      hl, room1_template
            ld      de, room1_state
            ld      bc, 768
            ldir
            ld      hl, room2_template
            ld      de, room2_state
            ld      bc, 768
            ldir

            xor     a
            ld      (current_room), a
            ld      (won), a
            ld      (caught), a
            ld      a, TOTAL_GOLD
            ld      (gold_remaining), a
            ld      a, START_COL
            ld      (thief_col), a
            ld      a, START_ROW
            ld      (thief_row), a

            call    draw_room
            call    save_under
            call    draw_thief
            call    warden_enter     ; this room's Warden, from the table
            call    save_warden
            call    draw_warden
            ret

mark_step:
            ld      bc, KEYS_SPACE
            in      a, (c)
            bit     0, a
            ret     nz
            call    cell_state_addr
            ld      (hl), '+'
            ld      hl, mark_tile
            ld      de, under_thief
            ld      bc, 8
            ldir
            ld      a, MARK_ATTR
            ld      (under_thief + 8), a
            ret

cell_state_addr:
            call    room_entry_addr
            ld      a, (hl)
            inc     hl
            ld      h, (hl)
            ld      l, a
            push    hl
            ld      a, (thief_row)
            ld      l, a
            ld      h, 0
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            ld      a, (thief_col)
            ld      e, a
            ld      d, 0
            add     hl, de
            pop     de
            add     hl, de
            ret

room_entry_addr:
            ld      a, (current_room)
            ld      l, a
            ld      h, 0
            ld      d, h
            ld      e, l
            add     hl, hl
            add     hl, de
            add     hl, hl
            ld      de, rooms
            add     hl, de
            ret


; ----------------------------------------------------------------------------
; find_torch — scan the current room's map for 'T', remember where it is (or
; NO_TORCH if the room is unlit).
; ----------------------------------------------------------------------------
find_torch:
            ld      a, NO_TORCH
            ld      (torch_col), a
            ld      (torch_row), a
            call    room_entry_addr
            ld      a, (hl)
            inc     hl
            ld      h, (hl)
            ld      l, a
            ld      b, 0
.ft_row:
            ld      c, 0
.ft_col:
            ld      a, (hl)
            cp      'T'
            jr      nz, .ft_skip
            ld      a, c
            ld      (torch_col), a
            ld      a, b
            ld      (torch_row), a
.ft_skip:
            inc     hl
            inc     c
            ld      a, c
            cp      32
            jr      nz, .ft_col
            inc     b
            ld      a, b
            cp      24
            jr      nz, .ft_row
            ret

; ----------------------------------------------------------------------------
; shade_for_cell — row in B, column in C. Returns a shade 0..4 in A: the
; Chebyshev distance to the torch, halved and clamped. Near the flame = 0
; (lightest); far away = 4 (darkest). No torch = darkest everywhere.
; ----------------------------------------------------------------------------
shade_for_cell:
            ld      a, (torch_col)
            cp      NO_TORCH
            jr      z, .sf_dark
            ld      a, b
            ld      hl, torch_row
            sub     (hl)
            jr      nc, .sf_rpos
            neg
.sf_rpos:
            ld      d, a            ; |row - torch_row|
            ld      a, c
            ld      hl, torch_col
            sub     (hl)
            jr      nc, .sf_cpos
            neg
.sf_cpos:
            cp      d               ; A = |dc|; max(|dc|, |dr|)
            jr      nc, .sf_max
            ld      a, d
.sf_max:
            srl     a               ; distance / 2
            cp      MAX_SHADE + 1
            jr      c, .sf_done
            ld      a, MAX_SHADE
.sf_done:
            ret
.sf_dark:
            ld      a, MAX_SHADE
            ret

draw_room:
            call    find_torch
            call    room_entry_addr
            ld      a, (hl)
            inc     hl
            ld      h, (hl)
            ld      l, a
            ld      (map_ptr), hl
            ld      b, 0
.room_row:
            ld      c, 0
.room_col:
            ld      hl, (map_ptr)
            ld      a, (hl)
            cp      '.'
            jr      nz, .not_floor
            call    shade_for_cell
            add     a, a
            ld      e, a
            ld      d, 0
            ld      hl, shade_tiles
            add     hl, de
            ld      e, (hl)
            inc     hl
            ld      d, (hl)
            ld      (tile_ptr), de
            ld      a, FLOOR_ATTR
            ld      (tile_attr), a
            call    draw_tile
            jr      .cell_done
.not_floor:
            call    lookup_tile
            call    draw_tile
.cell_done:
            ld      hl, (map_ptr)
            inc     hl
            ld      (map_ptr), hl
            inc     c
            ld      a, c
            cp      32
            jr      nz, .room_col
            inc     b
            ld      a, b
            cp      24
            jr      nz, .room_row
            ret

lookup_tile:
            ld      hl, palette
.scan:
            cp      (hl)
            jr      z, .found
            inc     hl
            inc     hl
            inc     hl
            inc     hl
            jr      .scan
.found:
            inc     hl
            ld      e, (hl)
            inc     hl
            ld      d, (hl)
            ld      (tile_ptr), de
            inc     hl
            ld      a, (hl)
            ld      (tile_attr), a
            ret

draw_tile:
            push    bc
            call    attr_addr_cr
            ld      a, (tile_attr)
            ld      (hl), a
            call    scr_addr_cr
            ld      de, (tile_ptr)
            ld      b, 8
.tile_row:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .tile_row
            pop     bc
            ret

player_step:
            ld      a, (thief_col)
            ld      (tcol), a
            ld      a, (thief_row)
            ld      (trow), a

            ld      bc, KEYS_OP
            in      a, (c)
            bit     1, a
            jr      z, .left
            bit     0, a
            jr      z, .right
            ld      bc, KEYS_Q
            in      a, (c)
            bit     0, a
            jr      z, .up
            ld      bc, KEYS_A
            in      a, (c)
            bit     0, a
            jr      z, .down
            ret
.left:
            ld      hl, tcol
            dec     (hl)
            jr      .move
.right:
            ld      hl, tcol
            inc     (hl)
            jr      .move
.up:
            ld      hl, trow
            dec     (hl)
            jr      .move
.down:
            ld      hl, trow
            inc     (hl)
.move:
            ld      a, (trow)
            ld      b, a
            ld      a, (tcol)
            ld      c, a
            call    wall_at
            ret     nz

            call    restore_under
            ld      a, (tcol)
            ld      (thief_col), a
            ld      a, (trow)
            ld      (thief_row), a
            call    collect_gold     ; the new cell might be gold — lift it first
            call    save_under
            call    draw_thief
            call    check_exit
            ret

wall_at:
            call    attr_addr_cr
            bit     WALL_BIT, (hl)
            ret

check_exit:
            ld      a, (thief_col)
            or      a
            jr      z, .west
            cp      31
            jr      z, .east
            ld      a, (thief_row)
            or      a
            jr      z, .north
            cp      23
            jr      z, .south
            ret
.east:
            call    room_entry_addr
            ld      de, 4
            add     hl, de
            ld      a, (hl)
            cp      NO_EXIT
            ret     z
            ld      (current_room), a
            ld      a, 1
            ld      (thief_col), a
            jr      .enter
.west:
            call    room_entry_addr
            ld      de, 5
            add     hl, de
            ld      a, (hl)
            cp      NO_EXIT
            ret     z
            ld      (current_room), a
            ld      a, 30
            ld      (thief_col), a
            jr      .enter
.north:
            call    room_entry_addr
            inc     hl
            inc     hl
            ld      a, (hl)
            cp      NO_EXIT
            ret     z
            ld      (current_room), a
            ld      a, 22
            ld      (thief_row), a
            jr      .enter
.south:
            call    room_entry_addr
            inc     hl
            inc     hl
            inc     hl
            ld      a, (hl)
            cp      NO_EXIT
            ret     z
            ld      (current_room), a
            ld      a, 1
            ld      (thief_row), a
.enter:
            call    draw_room
            call    save_under
            call    draw_thief
            call    warden_enter     ; this room's Warden, clear of the entry cell
            call    save_warden
            call    draw_warden
            ret

pos_bc:
            ld      a, (thief_row)
            ld      b, a
            ld      a, (thief_col)
            ld      c, a
            ret

save_under:
            call    pos_bc
            call    scr_addr_cr
            ld      de, under_thief
            ld      b, 8
.save_row:
            ld      a, (hl)
            ld      (de), a
            inc     de
            inc     h
            djnz    .save_row
            call    pos_bc
            call    attr_addr_cr
            ld      a, (hl)
            ld      (under_thief + 8), a
            ret

restore_under:
            call    pos_bc
            call    scr_addr_cr
            ld      de, under_thief
            ld      b, 8
.restore_row:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .restore_row
            call    pos_bc
            call    attr_addr_cr
            ld      a, (under_thief + 8)
            ld      (hl), a
            ret

draw_thief:
            call    pos_bc
            call    attr_addr_cr
            ld      (hl), THIEF
            call    pos_bc
            call    scr_addr_cr
            ld      de, thief
            ld      b, 8
.thief_row:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .thief_row
            ret

; ----------------------------------------------------------------------------
; The Warden — something shares the keep. A second mover, drawn exactly like the
; thief: a private under-buffer and its own save / draw, a spectral hooded
; sentinel. First we simply give it a body (it neither moves nor harms yet).
; ----------------------------------------------------------------------------
wpos_bc:
            ld      a, (warden_row)
            ld      b, a
            ld      a, (warden_col)
            ld      c, a
            ret

save_warden:
            call    wpos_bc
            call    scr_addr_cr
            ld      de, under_warden
            ld      b, 8
.svw_row:
            ld      a, (hl)
            ld      (de), a
            inc     de
            inc     h
            djnz    .svw_row
            call    wpos_bc
            call    attr_addr_cr
            ld      a, (hl)
            ld      (under_warden + 8), a
            ret

draw_warden:
            call    wpos_bc
            call    attr_addr_cr
            ld      (hl), WARDEN
            call    wpos_bc
            call    scr_addr_cr
            ld      de, warden_glyph
            ld      b, 8
.drw_row:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .drw_row
            ret

; A spectral hooded sentinel: a cowl with dark eye-slits over a robe that frays
; at the hem. Cold, faceless, unmistakably a figure.
warden_glyph:
            defb    %00111100
            defb    %01111110
            defb    %01100110
            defb    %01111110
            defb    %00111100
            defb    %01111110
            defb    %01111110
            defb    %01011010

restore_warden:
            call    wpos_bc
            call    scr_addr_cr
            ld      de, under_warden
            ld      b, 8
.rsw_row:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .rsw_row
            call    wpos_bc
            call    attr_addr_cr
            ld      a, (under_warden + 8)
            ld      (hl), a
            ret

; warden_step — the patrol. Walks its column one cell every WARDEN_SPEED frames,
; after a WARDEN_GATHER beat, reversing at walls. Deterministic: a route you learn
; and time. It reads the thief's cell as a wall (his attribute has WALL_BIT set),
; so it turns aside at him for now — the catch is Unit 11.
warden_step:
            ld      a, (warden_timer)
            dec     a
            ld      (warden_timer), a
            ret     nz
            ld      a, WARDEN_SPEED
            ld      (warden_timer), a
            ; propose the next cell along the patrol axis, in the current dir
            ld      a, (warden_axis)
            or      a
            jr      nz, .ws_vert
.ws_horiz:
            ld      a, (warden_row)
            ld      b, a             ; B = row (fixed)
            ld      a, (warden_dir)
            ld      hl, warden_col
            add     a, (hl)
            ld      c, a             ; C = next col
            jr      .ws_have
.ws_vert:
            ld      a, (warden_col)
            ld      c, a             ; C = col (fixed)
            ld      a, (warden_dir)
            ld      hl, warden_row
            add     a, (hl)
            ld      b, a             ; B = next row
.ws_have:
            ld      a, b             ; the thief there? caught — check BEFORE
            ld      hl, thief_row    ; wall_at, because his own cell reads as wall
            cp      (hl)
            jr      nz, .ws_wall
            ld      a, c
            ld      hl, thief_col
            cp      (hl)
            jr      nz, .ws_wall
            ld      a, 1
            ld      (caught), a
            ret
.ws_wall:
            push    bc
            call    wall_at
            pop     bc
            jr      z, .ws_commit    ; floor ahead — step onto it
            ld      a, (warden_dir)  ; wall ahead — reverse, wait a beat
            neg
            ld      (warden_dir), a
            ret
.ws_commit:
            push    bc               ; keep the proposed (row B, col C)
            call    restore_warden
            pop     bc
            ld      a, c
            ld      (warden_col), a
            ld      a, b
            ld      (warden_row), a
            call    save_warden      ; photograph the new cell's ground
            call    draw_warden
            ret

; ----------------------------------------------------------------------------
; warden_enter — instantiate the current room's Warden from warden_table: place
; it at the route-start (chosen clear of the entry cell), set its axis, and start
; its gather. Called on new_game and on every room change. A second mover is a
; table entry — like the torches and the gold.
; ----------------------------------------------------------------------------
warden_enter:
            ld      a, (current_room)
            add     a, a
            add     a, a             ; * 4 bytes per table row
            ld      e, a
            ld      d, 0
            ld      hl, warden_table
            add     hl, de
            ld      a, (hl)
            ld      (warden_col), a
            inc     hl
            ld      a, (hl)
            ld      (warden_row), a
            inc     hl
            ld      a, (hl)
            ld      (warden_dir), a
            inc     hl
            ld      a, (hl)
            ld      (warden_axis), a
            ld      a, WARDEN_GATHER
            ld      (warden_timer), a
            ret

; warden_table — one row per room: start col, start row, dir (+1/-1), axis.
; Each route crosses that room's gold and starts clear of the entry cell.
warden_table:
            defb    WARDEN_COL0, WARDEN_ROW0, -1, AXIS_VERT   ; Hall — the gold's column
            defb    24, 15, -1, AXIS_VERT                     ; Gallery — column 24, lower chamber
            defb    15, 20, -1, AXIS_HORIZ                    ; Vault — row 20, between the coins

; ----------------------------------------------------------------------------
; The gold — the keep's goal. Step onto a coin and it lifts: the map cell turns
; to floor (gone for good), the cell repaints as plain floor (no lighting yet),
; a chime sounds, and the counter ticks down.
; ----------------------------------------------------------------------------
collect_gold:
            call    cell_state_addr  ; HL -> map cell at the thief's position
            ld      a, (hl)
            cp      'G'
            ret     nz
            ld      (hl), '.'        ; the gold is taken — floor from now on
            call    pos_bc           ; B = row, C = col
            call    draw_floor_cell  ; repaint the cell as plain floor
            call    sfx_pickup
            ld      hl, gold_remaining
            dec     (hl)
            ld      a, (hl)
            or      a
            call    z, win           ; the last coin — the keep stands
            ret

; draw_floor_cell — paint the floor tile at (row B, col C). Lighting (Unit 13)
; will replace this with a shade chosen by distance from the nearest torch.
draw_floor_cell:
            call    shade_for_cell
            add     a, a
            ld      e, a
            ld      d, 0
            ld      hl, shade_tiles
            add     hl, de
            ld      e, (hl)
            inc     hl
            ld      d, (hl)
            ld      (tile_ptr), de
            ld      a, FLOOR_ATTR
            ld      (tile_attr), a
            call    draw_tile
            ret

; ----------------------------------------------------------------------------
; beep — the one tone primitive (the tiny game's blip, reused). B = cycles,
; C = the delay between speaker toggles (the pitch; larger C = lower).
; ----------------------------------------------------------------------------
beep:
.bp_cycle:
            ld      a, %00010000
            out     ($FE), a
            ld      e, c
.bp_hi:
            dec     e
            jr      nz, .bp_hi
            xor     a
            out     ($FE), a
            ld      e, c
.bp_lo:
            dec     e
            jr      nz, .bp_lo
            djnz    .bp_cycle
            ret

; sfx_pickup — a bright two-blip chime: the sound of gold.
sfx_pickup:
            ld      b, 8
            ld      c, 20
            call    beep
            ld      b, 8
            ld      c, 14
            call    beep
            ret

gold_tile:
            defb    %00000000
            defb    %00111100
            defb    %01111110
            defb    %01111110
            defb    %01111110
            defb    %01111110
            defb    %00111100
            defb    %00000000

; The shade ramp: lightest (lit) to darkest (deep shadow), all blue/black dither.
shade_tiles:
            defw    shade0_tile
            defw    shade1_tile
            defw    shade2_tile
            defw    shade3_tile
            defw    shade4_tile

shade0_tile:                        ; lit — nearly all blue
            defb    %00000000
            defb    %00100010
            defb    %00000000
            defb    %00000000
            defb    %00000000
            defb    %10001000
            defb    %00000000
            defb    %00000000
shade1_tile:
            defb    %00100010
            defb    %00000000
            defb    %10001000
            defb    %00000000
            defb    %00100010
            defb    %00000000
            defb    %10001000
            defb    %00000000
shade2_tile:                        ; the half-and-half slate from Unit 2
            defb    %10101010
            defb    %01010101
            defb    %10101010
            defb    %01010101
            defb    %10101010
            defb    %01010101
            defb    %10101010
            defb    %01010101
shade3_tile:
            defb    %10101010
            defb    %11111111
            defb    %01010101
            defb    %11111111
            defb    %10101010
            defb    %11111111
            defb    %01010101
            defb    %11111111
shade4_tile:                        ; deep shadow — nearly all black
            defb    %11111111
            defb    %11101110
            defb    %11111111
            defb    %10111011
            defb    %11111111
            defb    %11101110
            defb    %11111111
            defb    %10111011

torch_tile:                         ; a flame in its sconce
            defb    %00010000
            defb    %00111000
            defb    %00111000
            defb    %01111100
            defb    %01111100
            defb    %01111100
            defb    %00111000
            defb    %00010000

statue_tile:
            defb    %00111100
            defb    %01111110
            defb    %00111100
            defb    %00011000
            defb    %00011000
            defb    %00111100
            defb    %01111110
            defb    %01111110

banner_tile:
            defb    %01111110
            defb    %01111110
            defb    %01011010
            defb    %01011010
            defb    %01111110
            defb    %01111110
            defb    %00111100
            defb    %00011000

rubble_tile:
            defb    %00000000
            defb    %01100000
            defb    %01100000
            defb    %00000110
            defb    %00000110
            defb    %00011000
            defb    %00011000
            defb    %00000000

; ----------------------------------------------------------------------------
; show_title — black screen, the keep's name and a prompt; wait for SPACE (and
; release). Silent for now — the composed theme arrives in Unit 18. Words use the
; ROM's own 8x8 font at $3D00.
; ----------------------------------------------------------------------------
show_title:
            di
            call    clear_screen
            ld      hl, str_title
            ld      b, 8
            ld      c, 11
            call    print_string
            ld      hl, str_prompt
            ld      b, 16
            ld      c, 6
            call    print_string
.tt_wait:
            ld      bc, KEYS_SPACE
            in      a, (c)
            bit     0, a
            jr      nz, .tt_wait
.tt_rel:
            ld      bc, KEYS_SPACE
            in      a, (c)
            bit     0, a
            jr      z, .tt_rel
            ret

; show_win — the keep is cleared. Black screen, the words, the flourish, then
; wait for SPACE (and release) to return to the title.
show_win:
            di
            call    clear_screen
            ld      hl, str_won
            ld      b, 9
            ld      c, 8
            call    print_string
            ld      hl, str_again
            ld      b, 15
            ld      c, 5
            call    print_string
            call    sfx_win
.sw_wait:
            ld      bc, KEYS_SPACE
            in      a, (c)
            bit     0, a
            jr      nz, .sw_wait
.sw_rel:
            ld      bc, KEYS_SPACE
            in      a, (c)
            bit     0, a
            jr      z, .sw_rel
            ret

; win — the last coin is gone. Flourish, and raise the flag the loop watches.
win:
            ld      a, 1
            ld      (won), a
            call    sfx_win
            ret

; sfx_win — an ascending flourish: a low note climbing in steps to a high one.
sfx_win:
            ld      c, 60
.swf_loop:
            ld      b, 12
            push    bc
            call    beep
            pop     bc
            ld      a, c
            sub     8
            ld      c, a
            cp      16
            jr      nc, .swf_loop
            ret

; clear_screen — fill bitmap and attributes with zero: a black screen.
clear_screen:
            ld      hl, $4000
            ld      (hl), 0
            ld      de, $4001
            ld      bc, 6911
            ldir
            ret

; print_string — HL -> zero-terminated text, B = row, C = col.
print_string:
.ps_loop:
            ld      a, (hl)
            or      a
            ret     z
            push    hl
            call    print_char
            pop     hl
            inc     hl
            inc     c
            jr      .ps_loop

; print_char — A = character (32..127), B = row, C = col. Copies the ROM font
; glyph at $3D00 + (char-32)*8 to the screen, bright white.
print_char:
            push    bc
            sub     32
            ld      l, a
            ld      h, 0
            add     hl, hl
            add     hl, hl
            add     hl, hl
            ld      de, $3D00
            add     hl, de
            push    hl
            call    scr_addr_cr
            pop     de
            ld      b, 8
.pc_row:
            ld      a, (de)
            ld      (hl), a
            inc     de
            inc     h
            djnz    .pc_row
            pop     bc
            call    attr_addr_cr
            ld      (hl), %01000111
            ret

str_title:
            defb    "SHADOWKEEP", 0
str_prompt:
            defb    "PRESS SPACE TO ENTER", 0
str_won:
            defb    "THE KEEP STANDS", 0
str_again:
            defb    "PRESS SPACE TO RETURN", 0

; ----------------------------------------------------------------------------
; show_lose — the mirror of show_win. Black screen, the words, the freezing
; sting, then wait for SPACE (and release) to return to the title.
; ----------------------------------------------------------------------------
show_lose:
            di
            call    clear_screen
            ld      hl, str_lost
            ld      b, 9
            ld      c, 8
            call    print_string
            ld      hl, str_again
            ld      b, 15
            ld      c, 5
            call    print_string
            call    sfx_caught
.slo_wait:
            ld      bc, KEYS_SPACE
            in      a, (c)
            bit     0, a
            jr      nz, .slo_wait
.slo_rel:
            ld      bc, KEYS_SPACE
            in      a, (c)
            bit     0, a
            jr      z, .slo_rel
            ret

; sfx_caught — the plunge into stasis: a quick fall, then a deep, long toll as
; the stone closes over you. The opposite of the win flourish.
sfx_caught:
            ld      c, 16
.sca_fall:
            ld      b, 5
            push    bc
            call    beep
            pop     bc
            ld      a, c
            add     a, 7
            ld      c, a
            cp      100
            jr      c, .sca_fall
            ld      b, 60
            ld      c, 130
            call    beep
            ret

str_lost:
            defb    "THE KEEP SLEEPS", 0

scr_addr_cr:
            ld      a, b
            and     %00011000
            or      %01000000
            ld      h, a
            ld      a, b
            and     %00000111
            rrca
            rrca
            rrca
            or      c
            ld      l, a
            ret

attr_addr_cr:
            ld      a, b
            ld      l, a
            ld      h, 0
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            ld      de, $5800
            add     hl, de
            ld      a, c
            ld      e, a
            ld      d, 0
            add     hl, de
            ret

palette:
            defb    '.'
            defw    floor_tile
            defb    FLOOR_ATTR
            defb    '#'
            defw    wall_tile
            defb    WALL_ATTR
            defb    '+'
            defw    mark_tile
            defb    MARK_ATTR
            defb    'G'
            defw    gold_tile
            defb    GOLD_ATTR
            defb    'T'
            defw    torch_tile
            defb    TORCH_ATTR
            defb    'S'
            defw    statue_tile
            defb    STATUE_ATTR
            defb    'B'
            defw    banner_tile
            defb    BANNER_ATTR
            defb    'o'
            defw    rubble_tile
            defb    RUBBLE_ATTR

; ----------------------------------------------------------------------------
; The keep: three rooms. Hall -east-> Gallery -north-> Vault, and back.
;   entry: map ptr, North, South, East, West
; ----------------------------------------------------------------------------
rooms:
            defw    room0_state
            defb    NO_EXIT, NO_EXIT, 1, NO_EXIT      ; Hall: east -> Gallery
            defw    room1_state
            defb    2, NO_EXIT, NO_EXIT, 0            ; Gallery: north -> Vault, west -> Hall
            defw    room2_state
            defb    NO_EXIT, 1, NO_EXIT, NO_EXIT      ; Vault: south -> Gallery

; The Great Hall — four pillars, east door at row 11.
room0_template:
            defb    "###############T################"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "B..............S...............B"
            defb    "#.............ooo.........G....#"
            defb    "#..............................#"
            defb    "#........##..........##........#"
            defb    "#........##..........##........#"
            defb    "#..............................#"
            defb    "#..............................."
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#........##..........##........#"
            defb    "#........##..........##........#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#.........................G....#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "################################"

; The Gallery — a dividing wall with one gap (column 15). West door (row 11)
; back to the Hall; north door (column 15) up to the Vault.
room1_template:
            defb    "###############.################"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "###############.################"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "........................G......#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "B..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#........................ooo...#"
            defb    "#..............................#"
            defb    "#.......................G......#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "###############T################"

; The Vault — a great altar of stone in the middle, south door (column 15)
; down to the Gallery.
room2_template:
            defb    "###############T################"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#.............####.............#"
            defb    "B.............####.............#"
            defb    "#.............####.............B"
            defb    "#.............####.............#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#.........G.........G..........#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "###############.################"

floor_tile:
            defb    %10101010
            defb    %01010101
            defb    %10101010
            defb    %01010101
            defb    %10101010
            defb    %01010101
            defb    %10101010
            defb    %01010101

wall_tile:
            defb    %00010001
            defb    %00000000
            defb    %01000100
            defb    %00000000
            defb    %00010001
            defb    %00000000
            defb    %01000100
            defb    %00000000

mark_tile:
            defb    %00000000
            defb    %00011000
            defb    %00011000
            defb    %01111110
            defb    %01111110
            defb    %00011000
            defb    %00011000
            defb    %00000000

thief:
            defb    %00011000
            defb    %00111100
            defb    %01111110
            defb    %01111110
            defb    %01111110
            defb    %01111110
            defb    %00111100
            defb    %00100100

current_room:
            defb    0
thief_col:
            defb    START_COL
thief_row:
            defb    START_ROW
tcol:
            defb    0
trow:
            defb    0
map_ptr:
            defw    0
tile_ptr:
            defw    0
tile_attr:
            defb    0
under_thief:
            defb    0, 0, 0, 0, 0, 0, 0, 0, 0
gold_remaining:
            defb    TOTAL_GOLD
won:
            defb    0
under_warden:
            defb    0, 0, 0, 0, 0, 0, 0, 0, 0
warden_col:
            defb    WARDEN_COL0
warden_row:
            defb    WARDEN_ROW0
warden_dir:
            defb    -1
warden_axis:
            defb    AXIS_VERT
warden_timer:
            defb    WARDEN_GATHER
caught:
            defb    0
torch_col:
            defb    NO_TORCH
torch_row:
            defb    NO_TORCH

room0_state:
            defs    768
room1_state:
            defs    768
room2_state:
            defs    768

            end     start
