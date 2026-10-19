; Writable byte state is allocated by demo.asm. Bounds: x=0..15, y=0..9.
; read_controls supplies controls; up/down/left/right/action = 1/2/4/8/16.
; All routines change A/X/Y/flags; no IRQ may write this state.
; Call edges -> service_sound -> update_player -> draw_screen once per frame.
detect_edges:
    lda previous
    eor #$ff
    and controls
    sta pressed
    lda controls
    eor #$ff
    and previous
    sta released
    lda controls
    sta previous
    rts
reset_game:
    lda #2
    sta player_x
    lda #5
    sta player_y
    lda #1
    sta item_active
    lda #0
    sta score
    sta move_delay
    rts
update_player:
    lda pressed
    and #16
    beq movement
    jsr reset_game
    rts
movement:
    lda move_delay
    beq move_now
    dec move_delay
    rts
move_now:
    lda #5
    sta move_delay
    lda controls
    and #4
    beq move_right
    lda player_x
    beq move_right
    dec player_x
move_right:
    lda controls
    and #8
    beq move_up
    lda player_x
    cmp #15
    beq move_up
    inc player_x
move_up:
    lda controls
    and #1
    beq move_down
    lda player_y
    beq move_down
    dec player_y
move_down:
    lda controls
    and #2
    beq test_collection
    lda player_y
    cmp #9
    beq test_collection
    inc player_y
test_collection:
    lda item_active
    beq collection_done
    lda player_x
    sta rect_a
    clc
    adc #1
    sta rect_a+2
    lda player_y
    sta rect_a+1
    clc
    adc #1
    sta rect_a+3
    jsr boxes_overlap
    bcc collection_done
    lda #0
    sta item_active           ; consume BEFORE starting feedback
    inc score
    jsr trigger_sound
collection_done:
    rts
