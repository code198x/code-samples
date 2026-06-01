; ============================================================================
; PRIMER — Beat 2: LD Is Not LET
; ============================================================================
; In BASIC, LET a = 5 gave you as many named variables as you liked. The CPU
; doesn't work that way. It has a *handful* of registers — physical stores
; inside the chip, each holding one 8-bit number (0 to 255). Their names are
; fixed: A, B, C, D, E, H, L. You don't make more; you orchestrate these few.
;
; LD means "load", and all it ever does is move a number — into a register,
; or from one register to another. To prove a value really moves, we take it
; on a round trip and watch it come back:
;
;   1. Put 5 into A.            (5 = cyan)
;   2. Copy A into B.           (now B holds 5 too)
;   3. Wipe A back to 0.        (A = 0; if we stopped here the border'd be black)
;   4. Copy B back into A.      (A = 5 again — the 5 was safe in B all along)
;   5. Show A on the border.    (cyan proves B kept our 5)
;
; Open the register view in Emu198x and watch A and B change at each step.
; The border is just the visible proof; the registers are the lesson.
; ============================================================================

            org     32768

start:
            ld      a, 5             ; put 5 into A           (5 = cyan)
            ld      b, a             ; copy A into B          (B now holds 5 too)
            ld      a, 0             ; wipe A                 (A = 0; B still holds 5)
            ld      a, b             ; copy B back into A     (A = 5 again, from B)
            out     ($FE), a         ; show A on the border   (only A can do OUT)

.loop:
            halt
            jr      .loop

            end     start
