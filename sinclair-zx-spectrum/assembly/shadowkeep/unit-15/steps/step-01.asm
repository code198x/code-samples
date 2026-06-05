; Shadowkeep — Unit 15: A Theme in One Voice
; Cumulative build; every step runs on its own. Narrative: the unit page.
; step-01 adds a note-table player and a short D-minor theme that plays as the keep opens.

            org     32768

WALL_ATTR   equ     %01001000
FLOOR_ATTR  equ     %00001000
TORCH_ATTR  equ     %01001110
STATUE_ATTR equ     %01001111
BANNER_ATTR equ     %01001011
RUBBLE_ATTR equ     %00001000
MARK_ATTR   equ     %00001111
GOLD_ATTR   equ     %00000110         ; yellow ink, no BRIGHT -> walkable gold
THIEF       equ     %01001010
WALL_BIT    equ     6

START_COL   equ     15
START_ROW   equ     11
NO_EXIT     equ     $FF
MAX_SHADE   equ     4
MAX_TORCHES equ     4
TOTAL_GOLD  equ     6

KEYS_OP     equ     $DFFE
KEYS_Q      equ     $FBFE
KEYS_A      equ     $FDFE
KEYS_SPACE  equ     $7FFE

start:
            ld      a, 0
            out     ($FE), a

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
            ld      a, START_COL
            ld      (thief_col), a
            ld      a, START_ROW
            ld      (thief_row), a

            call    draw_room
            call    save_under
            call    draw_thief

            di                       ; clean audio: no 50Hz tick over the tune
            ld      hl, theme
            call    play_tune

            im      1
            ei
.loop:
            halt
            ld      a, (won)
            or      a
            jr      nz, .loop        ; keep won: freeze on the last coin
            call    player_step
            call    mark_step
            jr      .loop

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
; find_torches — collect every 'T' in the current room (up to MAX_TORCHES) into
; torch_list as (col, row) pairs; torch_count says how many.
; ----------------------------------------------------------------------------
find_torches:
            xor     a
            ld      (torch_count), a
            call    room_entry_addr
            ld      a, (hl)
            inc     hl
            ld      h, (hl)
            ld      l, a
            ld      b, 0
.fr_row:
            ld      c, 0
.fr_col:
            ld      a, (hl)
            cp      'T'
            jr      nz, .fr_skip
            ld      a, (torch_count)
            cp      MAX_TORCHES
            jr      nc, .fr_skip
            push    hl
            add     a, a            ; count * 2
            ld      e, a
            ld      d, 0
            ld      hl, torch_list
            add     hl, de
            ld      (hl), c         ; column
            inc     hl
            ld      (hl), b         ; row
            pop     hl
            ld      a, (torch_count)
            inc     a
            ld      (torch_count), a
.fr_skip:
            inc     hl
            inc     c
            ld      a, c
            cp      32
            jr      nz, .fr_col
            inc     b
            ld      a, b
            cp      24
            jr      nz, .fr_row
            ret

; ----------------------------------------------------------------------------
; shade_for_cell — row in B, column in C. Distance to the NEAREST torch,
; shifted by the room's falloff, clamped. Preserves B and C.
; ----------------------------------------------------------------------------
shade_for_cell:
            push    bc
            ld      a, b
            ld      (cell_row), a
            ld      a, c
            ld      (cell_col), a
            ld      a, (torch_count)
            or      a
            jr      z, .sf_dark
            ld      a, 255
            ld      (min_dist), a
            ld      hl, torch_list
            ld      a, (torch_count)
            ld      b, a            ; loop count
.sf_loop:
            ld      a, (cell_col)
            sub     (hl)            ; - torch col
            jr      nc, .sf_dc
            neg
.sf_dc:
            ld      d, a            ; |dc|
            inc     hl              ; -> torch row
            ld      a, (cell_row)
            sub     (hl)
            jr      nc, .sf_dr
            neg
.sf_dr:
            inc     hl              ; -> next torch pair
            cp      d               ; A = |dr|; take the larger
            jr      nc, .sf_mx
            ld      a, d
.sf_mx:
            ld      e, a            ; this torch's distance
            ld      a, (min_dist)
            cp      e
            jr      c, .sf_keep     ; min already smaller
            ld      a, e
            ld      (min_dist), a
.sf_keep:
            djnz    .sf_loop

            ld      a, (current_room)
            ld      c, a
            ld      b, 0
            ld      hl, room_falloff
            add     hl, bc
            ld      b, (hl)
            ld      a, (min_dist)
            inc     b
.sf_shift:
            dec     b
            jr      z, .sf_clamp
            srl     a
            jr      .sf_shift
.sf_clamp:
            cp      MAX_SHADE + 1
            jr      c, .sf_done
            ld      a, MAX_SHADE
.sf_done:
            pop     bc
            ret
.sf_dark:
            ld      a, MAX_SHADE
            pop     bc
            ret

draw_room:
            call    find_torches
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
            call    draw_floor_cell
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
            call    collect_gold     ; new cell might be gold — lift it first
            call    save_under
            call    draw_thief
            call    sfx_step
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
            call    sfx_door
            call    draw_room
            call    save_under
            call    draw_thief
            ret

; ----------------------------------------------------------------------------
; The sound-effects driver.
;
; beep — the one tone primitive. B = number of square-wave cycles (how long
; the tone lasts); C = the delay constant between speaker toggles (the pitch —
; a larger C waits longer between flips, so the wave is slower and the note is
; lower). Bit 4 of port $FE is the speaker; we write it high, wait C, write it
; low (and a black border with it), wait C, and repeat B times.
; ----------------------------------------------------------------------------
beep:
.bp_cycle:
            ld      a, %00010000     ; speaker high (border stays black)
            out     ($FE), a
            ld      e, c
.bp_hi:
            dec     e
            jr      nz, .bp_hi
            xor     a                ; speaker low, border black
            out     ($FE), a
            ld      e, c
.bp_lo:
            dec     e
            jr      nz, .bp_lo
            djnz    .bp_cycle
            ret

; sfx_step — a footfall: short and low. A handful of cycles of a low tone,
; gone almost before you notice it. Played under every successful move.
sfx_step:
            ld      b, 5
            ld      c, 90
            call    beep
            ret

; sfx_door — a creak: a tone that falls in pitch as it plays. We start the
; delay constant small (higher) and let it grow (lower), a few cycles at each
; step, so the note groans downward — a heavy door swinging on its hinges.
sfx_door:
            ld      c, 36            ; start higher
.sd_sweep:
            ld      b, 3
            push    bc
            call    beep
            pop     bc
            inc     c                ; lower the pitch a little
            inc     c
            ld      a, c
            cp      130              ; until it has groaned down low
            jr      c, .sd_sweep
            ret

; sfx_pickup — a bright two-blip chime: short, high, rising. The sound of gold.
sfx_pickup:
            ld      b, 8
            ld      c, 20
            call    beep
            ld      b, 8
            ld      c, 14            ; a touch higher — a little ting
            call    beep
            ret

; sfx_win — an ascending flourish: a low note climbing in steps to a high one.
sfx_win:
            ld      c, 60            ; low-ish
.sw_loop:
            ld      b, 12
            push    bc
            call    beep
            pop     bc
            ld      a, c
            sub     8                ; smaller delay -> higher pitch (rising)
            ld      c, a
            cp      16
            jr      nc, .sw_loop     ; until we've climbed high
            ret

; ----------------------------------------------------------------------------
; draw_floor_cell — paint the floor at (row B, col C), shaded for the light.
; Extracted from draw_room so collection can repaint a cell as floor too.
; ----------------------------------------------------------------------------
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
; collect_gold — if the cell the thief just moved onto is gold, lift it: turn
; the map cell to floor (gone for good), repaint it, chime, and tick the
; counter down. At zero, the keep is won.
; ----------------------------------------------------------------------------
collect_gold:
            call    cell_state_addr  ; HL -> map cell at the thief's position
            ld      a, (hl)
            cp      'G'
            ret     nz
            ld      (hl), '.'        ; the gold is taken — floor from now on
            call    pos_bc           ; B = row, C = col
            call    draw_floor_cell  ; so save_under grabs floor, not gold
            call    sfx_pickup
            ld      hl, gold_remaining
            dec     (hl)
            ld      a, (hl)
            or      a
            call    z, win
            ret

; win — the last coin is gone. Flourish, and raise the flag the loop watches.
win:
            ld      a, 1
            ld      (won), a
            call    sfx_win
            ret

; ----------------------------------------------------------------------------
; The music player — a note-table interpreter.
;
; play_tune — HL points at a stream of (pitch, duration) byte pairs:
;   pitch $FF  -> end of tune (return).
;   pitch 0    -> rest: silence for `duration` chunks.
;   else       -> a note: tone at delay `pitch`, held for `duration` chunks.
; A short gap is inserted after every note so they articulate instead of
; slurring into one another.
; ----------------------------------------------------------------------------
play_tune:
.pt_next:
            ld      a, (hl)          ; pitch
            inc     hl
            cp      $FF
            ret     z                ; end of tune
            ld      c, a             ; pitch -> C
            ld      a, (hl)          ; duration
            inc     hl
            ld      d, a             ; duration -> D (chunk count)
            ld      a, c
            or      a
            jr      z, .pt_rest
            push    hl
            call    play_note        ; C = pitch, D = chunks
            pop     hl
            jr      .pt_gap
.pt_rest:
            push    hl
            call    rest_chunks      ; D chunks of silence
            pop     hl
.pt_gap:
            push    hl
            ld      d, 1             ; one chunk of silence between notes
            call    rest_chunks
            pop     hl
            jr      .pt_next

