;
; Shadowkeep Unit 7, Stage 3 — A Melody
;
; Stage 2's play_note can play one note. To play a *melody* we need a
; list of notes and a routine that walks the list. This stage introduces
; a `melody` data table — pairs of bytes, (pitch, duration) — and a
; player that reads each pair, calls play_note, and advances.
;
; The melody is a D-minor arpeggio: D5, F5, A5, D6, then descending back.
; Eight notes. The keep's first hummable phrase.
;
; The pitch values are calibrated so the play_note inner loop produces
; the right frequency for each note. See the table at end of file.
;

            org     32768

SPEAKER     equ     $10
TEMPO       equ     2                   ; cycles per duration unit (>>0 = scale)

start:
            im      1
            ei

            xor     a
            out     ($FE), a

            ld      hl, melody          ; HL = melody pointer
.next_note:
            ld      a, (hl)             ; pitch byte
            cp      $FF                 ; end-of-melody marker?
            jr      z, .done
            inc     hl
            ld      c, (hl)             ; duration byte
            inc     hl

            push    hl                  ; preserve melody pointer

            ; Expand 8-bit duration C to 16-bit cycle count in DE.
            ; cycles = C << 2 (TEMPO=2 → each tick is 4 cycles).
            ld      d, 0
            ld      e, c
            sla     e
            rl      d
            sla     e
            rl      d

            call    play_note

            pop     hl
            jr      .next_note

.done:
            xor     a
            out     ($FE), a
.idle:      halt
            jr      .idle

; ----------------------------------------------------------------------------
; play_note: see Stage 2 for the full commentary.
; ----------------------------------------------------------------------------

play_note:
            ld      h, a
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

; ----------------------------------------------------------------------------
; Melody table — D minor, eight notes plus a final D5 cadence.
;
; Pitch values calibrated for play_note's inner loop at 3.5MHz:
;   D5 = 227 (587 Hz)   F5 = 191 (698 Hz)   A5 = 151 (880 Hz)
;   D6 = 112 (1175 Hz)
;
; Duration is in driver ticks. With TEMPO=2 (above), each tick is 4 cycles.
;   Quarter note = 64 ticks (256 cycles) — for typical 100 BPM feel.
; ----------------------------------------------------------------------------

melody:
            defb    227, 64             ; D5 quarter
            defb    191, 64             ; F5 quarter
            defb    151, 64             ; A5 quarter
            defb    112, 128            ; D6 half
            defb    151, 64             ; A5 quarter
            defb    191, 64             ; F5 quarter
            defb    227, 128            ; D5 half
            defb    $FF                 ; end marker

            end     start
