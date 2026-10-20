; SPDX-License-Identifier: MIT
; Original reset caller. No manufacturer firmware is distributed.
G equ $0400
GEO_WIDTH equ 256
GEO_HEIGHT equ 192
GEO_PEN_MAX equ 255
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
; A normal game call: an outlined ellipse. Setup and mailbox are separate.
    ldd #$0050
    std G+0
    ldd #$0046
    std G+2
    ldd #$0030
    std G+4
    ldd #$0018
    std G+6
    ldd #$0000
    std G+12
    ldd #$0000
    std G+14
    ldd #$0100
    std G+16
    ldd #$00c0
    std G+18
    lda #0
    sta G+8
    lda #0
    sta G+9
    lda #1
    sta G+11
    jsr geo_ellipse
    lda #0
    sta COMMAND
    lda #239
    sta COMMAND+1
mailbox
    lda COMMAND
    beq mailbox
    cmpa #1
    bne command_2
    jsr geo_line
    jmp complete
command_2
    cmpa #2
    bne command_3
    jsr geo_circle
    jmp complete
command_3
    cmpa #3
    bne command_4
    jsr geo_ellipse
    jmp complete
command_4
    cmpa #4
    bne command_5
    jsr geo_fill_circle
    jmp complete
command_5
    cmpa #5
    bne command_6
    jsr geo_fill_ellipse
    jmp complete
command_6
    cmpa #6
    bne command_7
    jsr bp_pixel
    jmp complete
command_7
    cmpa #7
    bne command_8
    jsr bp_read
    jmp complete
command_8
    cmpa #8
    bne command_9
    jsr bp_hspan
    jmp complete
command_9
    cmpa #9
    bne command_10
    jsr bp_vspan
    jmp complete
command_10
    cmpa #10
    bne command_11
    jsr bp_fill
    jmp complete
command_11
    cmpa #11
    bne command_12
    jsr bp_box
    jmp complete
command_12
    cmpa #12
    bne command_13
    jsr clear_screen
    jmp complete
command_13
complete
    lda #0
    sta COMMAND
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
    include "../../../../../cross-platform/patterns/rendering/geometry/6809.inc"
geometry_backend_start
    include "../../../../../cross-platform/patterns/rendering/drawing-foundations/6809.inc"
geometry_backend_end
