; Fixed seed, twelve calls, no joystick input or gameplay updates.
*= $3000
position_trial:
        lda #1
        sta rng_seed
        lda #$ab                ; Sprite 2 high bit clear; other bits deliberately set
        sta $d010
        lda #0
        sta trial_index
        sta record_offset
position_next:
        ldx #0                  ; Reuse enemy 0 (sprite 2) to test set AND clear
        lda #80
        jsr spawn_enemy
        ldy record_offset
        lda rng_seed
        sta records,y
        lda enemy_x_tbl
        sta records+1,y
        lda enemy_xhi_tbl
        sta records+2,y
        lda $d004
        sta records+3,y
        lda $d010
        sta records+4,y
        tya
        clc
        adc #5
        sta record_offset
        inc trial_index
        lda trial_index
        cmp #12
        bne position_next
        sei
        lda #0
        sta $d015               ; Display records, not a moving sprite
        ldx #0
        lda #32
position_clear:
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $0700,x
        inx
        bne position_clear
        ldx #0
position_panel:
        lda panel,x
        sta $0400,x
        lda #1
        sta $d800,x
        inx
        cpx #160
        bne position_panel
        ; Show the last three records as hex: seed, low, high, VIC low, D010.
        ldx #0
position_hex:
        lda records+45,x
        lsr
        lsr
        lsr
        lsr
        tay
        lda hex_digits,y
        ldy screen_offsets,x
        sta $0400,y
        lda records+45,x
        and #15
        tay
        lda hex_digits,y
        ldy screen_offsets,x
        sta $0401,y
        inx
        cpx #15
        bne position_hex
        lda #1
        sta trial_done
position_halt:
        jmp position_halt
hex_digits: !byte 48,49,50,51,52,53,54,55,56,57,1,2,3,4,5,6
screen_offsets: !byte 46,51,56,61,66,86,91,96,101,106,126,131,136,141,146
panel:
