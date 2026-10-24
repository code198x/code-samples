; SPDX-License-Identifier: MIT
; A Bounded Event Queue. Bind these contiguous private bytes: HEAD, TAIL, COUNT, VALUE, MODE, OK, B0, B1, B2, B3.
; init clears the whole block; step uses current inputs. No I/O, waits or IRQ owner.
; A/X/flags may change; Y and decimal mode survive. Binary arithmetic requires D=0.
event_queue_init:
    lda #0
    sta HEAD
    sta TAIL
    sta COUNT
    sta VALUE
    sta MODE
    sta OK
    sta B0
    sta B1
    sta B2
    sta B3
    rts
event_queue_step:
    lda #0
    sta OK
    lda MODE
    cmp #1
    beq queue_push
    cmp #2
    bne queue_done
    lda COUNT
    beq queue_done
    ldx HEAD
    lda B0,x
    sta VALUE
    inx
    cpx #QUEUE_CAP
    bcc queue_pop_index
    ldx #0
queue_pop_index:
    stx HEAD
    dec COUNT
    jmp queue_success
queue_push:
    lda COUNT
    cmp #QUEUE_CAP
    bcs queue_done
    ldx TAIL
    lda VALUE
    sta B0,x
    inx
    cpx #QUEUE_CAP
    bcc queue_push_index
    ldx #0
queue_push_index:
    stx TAIL
    inc COUNT
queue_success:
    inc OK
queue_done:
    rts
component_end:
