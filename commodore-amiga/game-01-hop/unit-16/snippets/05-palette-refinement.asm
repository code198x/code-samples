; Title screen palette - cooler blues
title_palette:
            dc.w    $0113               ; Dark blue background
            dc.w    $0fff               ; White
            dc.w    $08af               ; Light blue
            dc.w    $0248               ; Dark blue

; Gameplay palette - warmer, more contrast
game_palette:
            dc.w    $0000               ; Black background
            dc.w    $0fff               ; White
            dc.w    $00f0               ; Green
            dc.w    $0f00               ; Red

set_title_palette:
            lea     title_palette,a0
            bra.s   set_palette_common

set_game_palette:
            lea     game_palette,a0

set_palette_common:
            lea     copper_palette+2,a1
            moveq   #3,d0
.loop:
            move.w  (a0)+,(a1)
            addq.l  #4,a1               ; Skip copper instruction
            dbf     d0,.loop
            rts
