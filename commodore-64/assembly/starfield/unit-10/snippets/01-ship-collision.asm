        ; --- Check ship-enemy collision ---
        ldx #$00
ship_collision_loop:
        lda flash_tbl,x
        bne next_ship_check     ; Skip flashing enemies

        ; Check Y distance (ship Y vs enemy Y)
        lda $d001               ; Ship Y
        sec
        sbc enemy_y_tbl,x
        cmp #$10
        bcc check_ship_x
        cmp #$f0
        bcc next_ship_check

check_ship_x:
        ; Check X distance (ship X vs enemy X)
        lda $d000               ; Ship X
        sec
        sbc enemy_x_tbl,x
        cmp #$10
        bcc ship_hit
        cmp #$f0
        bcc next_ship_check
        jmp ship_hit            ; >= $F0 = close (negative)

next_ship_check:
        inx
        cpx #$03
        bne ship_collision_loop
        jmp no_ship_hit

ship_hit:
        ; Ship is destroyed
        lda #$01
        sta game_over

        ; Turn ship red
        lda #$02
        sta $d027

        ; Death sound — SID voice 3 (descending sawtooth)
        lda #$00
        sta $d40e               ; Frequency low
        lda #$10
        sta $d40f               ; Frequency high
        lda #$0a
        sta $d412               ; Attack=0, Decay=10 (long decay)
        lda #$00
        sta $d413               ; Sustain=0, Release=0
        lda #$20
        sta $d411               ; Sawtooth, gate OFF (reset envelope)
        lda #$21
        sta $d411               ; Sawtooth, gate ON (trigger)

no_ship_hit:
