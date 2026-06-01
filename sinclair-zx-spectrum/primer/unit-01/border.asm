; ============================================================================
; PRIMER — Beat 1: Assemble and Run
; ============================================================================
; This is the whole program. Three things happen, no more:
;
;   1. We put a number into the register A.
;   2. We send that number to the border, through port $FE.
;   3. We stop, holding the picture still.
;
; The point of this beat is not the border. The point is the *loop you just
; ran*: you wrote text, an assembler turned it into a program, and the machine
; ran it. There is a build step now. That is the whole idea.
;
; The border is just the quickest thing on the Spectrum to change — one
; instruction, and you can see it the instant the program runs.
; ============================================================================

            org     32768           ; load our program at address 32768

start:
            ld      a, 2             ; 2 is red (the border reads the low 3 bits)
            out     ($FE), a         ; send it to port $FE — the border changes

; ----------------------------------------------------------------------------
; Hold the picture. HALT waits for the next interrupt (50 times a second);
; the jump sends us straight back to wait again. Without this the program
; would run off the end into whatever bytes follow, and the machine would do
; something we never asked for.
; ----------------------------------------------------------------------------
.loop:
            halt
            jr      .loop

            end     start
