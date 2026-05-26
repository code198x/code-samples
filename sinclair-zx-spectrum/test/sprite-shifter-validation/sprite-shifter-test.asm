;
; Sprite-shifter validation program
;
; Draws the test pattern (16x16, masked) at 8 successive sub-cell pixel
; positions across the screen, demonstrating all 8 pre-shifted variants.
;
; Expected visual: 8 copies of the test pattern, each starting at pixel
; columns 16, 33, 50, 67, 84, 101, 118, 135 - i.e., one per shift offset 0-7.
; Spacing 17 chosen so sprites don't overlap (each is 16 wide) AND
; consecutive columns hit each successive shift (17 mod 8 = 1).
;
; If a shifted version has off-by-one bugs, the asymmetric 3-sided border
; will be visibly misaligned. If the mask has bugs, the background colour
; between sprite-pixel regions will be wrong.
;
; Build: pasmonext --sna sprite-shifter-test.asm sprite-shifter-test.sna
;

            org     $8000

start:
            di
            im      1
            ei

            xor     a
            out     ($FE), a            ; black border

            call    clear_screen
            call    draw_all_shifts

.halt:      halt
            jr      .halt

; ----------------------------------------------------------------------------
; clear_screen - bitmap to 0; attribute to $38 (PAPER 7 white, INK 0 black)
; so that sprite-set pixels (image bit = 1) appear black against white paper.
; ----------------------------------------------------------------------------
clear_screen:
            ld      hl, $4000
            ld      de, $4001
            ld      (hl), 0
            ld      bc, 6143
            ldir

            ld      hl, $5800
            ld      de, $5801
            ld      (hl), $38
            ld      bc, 767
            ldir
            ret

; ----------------------------------------------------------------------------
; draw_all_shifts - draw the test pattern at 8 pixel positions spaced 9
; apart, each picking the correct pre-shifted variant via (col MOD 8).
; ----------------------------------------------------------------------------
draw_all_shifts:
            ld      a, 16
            ld      (cur_pixel_col), a
            ld      a, 64
            ld      (cur_pixel_row), a
            ld      b, 8
.loop:
            push    bc
            call    draw_one_shifted
            ld      a, (cur_pixel_col)
            add     a, 17               ; +17: 16 wide + 1 to advance shift
            ld      (cur_pixel_col), a
            pop     bc
            djnz    .loop
            ret

; ----------------------------------------------------------------------------
; draw_one_shifted - draw the test sprite at (cur_pixel_col, cur_pixel_row),
; picking the pre-shifted variant for (col MOD 8).
; ----------------------------------------------------------------------------
draw_one_shifted:
            ; DE = pointer to pre-shifted image+mask data for this column
            ld      a, (cur_pixel_col)
            and     7
            add     a, a                ; *2 (table entries are 16-bit pointers)
            ld      l, a
            ld      h, 0
            ld      de, shift_table
            add     hl, de
            ld      e, (hl)
            inc     hl
            ld      d, (hl)
            push    de                  ; preserve sprite pointer

            ; HL = screen address of top-left byte of sprite
            ld      a, (cur_pixel_row)
            call    row_to_screen_addr
            ld      a, (cur_pixel_col)
            srl     a
            srl     a
            srl     a                   ; A = col / 8 (byte column)
            ld      e, a
            ld      d, 0
            add     hl, de

            pop     de                  ; restore sprite data pointer
            call    draw_sprite_3w_16h
            ret

; ----------------------------------------------------------------------------
; draw_sprite_3w_16h - draw a 3-byte-wide, 16-row masked sprite.
;
; In:  HL = screen address (top-left byte of sprite)
;      DE = sprite data, interleaved (image, mask) pairs:
;           image_0, mask_0, image_1, mask_1, image_2, mask_2  (per row x 16)
;
; For each of the 3 screen bytes per row:
;   screen = (screen AND mask) OR image
; ----------------------------------------------------------------------------
draw_sprite_3w_16h:
            ld      b, 16
.row:
            push    hl                  ; save row start

            ; Byte 0
            ld      a, (de)             ; image
            ld      c, a
            inc     de
            ld      a, (de)             ; mask
            inc     de
            and     (hl)
            or      c
            ld      (hl), a
            inc     l

            ; Byte 1
            ld      a, (de)
            ld      c, a
            inc     de
            ld      a, (de)
            inc     de
            and     (hl)
            or      c
            ld      (hl), a
            inc     l

            ; Byte 2
            ld      a, (de)
            ld      c, a
            inc     de
            ld      a, (de)
            inc     de
            and     (hl)
            or      c
            ld      (hl), a

            pop     hl                  ; restore row start
            call    next_scanline

            djnz    .row
            ret

; ----------------------------------------------------------------------------
; row_to_screen_addr - in: A = pixel row (0..191). out: HL = $4000 + addr
; of column 0 for that row.
;
;   addr = $4000 | ((row & $C0) << 5) | ((row & $07) << 8) | ((row & $38) << 2)
; ----------------------------------------------------------------------------
row_to_screen_addr:
            push    af
            and     $C0                 ; A = row & $C0 (which third)
            rrca
            rrca
            rrca                        ; >>= 3, lands in high-byte's low bits
            or      $40                 ; OR base $40
            ld      h, a

            pop     af
            push    af
            and     $07                 ; A = row & 7
            or      h
            ld      h, a

            pop     af
            and     $38                 ; A = row & $38 (cell-row within third)
            rlca
            rlca                        ; <<= 2, lands in low-byte's high bits
            ld      l, a
            ret

; ----------------------------------------------------------------------------
; next_scanline - HL += one bitmap scanline.
;
; Within a cell-row, next scanline is HL + $0100. At every cell-row boundary
; (8 scanlines), wrap: H -= 8, L += $20. If L overflows out of a third,
; H += 8 to land in the next third.
; ----------------------------------------------------------------------------
next_scanline:
            inc     h
            ld      a, h
            and     $07
            ret     nz                  ; still inside the same cell-row

            ld      a, h
            sub     8
            ld      h, a
            ld      a, l
            add     a, $20
            ld      l, a
            ret     nc                  ; clean cell-row crossing within a third

            ld      a, h
            add     a, 8
            ld      h, a
            ret

; ----------------------------------------------------------------------------
; Shift table - one pointer per sub-cell shift 0..7.
; ----------------------------------------------------------------------------
shift_table:
            defw    test_pattern_shift_0
            defw    test_pattern_shift_1
            defw    test_pattern_shift_2
            defw    test_pattern_shift_3
            defw    test_pattern_shift_4
            defw    test_pattern_shift_5
            defw    test_pattern_shift_6
            defw    test_pattern_shift_7

cur_pixel_col:  defb 0
cur_pixel_row:  defb 0

            include "test_pattern.inc"

            end     start
