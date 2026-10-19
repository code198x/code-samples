; Pasmo syntax. ANIM_DELAY and ANIM_LENGTH are constants in1.animation_255.
; Caller allocates anim_counter, anim_frame and sprite_index as writable bytes.
; Initialise counters to0 and sprite_index to walk_frames[0] on state entry.
; walk_frames has ANIM_LENGTH bytes and remains readable for all calls.
; One call per chosen update. Changes AF/DE/HL; preserves BC/IX/IY.
; A=new sprite_index only when the delay expires; use the state byte to draw.
update_animation:
    ld a,(anim_counter)
    inc a
    ld (anim_counter),a
    cp ANIM_DELAY
    ret c                 ; Not time yet

    xor a
    ld (anim_counter),a

    ld a,(anim_frame)
    inc a
    cp ANIM_LENGTH
    jr c,animation_set_frame
    xor a
animation_set_frame:
    ld (anim_frame),a

    ld e,a
    ld d,0
    ld hl,walk_frames
    add hl,de             ; propagate carry when the table crosses a page
    ld a,(hl)             ; Get sprite index
    ld (sprite_index),a    ; renderer consumes this logical image number
    ret
