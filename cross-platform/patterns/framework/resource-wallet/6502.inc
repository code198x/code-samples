; SPDX-License-Identifier: MIT
; Resource Counters. Bind these contiguous private bytes: BALANCE, AMOUNT, MODE, OK.
; init clears the whole block; step uses current inputs. No I/O, waits or IRQ owner.
; A/X/flags may change; Y and decimal mode survive. Binary arithmetic requires D=0.
resource_wallet_init:
    lda #0
    sta BALANCE
    sta AMOUNT
    sta MODE
    sta OK
    rts
resource_wallet_step:
    lda #0
    sta OK
    lda MODE
    beq wallet_add
    cmp #1
    bne wallet_done
    lda BALANCE
    cmp AMOUNT
    bcc wallet_done
    sec
    sbc AMOUNT
    jmp wallet_store
wallet_add:
    lda BALANCE
    clc
    adc AMOUNT
    bcc wallet_store
    lda #255
wallet_store:
    sta BALANCE
    lda #1
    sta OK
wallet_done:
    rts
component_end:
