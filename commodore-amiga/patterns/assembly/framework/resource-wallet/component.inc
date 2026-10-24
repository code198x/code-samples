; SPDX-License-Identifier: MIT
; Resource Counters. Bind these contiguous private bytes: BALANCE, AMOUNT, MODE, OK.
; init clears the whole block; step uses current inputs. No I/O, waits or IRQ owner.
; D0-D3/A0-A1/CCR may change; D4-D7/A2-A6 survive.
resource_wallet_init:
    clr.b BALANCE
    clr.b AMOUNT
    clr.b MODE
    clr.b OK
    rts
resource_wallet_step:
    clr.b OK
    move.b MODE,d0
    beq.s wallet_add
    cmp.b #1,d0
    bne.s wallet_done
    move.b BALANCE,d0
    cmp.b AMOUNT,d0
    blo.s wallet_done
    sub.b AMOUNT,d0
    bra.s wallet_store
wallet_add:
    move.b BALANCE,d0
    add.b AMOUNT,d0
    bcc.s wallet_store
    move.b #255,d0
wallet_store:
    move.b d0,BALANCE
    move.b #1,OK
wallet_done:
    rts
component_end:
