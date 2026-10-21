; SPDX-License-Identifier: MIT
; Deliberately wrong: ignore the last space and cut at capacity.
; BEGIN WRONG
    jmp layout_position ; WRONG: discard the saved word boundary
; END WRONG
; BEGIN FIX
    lda l_break_count
    cmp g_cmp
    beq layout_branch_82
    jmp layout_branch_81
layout_branch_82:
    jmp layout_position
layout_branch_81:
    lda l_break_count
    sta l_count
    lda l_break_i
    sta l_i
; END FIX
