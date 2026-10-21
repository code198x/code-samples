; SPDX-License-Identifier: MIT
; Deliberately wrong: ignore the last space and cut at capacity.
; BEGIN WRONG
    jp layout_position ; WRONG: discard the saved word boundary
; END WRONG
; BEGIN FIX
    ld a,(l_break_count)
    ld b,a
    ld a,(g_cmp)
    ld c,a
    ld a,b
    cp c
    jp nz,layout_branch_28
    jp layout_position
layout_branch_28:
    ld a,(l_break_count)
    ld (l_count),a
    ld a,(l_break_i)
    ld (l_i),a
; END FIX
