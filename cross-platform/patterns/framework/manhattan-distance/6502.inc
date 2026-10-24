; SPDX-License-Identifier: MIT
; Manhattan Distance. Bind these contiguous private bytes: AX, AY, BX, BY, DIST_LO, DIST_HI.
; init clears the whole block; step uses current inputs. No I/O, waits or IRQ owner.
; A/X/flags may change; Y and decimal mode survive. Binary arithmetic requires D=0.
manhattan_distance_init:
    lda #0
    sta AX
    sta AY
    sta BX
    sta BY
    sta DIST_LO
    sta DIST_HI
    rts
manhattan_distance_step:
    lda #0
    sta DIST_HI
    lda AX
    cmp BX
    bcs distance_x
    lda BX
    sec
    sbc AX
    jmp distance_save
 distance_x:
    sec
    sbc BX
distance_save:
    sta DIST_LO
    lda AY
    cmp BY
    bcs distance_y
    lda BY
    sec
    sbc AY
    jmp distance_add
 distance_y:
    sec
    sbc BY
distance_add:
    clc
    adc DIST_LO
    sta DIST_LO
    bcc distance_done
    inc DIST_HI
distance_done:
    rts
component_end:
