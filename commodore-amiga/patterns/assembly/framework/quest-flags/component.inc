; SPDX-License-Identifier: MIT
; Quest and Inventory Flags. Bind these contiguous private bytes: FLAGS, MASK, MODE, ALL_SET.
; init clears the whole block; step uses current inputs. No I/O, waits or IRQ owner.
; D0-D3/A0-A1/CCR may change; D4-D7/A2-A6 survive.
quest_flags_init:
    clr.b FLAGS
    clr.b MASK
    clr.b MODE
    clr.b ALL_SET
    rts
quest_flags_step:
    move.b MODE,d0
    cmp.b #1,d0
    beq.s flags_set
    cmp.b #2,d0
    bne.s flags_test
    move.b MASK,d0
    not.b d0
    and.b d0,FLAGS
    bra.s flags_test
flags_set:
    move.b MASK,d0
    or.b d0,FLAGS
flags_test:
    clr.b ALL_SET
    move.b FLAGS,d0
    and.b MASK,d0
    cmp.b MASK,d0
    bne.s flags_done
    move.b #1,ALL_SET
flags_done:
    rts
component_end:
