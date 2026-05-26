;
; Minimal HALT verification — from Code198x → Emu198x investigation brief.
;
; Expected (with HALT working): BORDER stays one of two adjacent colours
;   (one OUT per frame, near the top scanline since HALT exits at frame start).
; Previously broken: BORDER renders as dense horizontal stripes (HALT
;   was falling through; main_loop ran millions of times per frame).
;

            org     32768

start:
            im      1
            ei

            xor     a
            out     ($FE), a            ; clear border

main_loop:
            halt
            ld      a, (debug_b)
            xor     7                   ; cycle through colour bits
            ld      (debug_b), a
            out     ($FE), a
            jr      main_loop

debug_b:    defb    0

            end     start
