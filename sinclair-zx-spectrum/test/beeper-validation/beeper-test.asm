;
; Beeper music pipeline validation
;
; Plays the compiled test_melody using a custom one-voice beeper routine -
; deliberately avoiding ROM BEEP so the teaching code has no ROM dependencies.
;
; Each table entry is 4 bytes:
;   defw period      ; inner-delay count (16-bit). 0 = special marker.
;   defw cycles      ; full cycles to emit, or, if period==0, rest frame count
; End of score: period == 0 AND cycles == 0.
;
; Per-cycle T-state cost of play_tone is 52 * period + 115 (see comments
; on play_tone for the breakdown). Compile time uses the same formula
; (see tools/compile_music.py).
;
; Build:
;   docker run --rm -v ../../..:/code-samples \
;       -w /code-samples/sinclair-zx-spectrum/test/beeper-validation \
;       ghcr.io/code198x/sinclair-zx-spectrum:latest \
;       pasmonext --sna beeper-test.asm beeper-test.sna
;

            org     $8000

SPK_BIT     equ $10                     ; speaker bit on port $FE

start:
            di
            im      1
            ei

            xor     a
            out     ($FE), a            ; black border, speaker off

            call    play_score

.done:      halt
            jr      .done

; ----------------------------------------------------------------------------
; play_score - walk the test_melody table. Tone events call play_tone; rest
; events HALT for the given frame count.
; ----------------------------------------------------------------------------
play_score:
            ld      ix, test_melody
.next:
            ; HL = period
            ld      l, (ix+0)
            ld      h, (ix+1)
            ; DE = cycles (or frame count if period==0)
            ld      e, (ix+2)
            ld      d, (ix+3)

            ld      a, h
            or      l
            jr      nz, .note           ; period != 0 -> tone

            ld      a, d
            or      e
            ret     z                   ; period==0 AND cycles==0 -> end

            ; period==0, cycles != 0 -> rest for DE frames
            call    rest_de_frames
            jr      .advance

.note:
            ; HL = period, DE = cycles
            push    ix
            ld      b, d
            ld      c, e                ; BC = cycles; HL = period unchanged
            call    play_tone
            pop     ix

.advance:
            ld      bc, 4
            add     ix, bc
            jr      .next

; ----------------------------------------------------------------------------
; play_tone - emit BC complete square-wave cycles with half-cycle delay
; controlled by HL.
;
; In:  HL = period count (inner-loop iterations per half-cycle)
;      BC = number of complete cycles
; Out: BC = 0, HL preserved.
;
; T-state accounting per full cycle:
;   half-cycle 1: ld a,$10(7) + out(11) + push hl(11) + delay + pop hl(10) = 39 + delay
;   half-cycle 2: xor a(4)    + out(11) + push hl(11) + delay + pop hl(10) = 36 + delay
;   delay:        (N-1)*26 + 21 = 26N - 5
;   bookkeeping:  dec bc(6) + ld a,b(4) + or c(4) + jr nz(12) = 26
;   full cycle:   52N + 91 T-states.
;
; For F Hz at 3.5 MHz: full cycle = 3500000/F T-states. N = round((3500000/F - 91)/52).
;
; Note: the 50Hz IM 1 interrupt will introduce ~30us of jitter per frame
; (the keyboard-scan ISR takes around 100 T-states inside the active note).
; That's inaudible — well below a semitone. We don't need DI here.
; ----------------------------------------------------------------------------
play_tone:
.cycle:
            ld      a, SPK_BIT
            out     ($FE), a            ; speaker high
            push    hl
.d1:
            dec     hl
            ld      a, h
            or      l
            jr      nz, .d1
            pop     hl

            xor     a
            out     ($FE), a            ; speaker low
            push    hl
.d2:
            dec     hl
            ld      a, h
            or      l
            jr      nz, .d2
            pop     hl

            dec     bc
            ld      a, b
            or      c
            jr      nz, .cycle
            ret

; ----------------------------------------------------------------------------
; rest_de_frames - block until DE 50Hz frame interrupts have fired.
; ----------------------------------------------------------------------------
rest_de_frames:
.r:
            halt
            dec     de
            ld      a, d
            or      e
            jr      nz, .r
            ret

; ----------------------------------------------------------------------------
; Compiled score data
; ----------------------------------------------------------------------------
            include "test_melody.inc"

            end     start
