; SID note trigger demonstration: one note on voice 1.
; Target: C64 PAL, loaded at $0801 and started with RUN.

* = $0801
    !byte $0b, $08, $0a, $00, $9e   ; 10 SYS 2064
    !text "2064"
    !byte $00, $00, $00

* = $0810
SID_VOICE = $d400                   ; voice 1

start:
    lda #$0f                        ; volume 15, no filter, voice 3 audible
    sta $d418
    lda #$00                        ; attack 0, decay 0
    ldx #$f9                        ; sustain 15, release 9
    jsr sid_voice_setup
    ldy #25                         ; half a second of silence first
    jsr wait_frames

    lda #$11                        ; C4 on PAL: $1167
    ldx #$67
    jsr sid_note_on
    ldy #25                         ; hold for half a second
    jsr wait_frames
    jsr sid_note_off
    ldy #50                         ; let the release finish
    jsr wait_frames

    lda #1
    sta done
finished:
    jmp finished

; Wait Y frames (Y = 1-255), timing each frame by raster line 255.
wait_frames:
    lda $d012
    cmp #$ff
    bne wait_frames
wait_line_end:
    lda $d012
    cmp #$ff
    beq wait_line_end
    dey
    bne wait_frames
    rts

!source "sid-note.inc"

done:
    !byte 0
