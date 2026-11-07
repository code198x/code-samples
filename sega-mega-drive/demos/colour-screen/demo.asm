; An original colour display. No game data or firmware.
        dc.l $00fffe00,start
        dcb.b 248,0
        dc.b "SEGA MEGA DRIVE "
        dcb.b 240,0
start:
        move.w #$2700,sr
        move.w #$8144,$c00004
        move.w #$8c81,$c00004
        move.w #$8701,$c00004
        move.l #$c0020000,$c00004
        move.w #$000e,$c00000
forever:
        bra.s forever

        dcb.b 1488,0
