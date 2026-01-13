; Life Icon Sprites
; Small frog shapes displayed using hardware sprites 1-3

; Sprite 1 (first life icon)
            even
life_icon_1:
            dc.w    $0000,$0000         ; Control words (set by code)
            dc.w    $0000,$0000
            dc.w    $1800,$0000         ; ..##............
            dc.w    $3c00,$0000         ; .####...........
            dc.w    $7e00,$0000         ; .######.........
            dc.w    $7e00,$0000         ; .######.........
            dc.w    $3c00,$0000         ; .####...........
            dc.w    $1800,$0000         ; ..##............
            dc.w    $0000,$0000
            dc.w    $0000,$0000         ; End marker

; Sprite 2 (second life icon)
            even
life_icon_2:
            dc.w    $0000,$0000
            dc.w    $0000,$0000
            dc.w    $1800,$0000
            dc.w    $3c00,$0000
            dc.w    $7e00,$0000
            dc.w    $7e00,$0000
            dc.w    $3c00,$0000
            dc.w    $1800,$0000
            dc.w    $0000,$0000
            dc.w    $0000,$0000

; Sprite 3 (third life icon)
            even
life_icon_3:
            dc.w    $0000,$0000
            dc.w    $0000,$0000
            dc.w    $1800,$0000
            dc.w    $3c00,$0000
            dc.w    $7e00,$0000
            dc.w    $7e00,$0000
            dc.w    $3c00,$0000
            dc.w    $1800,$0000
            dc.w    $0000,$0000
            dc.w    $0000,$0000
