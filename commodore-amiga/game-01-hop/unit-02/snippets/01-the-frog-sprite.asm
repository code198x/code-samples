frog_data:
            ; Control words
            dc.w    $b460           ; VSTART=$B4 (line 180), HSTART=$60 (pos 192)
            dc.w    $c400           ; VSTOP=$C4 (line 196), control=0

            ; 16 lines of pixel data (bitplane 0, bitplane 1)
            dc.w    $0000,$0000     ; ................
            dc.w    $07e0,$0000     ; .....XXXXXX.....
            dc.w    $1ff8,$0420     ; ...XXXXXXXXXXX..
            dc.w    $3ffc,$0a50     ; ..XXXXXXXXXXXXX.
            dc.w    $7ffe,$1248     ; .XXXXXXXXXXXXXXX
            dc.w    $7ffe,$1008     ; .XXXXXXXXXXXXXXX
            dc.w    $ffff,$2004     ; XXXXXXXXXXXXXXXX
            dc.w    $ffff,$0000     ; XXXXXXXXXXXXXXXX
            dc.w    $ffff,$0000     ; XXXXXXXXXXXXXXXX
            dc.w    $7ffe,$2004     ; .XXXXXXXXXXXXXXX
            dc.w    $7ffe,$1008     ; .XXXXXXXXXXXXXXX
            dc.w    $3ffc,$0810     ; ..XXXXXXXXXXXXX.
            dc.w    $1ff8,$0420     ; ...XXXXXXXXXXX..
            dc.w    $07e0,$0000     ; .....XXXXXX.....
            dc.w    $0000,$0000     ; ................
            dc.w    $0000,$0000     ; ................

            ; End marker
            dc.w    $0000,$0000
