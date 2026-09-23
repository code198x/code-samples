; Controlled transition test, not three played-through games.
*= $3000
restart_trial:
        lda #3
        sta enemy_count         ; Explicit one-time setup for this experiment
        lda #0
        sta trial_index
trial_again:
        jsr enter_title
        jsr enter_game
        jsr snapshot_entry
        inc trial_index
        lda trial_index
        cmp #3
        beq trial_finish
        ; Exercise real wave growth, without requiring ten kills per wave.
        lda #5
        sta growth_left
trial_grow:
        jsr advance_wave
        dec growth_left
        bne trial_grow
        ; Deliberate late-session state. These are fixture writes, not play.
        lda #$42
        sta score
        lda #$12
        sta score_hi
        lda #1
        sta lives
        sta bullet_active
        lda #7
        sta kills
        jmp trial_again
snapshot_entry:
        ldx trial_index
        lda record_offsets,x
        tax
        lda enemy_count
        sta records,x
        lda score
        sta records+1,x
        lda score_hi
        sta records+2,x
        lda lives
        sta records+3,x
        lda wave
        sta records+4,x
        lda kills
        sta records+5,x
        lda fall_speed
        sta records+6,x
        lda bullet_active
        sta records+7,x
        lda $d015
        sta records+8,x
        rts
trial_finish:
        ; Freeze the diagnostic screen after all transitions have completed.
        sei
        lda #0
        sta $d015
        ldx #0
        lda #32
trial_clear:
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $0700,x
        inx
        bne trial_clear
        ldx #0
trial_text:
        lda panel,x
        sta $0400,x
        lda #1
        sta $d800,x
        inx
        cpx #160
        bne trial_text
        lda records
        clc
        adc #48
        sta $043f
        lda records+9
        clc
        adc #48
        sta $0467
        lda records+18
        clc
        adc #48
        sta $048f
        lda #1
        sta trial_done
trial_halt:
        jmp trial_halt
record_offsets: !byte 0,9,18
panel:
; prepare.py appends 4 rows of screen-code text here.
