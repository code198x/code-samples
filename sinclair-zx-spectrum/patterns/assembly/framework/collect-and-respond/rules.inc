; State: bytes. Grid x=0..15,y=0..9. Controls U/D/L/R/action=1/2/4/8/16.
; Call once after read_controls; changes AF/BC/DE/HL, preserves IX/IY.
detect_edges:
    ld a,(previous)
    cpl
    ld b,a
    ld a,(controls)
    and b
    ld (pressed),a
    ld a,(controls)
    cpl
    ld b,a
    ld a,(previous)
    and b
    ld (released),a
    ld a,(controls)
    ld (previous),a
    ret
reset_game:
    ld a,2
    ld (player_x),a
    ld a,5
    ld (player_y),a
    ld a,1
    ld (item_active),a
    xor a
    ld (score),a
    ld (move_delay),a
    ret
update_player:
    ld a,(pressed)
    and 16
    jp nz,reset_game
    ld a,(move_delay)
    or a
    jr z,move_now
    dec a
    ld (move_delay),a
    ret
move_now:
    ld a,5
    ld (move_delay),a
    ld a,(controls)
    ld b,a
    ld hl,player_x
    bit 2,b
    jr z,move_right
    ld a,(hl)
    or a
    jr z,move_right
    dec (hl)
move_right:
    bit 3,b
    jr z,move_up
    ld a,(hl)
    cp 15
    jr z,move_up
    inc (hl)
move_up:
    ld hl,player_y
    bit 0,b
    jr z,move_down
    ld a,(hl)
    or a
    jr z,move_down
    dec (hl)
move_down:
    bit 1,b
    jr z,test_collection
    ld a,(hl)
    cp 9
    jr z,test_collection
    inc (hl)
test_collection:
    ld a,(item_active)
    or a
    ret z
    ld a,(player_x)
    ld (rect_a),a
    inc a
    ld (rect_a+2),a
    ld a,(player_y)
    ld (rect_a+1),a
    inc a
    ld (rect_a+3),a
    call boxes_overlap
    ret nc
    xor a
    ld (item_active),a
    ld hl,score
    inc (hl)
    jp trigger_sound
