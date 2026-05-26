;
; Shadowkeep Unit 7, Stage 4 — The Theme
;
; Stage 3 played a melody once and stopped. A title theme has to *loop*
; — play forever until the player presses a key to start the game. This
; stage adds the loop, plus an extended D-minor phrase that builds on
; Stage 3's arpeggio: rising figure, descending response, a held cadence
; back to the tonic. Twelve notes plus the loop marker.
;
; The loop format follows the Shadowkeep beeper-spec (see
; wiki/curriculum/shadowkeep-beeper-spec.md): each note is a (pitch,
; duration) byte pair. A $00 pitch is a rest (speaker stays low). A
; $FF $FF pair is the loop marker — when the player reaches it, the
; pointer resets to the start of the melody.
;
; The result is the keep's first voice: a slow, sombre, dignified theme
; in D minor that plays under the title and loops until the thief moves.
;

            org     32768

SPEAKER     equ     $10
LOOP_MARK   equ     $FF
REST        equ     $00

start:
            im      1
            ei

            xor     a
            out     ($FE), a            ; BORDER black

            ; Blank the screen to black-on-black: bitmap = 0, attrs = $00.
            ; The keep is heard before it's seen. Unit 8 puts the picture in.
            ld      hl, $4000
            ld      de, $4001
            ld      (hl), 0
            ld      bc, 6143
            ldir
            ld      hl, $5800
            ld      de, $5801
            ld      (hl), $00           ; INK 0, PAPER 0
            ld      bc, 767
            ldir

play_theme:
            ld      hl, melody
.next_note:
            ld      a, (hl)             ; pitch byte
            cp      LOOP_MARK
            jr      z, play_theme       ; $FF -> restart from top
            inc     hl
            ld      c, (hl)             ; duration byte
            inc     hl

            cp      REST
            jr      z, .play_rest

            push    hl                  ; preserve melody pointer

            ; Expand 8-bit duration C to 16-bit cycle count in DE
            ; via two left-shifts (cycles = C << 2).
            ld      d, 0
            ld      e, c
            sla     e
            rl      d
            sla     e
            rl      d

            call    play_note

            pop     hl
            jr      .next_note

.play_rest:
            ; Rest: hold speaker low for the duration. Same timing as
            ; play_note's loop but without toggling bit 4. Approximated
            ; by a delay calibrated to feel like one tick at PITCH 150.
            push    hl
            xor     a
            out     ($FE), a
            ld      b, c
.rest_outer:
            ld      a, 150
.rest_inner:
            dec     a
            jr      nz, .rest_inner
            djnz    .rest_outer
            pop     hl
            jr      .next_note

; ----------------------------------------------------------------------------
; play_note — pitch in A, 16-bit duration in DE. See Stage 2.
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
; The Shadowkeep title theme — D minor, 12 notes + a brief rest, looping.
;
; Phrase 1 (bars 1-2): rising D-minor arpeggio with a strong landing on D6.
;   D5 quarter — F5 quarter — A5 quarter — D6 half
;
; Phrase 2 (bars 3-4): descending response, resolving on D5.
;   C6 quarter — A5 quarter — F5 quarter — E5 quarter — D5 half
;
; Cadence (bar 5): a beat of silence, then a low D5 to ground the loop.
;   rest quarter — D5 whole — D5 (held long via second whole)
;
; The full theme runs ~6 seconds at the calibrated tempo, then loops.
;
; Pitch values (calibrated for play_note's inner loop at 3.5 MHz):
;   D5=227 (587 Hz)   E5=202 (659 Hz)   F5=191 (698 Hz)   G5=170 (784 Hz)
;   A5=151 (880 Hz)   B5=135 (988 Hz)   C6=126 (1047 Hz)  D6=112 (1175 Hz)
;
; Durations are in driver ticks (each tick = 4 cycles via TEMPO=2):
;   quarter = 64, half = 128, whole = 255 (just under a full whole).
; ----------------------------------------------------------------------------

melody:
            ; Phrase 1 — the rise.
            defb    227, 64             ; D5 quarter
            defb    191, 64             ; F5 quarter
            defb    151, 64             ; A5 quarter
            defb    112, 128            ; D6 half

            ; Phrase 2 — the descent.
            defb    126, 64             ; C6 quarter
            defb    151, 64             ; A5 quarter
            defb    191, 64             ; F5 quarter
            defb    202, 64             ; E5 quarter
            defb    227, 128            ; D5 half

            ; Cadence — silence, then a low tonic to land the loop.
            defb    REST, 32            ; brief rest
            defb    227, 255            ; D5 whole-ish (held)

            defb    LOOP_MARK           ; $FF: return to `melody`

            end     start
