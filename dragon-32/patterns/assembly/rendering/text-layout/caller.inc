L equ 1152
; SPDX-License-Identifier: MIT
; Original reset caller. No manufacturer firmware is distributed.
T equ $0400
TEXT_WIDTH equ 256
TEXT_HEIGHT equ 192
TEXT_PEN_MAX equ 1
; SPDX-License-Identifier: MIT
; Original reset fixture; mailbox is verification transport, not a game loop.
 org $8000
BP equ $0380
COMMAND equ $0300
start
    orcc #$50
    lds #$7f00
    ; Configure PIA1 B direction before its output data register.
    clr $ff23
    lda #$ff
    sta $ff22
    lda #4
    sta $ff23
    lda #$f0
    sta $ff22
    ; SAM V=110 for RG6; base $0600 = 3 * 512.
    sta $ffc0
    sta $ffc3
    sta $ffc5
    sta $ffc7
    sta $ffc9
    sta $ffca
    sta $ffcc
    sta $ffce
    sta $ffd0
    sta $ffd2
    ldx #$0600
clear_bitmap
    clr ,x+
    cmpx #$1e00
    bne clear_bitmap
    lda #$a5
    ldx #$05f0
set_guard
    sta ,x+
    cmpx #$0600
    bne set_guard
    ldx #$1e00
set_after
    sta ,x+
    cmpx #$1e10
    bne set_after
    clr COMMAND
    lda #$ef
    sta COMMAND+1
TEXT_PACKED equ 0
; A normal game call: eight-pixel advance, off-grid origin, opaque label.
    ldd #21
    std T+0
    ldd #37
    std T+2
    ldd #font_data
    std T+4
    ldd #label_data
    std T+6
    ldd #64
    std T+11
    ldd #0
    std T+18
    ldd #0
    std T+20
    ldd #256
    std T+22
    ldd #192
    std T+24
    lda #10
    sta T+8
    lda #65
    sta T+9
    lda #32
    sta T+10
    lda #63
    sta T+13
    lda #1
    sta T+14
    lda #1
    sta T+15
    lda #0
    sta T+16
    include "prepare.inc"
    lda #0
    sta COMMAND
    lda #239
    sta COMMAND+1
mailbox
    lda COMMAND
    beq mailbox
    cmpa #1
    bne do_string
    jsr layout_measure
    jmp complete
do_string
    cmpa #2
    bne do_clear
    jsr layout_line
    jmp complete
do_clear
    cmpa #4
    bne clear_only
    jsr layout_block
    jmp complete
clear_only
    jsr clear_screen
complete
    clr COMMAND
    jmp mailbox
clear_screen
    ldd #$0000
    std BP+0
    ldd #$0000
    std BP+2
    ldd #$0100
    std BP+4
    ldd #$00c0
    std BP+6
    lda #1
    sta BP+8
    lda #1
    sta BP+11
    jsr bp_fill
    rts
    include "../../../../../cross-platform/patterns/rendering/bitmap-text/6809.inc"
    include "../../../../../cross-platform/patterns/rendering/text-layout/6809.inc"
text_backend_start
    include "../../../../../cross-platform/patterns/rendering/drawing-foundations/6809.inc"
text_backend_end
font_data
    include "../../../../../cross-platform/patterns/rendering/bitmap-text/font-6809.inc"
font_end
label_data
    ifne CUSTOM_LAYOUT
    include "customise-message.inc"
    else
    include "demo-message.inc"
    endc
