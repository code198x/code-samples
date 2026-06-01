ship_hit:
        ; --- Decrement lives ---
        dec lives

        ; Update lives display
        lda lives
        clc
        adc #$30
        sta $0427

        ; Check if lives exhausted
        lda lives
        bne life_lost

        ; --- No lives left — game over ---
        lda #$01
        sta game_state

        ; Turn ship red
        lda #$02
        sta $d027

        ; Show GAME OVER text
        jsr show_game_over
        jmp play_death_sound

life_lost:
        ; --- Lives remaining — reset ship position ---
        lda #172
        sta $d000
        lda #220
        sta $d001

play_death_sound:
        ; Death sound plays in both cases
        ; ...
