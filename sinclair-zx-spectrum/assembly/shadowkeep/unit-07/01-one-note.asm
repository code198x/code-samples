;
; Shadowkeep Unit 7, Stage 1 — One Note
;
; The Spectrum's beeper is bit 4 of port $FE. The same port that carries
; the BORDER colour (bits 0-2), the MIC line (bit 3), and the keyboard
; (read side) carries the speaker too. To produce a tone, you toggle
; bit 4 at a steady rate. That's the whole technique.
;
; This stage plays a single fixed-pitch tone. Two halves of every cycle:
; speaker high (bit 4 set), wait, speaker low (bit 4 clear), wait. The
; wait controls the pitch — longer wait = lower pitch.
;
; Run the program. You hear a steady tone.
;

            org     32768

SPEAKER     equ     $10                 ; bit 4 of port $FE
PITCH       equ     80                  ; inner-loop count; lower = higher pitch

start:
            im      1
            ei

            xor     a
            out     ($FE), a            ; BORDER black, speaker low

tone_loop:
            ld      a, SPEAKER
            out     ($FE), a            ; speaker high
            ld      b, PITCH
.half_high:
            djnz    .half_high

            xor     a
            out     ($FE), a            ; speaker low
            ld      b, PITCH
.half_low:
            djnz    .half_low

            jr      tone_loop           ; forever

            end     start