; play_note — C = pitch (beep delay), D = duration in chunks. A note is just
; the beep primitive run for D fixed-size chunks, so a note can be long even
; though one beep's cycle count (B) is a single byte.
play_note:
.pn_loop:
            ld      b, 24            ; one chunk = 24 square-wave cycles
            push    de
            call    beep             ; B cycles at pitch C
            pop     de
            dec     d
            jr      nz, .pn_loop
            ret

; rest_chunks — D chunks of silence, timed to roughly match a note chunk so
; rests sit in the rhythm.
rest_chunks:
.rc_loop:
            ld      b, 24
.rc_inner:
            ld      e, 75
.rc_wait:
            dec     e
            jr      nz, .rc_wait
            djnz    .rc_inner
            dec     d
            jr      nz, .rc_loop
            ret

; The theme — a short, solemn phrase in D minor. Pitch values are beep delay
; constants (larger = lower); durations are chunk counts. One voice, no
; harmony: the melody carries the whole mood by itself.
theme:
            defb    75, 8            ; D5
            defb    63, 8            ; F5
            defb    50, 8            ; A5
            defb    50, 12           ; A5 (held)
            defb    56, 8            ; G5
            defb    63, 8            ; F5
            defb    66, 8            ; E5
            defb    75, 16           ; D5 (resolve)
            defb    0,  6            ; breath
            defb    56, 8            ; G5
            defb    63, 8            ; F5
            defb    50, 8            ; A5
            defb    75, 16           ; D5 (home)
            defb    $FF              ; end

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
            defw    shade2_tile
            defb    FLOOR_ATTR
            defb    '#'
            defw    wall_tile
            defb    WALL_ATTR
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
            defb    '+'
            defw    mark_tile
            defb    MARK_ATTR
            defb    'G'
            defw    gold_tile
            defb    GOLD_ATTR

shade_tiles:
            defw    shade0_tile
            defw    shade1_tile
            defw    shade2_tile
            defw    shade3_tile
            defw    shade4_tile

room_falloff:
            defb    2                   ; Hall — broad
            defb    1                   ; Gallery — medium
            defb    0                   ; Vault — tight

rooms:
            defw    room0_state
            defb    NO_EXIT, NO_EXIT, 1, NO_EXIT
            defw    room1_state
            defb    2, NO_EXIT, NO_EXIT, 0
            defw    room2_state
            defb    NO_EXIT, 1, NO_EXIT, NO_EXIT

; The Great Hall — three sconces (top-centre and the two side walls), broadly
; lit; banners flank a statue with rubble at its feet.
room0_template:
            defb    "###############T################"
            defb    "#..............................#"
            defb    "#.......G......................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "B..............S...............B"
            defb    "#.............ooo..............#"
            defb    "#..............................#"
            defb    "T........##..........##........T"
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
            defb    "#.....................G........#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "################################"

; The Gallery — two torches: low on the south wall, and one on the east wall.
room1_template:
            defb    "###############.################"
            defb    "#..............................#"
            defb    "#.....G........................#"
            defb    "#..............................#"
            defb    "#..............................T"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "###############.################"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "...............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "B..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#........................ooo...#"
            defb    "#..............................#"
            defb    "#.......................G......#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "###############T################"

; The Vault — one flame, on the altar. Its character is the dark.
room2_template:
            defb    "################################"
            defb    "#..............................#"
            defb    "#.........G....................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#.............#T##.............#"
            defb    "#.............####.............#"
            defb    "#.............####.............#"
            defb    "#.............####.............#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#..............................#"
            defb    "#...................G..........#"
            defb    "#..............................#"
            defb    "###############.################"

shade0_tile:
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
shade2_tile:
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
shade4_tile:
            defb    %11111111
            defb    %11101110
            defb    %11111111
            defb    %10111011
            defb    %11111111
            defb    %11101110
            defb    %11111111
            defb    %10111011

wall_tile:
            defb    %00010001
            defb    %00000000
            defb    %01000100
            defb    %00000000
            defb    %00010001
            defb    %00000000
            defb    %01000100
            defb    %00000000

torch_tile:
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

mark_tile:
            defb    %00000000
            defb    %00011000
            defb    %00011000
            defb    %01111110
            defb    %01111110
            defb    %00011000
            defb    %00011000
            defb    %00000000

gold_tile:
            defb    %00000000
            defb    %00111100
            defb    %01111110
            defb    %01111110
            defb    %01111110
            defb    %01111110
            defb    %00111100
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
torch_count:
            defb    0
cell_row:
            defb    0
cell_col:
            defb    0
min_dist:
            defb    0
gold_remaining:
            defb    TOTAL_GOLD
won:
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
torch_list:
            defs    MAX_TORCHES * 2

room0_state:
            defs    768
room1_state:
            defs    768
room2_state:
            defs    768

            end     start
