; Sprite Control Words
; Each sprite starts with two control words that set position:
;
; Word 0: [VSTART 7:0] << 8 | [HSTART 8:1]
;         ───────────       ───────────
;         Vertical start    Horizontal start / 2
;
; Word 1: [VSTOP 7:0] << 8 | [control bits]
;         ──────────        ──────────────
;         Vertical stop     V8, H8, attach, etc.

; For simple sprites (Y < 256, X < 512):
update_sprite:
            lea     frog_data,a0        ; Sprite data
            move.w  frog_y,d0           ; Y position
            move.w  frog_x,d1           ; X position

            ; Word 0: VSTART<<8 | HSTART>>1
            move.w  d0,d2
            lsl.w   #8,d2               ; VSTART to high byte
            lsr.w   #1,d1               ; HSTART / 2
            or.b    d1,d2               ; Combine
            move.w  d2,(a0)             ; Write word 0

            ; Word 1: VSTOP<<8
            add.w   #16,d0              ; VSTOP = VSTART + height
            lsl.w   #8,d0
            move.w  d0,2(a0)            ; Write word 1
            rts
