; SPDX-License-Identifier: MIT
; Quest and Inventory Flags. Bind these contiguous private bytes: FLAGS, MASK, MODE, ALL_SET.
; init clears the whole block; step uses current inputs. No I/O, waits or IRQ owner.
; A/X/flags may change; Y and decimal mode survive. Binary arithmetic requires D=0.
quest_flags_init:
    lda #0
    sta FLAGS
    sta MASK
    sta MODE
    sta ALL_SET
    rts
quest_flags_step:
    lda MODE
    cmp #1
    beq flags_set
    cmp #2
    bne flags_test
    lda MASK
    eor #255
    and FLAGS
    sta FLAGS
    jmp flags_test
flags_set:
    lda FLAGS
    ora MASK
    sta FLAGS
flags_test:
    lda #0
    sta ALL_SET
    lda FLAGS
    and MASK
    cmp MASK
    bne flags_done
    inc ALL_SET
flags_done:
    rts
component_end:
