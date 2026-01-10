; The Spectrum keyboard is arranged in 8 half-rows
; Each half-row is read via port $FE with the high byte selecting the row

ROW_CAPS_V  equ $FE         ; CAPS SHIFT, Z, X, C, V
ROW_A_G     equ $FD         ; A, S, D, F, G
ROW_Q_T     equ $FB         ; Q, W, E, R, T
ROW_1_5     equ $F7         ; 1, 2, 3, 4, 5
ROW_0_6     equ $EF         ; 0, 9, 8, 7, 6
ROW_P_Y     equ $DF         ; P, O, I, U, Y
ROW_ENT_H   equ $BF         ; ENTER, L, K, J, H
ROW_SPC_B   equ $7F         ; SPACE, SYM SHIFT, M, N, B

; Within each row, keys are in bits 0-4 (right to left)
; Keys are ACTIVE LOW: 0 = pressed, 1 = not pressed
