VERSION_X       equ     240
VERSION_Y       equ     248

version_string: dc.b    "V1.0",0
            even

draw_version:
            lea     version_string,a0
            move.w  #VERSION_X,d0
            move.w  #VERSION_Y,d1
            bsr     draw_string
            rts
