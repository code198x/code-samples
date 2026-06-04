        ; --- Death timer (invulnerability flash) ---
        lda death_timer
        beq no_death_flash      ; Timer not running

        dec death_timer
        bne no_death_flash      ; Still counting down

        ; Timer just expired — restore border to black
        lda #$00
        sta $d020

no_death_flash:
