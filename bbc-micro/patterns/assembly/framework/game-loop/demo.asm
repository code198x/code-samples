; BBC Model B, MOS 1.20/BASIC II. Enter generated loader.bas, RUN.
; Space holds slow CPU work. MOS services own IRQ/video/keyboard. Reset to leave.
*=$3000
OSWRCH=$ffee
start:
    cli
    lda #0
    sta updates
    sta updates+1
    sta slow
main_loop:
    jsr wait_frame
    jsr read_input
    jsr update_game
    jsr draw_screen
    jsr expensive_work
frame_done:
    jmp main_loop
read_input:
    lda #129
    ldx #$9d                 ; INKEY(-99): Space
    ldy #$ff
    jsr OSBYTE
    stx slow                 ; $ff held, 0 released
    rts
update_game:
    inc updates
    bne update_done
    inc updates+1
update_done:
    rts
draw_screen:
    lda #31                  ; VDU 31: fixed text position, then a changing digit
    jsr OSWRCH
    lda #10
    jsr OSWRCH
    lda #8
    jsr OSWRCH
    lda updates
    lsr
    lsr
    lsr
    and #7
    clc
    adc #48
    jmp OSWRCH
expensive_work:
    lda slow
    beq work_done
    ldy #64
work_outer:
    ldx #0
work_inner:
    dex
    bne work_inner
    dey
    bne work_outer
work_done:
    rts
updates: !word 0
slow: !byte 0
!source "frame.inc"
