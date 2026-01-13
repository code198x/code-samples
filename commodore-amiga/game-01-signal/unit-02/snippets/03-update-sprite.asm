; Update Sprite Control Words
; Pack X/Y coordinates into hardware sprite format

FROG_HEIGHT     equ 16

update_sprite:
            lea     frog_data,a0
            move.w  frog_y,d0           ; Y position
            move.w  frog_x,d1           ; X position

            ; First control word: VSTART<<8 | HSTART>>1
            move.w  d0,d2
            lsl.w   #8,d2               ; VSTART in high byte
            lsr.w   #1,d1               ; HSTART / 2
            or.b    d1,d2               ; Combine
            move.w  d2,(a0)             ; Write to sprite data

            ; Second control word: VSTOP<<8 | control bits
            add.w   #FROG_HEIGHT,d0     ; VSTOP = VSTART + height
            lsl.w   #8,d0               ; VSTOP in high byte
            move.w  d0,2(a0)            ; Write to sprite data
            rts

; Sprite control word format:
; Word 0: [VSTART 7:0] [HSTART 8:1]
; Word 1: [VSTOP 7:0] [V8 H8 ATT SH V0]
