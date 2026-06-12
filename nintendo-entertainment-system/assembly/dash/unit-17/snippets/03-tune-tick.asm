; -----------------------------------------------------------------------------
; tune_tick — one frame of the sequencer
;   A phrase is rows of three bytes: period low, period high, frames.
;   Period 0/0 is a rest (silence is a note too). Two terminators, two
;   meanings: frames $FF loops to the top (the title jingle), frames $FE
;   stops for good (a fanfare or a sting says its piece once).
;   The APU holds each note itself — this routine touches the chip twice
;   per note, and the game runs on regardless.
; -----------------------------------------------------------------------------
tune_tick:
    lda tune_ptr+1
    bne @active
    rts                     ; sequencer off
@active:
    dec tune_timer
    beq @next
    rts
@next:
    ldy tune_idx
    lda (tune_ptr), y       ; period, low byte
    sta tune_lo
    iny
    lda (tune_ptr), y       ; period, high byte
    sta tune_hi
    iny
    lda (tune_ptr), y       ; frames — or a marker
    iny
    sty tune_idx

    cmp #$FF                ; loop: round again
    bne @not_loop
    lda #0
    sta tune_idx
    jmp @next
@not_loop:
    cmp #$FE                ; stop: played once, now done
    bne @note
    lda #%00110000          ; silence the pulse
    sta SQ1_VOL
    lda #0
    sta tune_ptr+1          ; sequencer off
    rts
@note:
    sta tune_timer
    lda tune_lo
    ora tune_hi
    bne @sound
    lda #%00110000          ; a rest: quiet, but the clock keeps counting
    sta SQ1_VOL
    rts
@sound:
    lda #%10111000          ; duty 10, constant volume 8
    sta SQ1_VOL
    lda #$00                ; sweep unit off — safe for every period in our
    sta SQ1_SWEEP           ; tables (the idle target stays under $7FF)
    lda tune_lo
    sta SQ1_LO
    lda tune_hi
    sta SQ1_HI              ; the high write restarts the note
    rts
