; Letter font for title/game over text
; Letters indexed: A=0, E=1, G=2, I=3, L=4, M=5, N=6, O=7, R=8, S=9, V=10
; Same 8x8 format as digit font (16 bytes per glyph)

            even
letter_font:
; A (index 0)
            dc.w    $3c00           ; ..XXXX..
            dc.w    $6600           ; .XX..XX.
            dc.w    $6600           ; .XX..XX.
            dc.w    $7e00           ; .XXXXXX.
            dc.w    $6600           ; .XX..XX.
            dc.w    $6600           ; .XX..XX.
            dc.w    $6600           ; .XX..XX.
            dc.w    $0000           ; ........
; E (index 1)
            dc.w    $7e00           ; .XXXXXX.
            dc.w    $6000           ; .XX.....
            dc.w    $6000           ; .XX.....
            dc.w    $7c00           ; .XXXXX..
            dc.w    $6000           ; .XX.....
            dc.w    $6000           ; .XX.....
            dc.w    $7e00           ; .XXXXXX.
            dc.w    $0000           ; ........
; ... (more letters follow same pattern)

; Text data - "SIGNAL" as indices into letter_font
title_text:
            dc.w    9,3,2,6,0,4     ; S=9, I=3, G=2, N=6, A=0, L=4

; Text data - "GAME OVER" (99 = space character)
gameover_text:
            dc.w    2,0,5,1,99,7,10,1,8     ; G A M E _ O V E R
