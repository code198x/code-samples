;
; Shadowkeep Unit 7, Stage 2 — Two Notes
;
; Stage 1 toggled bit 4 at a fixed rate. The pitch was hard-coded as a
; constant. To play a *melody* we need two things this stage adds:
;
;   1. A note as a parameterised subroutine. `play_note` takes a pitch
;      and a duration; it toggles bit 4 at the given pitch for the given
;      number of half-cycles, then returns.
;
;   2. A 16-bit `duration` counter that controls how long each note
;      plays. 8 bits (max 255 half-cycles) isn't long enough — at our
;      pitch a single tone fades inside 100ms. We need DE as a 16-bit
;      half-cycle count to get audible note lengths.
;
; This stage plays two notes back-to-back. Lower pitch first (longer
; toggle wait), then higher pitch. You hear "boop... beep."
;

            org     32768

SPEAKER     equ     $10

; Pitch values are inner-loop counts. Empirical calibration: at PITCH=80
; the loop produces about 1.26kHz (roughly D#6). Higher PITCH = lower
; frequency. The two notes here are chosen far enough apart that the
; pitch difference is clear when listened to.
NOTE_LOW    equ     180                 ; roughly G5
NOTE_HIGH   equ     90                  ; roughly C6
TICKS_LO    equ     1500                ; ~1 second at NOTE_LOW
TICKS_HI    equ     2200                ; ~1 second at NOTE_HIGH

start:
            im      1
            ei

            xor     a
            out     ($FE), a

            ld      a, NOTE_LOW
            ld      de, TICKS_LO
            call    play_note

            ld      a, NOTE_HIGH
            ld      de, TICKS_HI
            call    play_note

            ; Done. Settle the speaker, then idle.
            xor     a
            out     ($FE), a
.idle:      halt
            jr      .idle

; ----------------------------------------------------------------------------
; play_note: toggle bit 4 of port $FE at the pitch in A, for DE
; half-cycles. Caller's choice of pitch and duration.
;
; In:  A  = pitch (inner-loop count for one half-cycle)
;      DE = duration (number of half-cycles to play; 16-bit)
;
; Trashes A, B, DE.
; ----------------------------------------------------------------------------

play_note:
            ld      h, a                ; preserve pitch in H
.cycle:
            ld      a, SPEAKER
            out     ($FE), a
            ld      b, h
.h_up:      djnz    .h_up

            xor     a
            out     ($FE), a
            ld      b, h
.h_dn:      djnz    .h_dn

            dec     de
            ld      a, d
            or      e
            jr      nz, .cycle
            ret

            end     start
