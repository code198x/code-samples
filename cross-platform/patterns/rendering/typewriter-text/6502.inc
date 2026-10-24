; SPDX-License-Identifier: MIT
; Reveal Counted Text Over Time. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
typewriter_text_init:
    lda #0
    sta REVEALED
    sta TICKS
    sta DONE
    sta ADDED
    sta VALID
    sta LENGTH
    sta INTERVAL
    sta SKIP
    rts
typewriter_text_step:
; DONE = 0
    lda #0
    sta DONE
; ADDED = 0
    lda #0
    sta ADDED
; VALID = 0
    lda #0
    sta VALID
; if INTERVAL == 0:
    lda INTERVAL
    cmp #0
    beq typewriter_text_L4
typewriter_text_L5:
    jmp typewriter_text_L2
typewriter_text_L4:
    jmp typewriter_text_L1
typewriter_text_L1:
; return
    rts
    jmp typewriter_text_L3
typewriter_text_L2:
typewriter_text_L3:
; if TICKS >= INTERVAL:
    lda TICKS
    cmp INTERVAL
    bcs typewriter_text_L9
typewriter_text_L10:
    jmp typewriter_text_L7
typewriter_text_L9:
    jmp typewriter_text_L6
typewriter_text_L6:
; return
    rts
    jmp typewriter_text_L8
typewriter_text_L7:
typewriter_text_L8:
; if REVEALED > LENGTH:
    lda REVEALED
    cmp LENGTH
    beq typewriter_text_L15
    bcs typewriter_text_L14
typewriter_text_L15:
    jmp typewriter_text_L12
typewriter_text_L14:
    jmp typewriter_text_L11
typewriter_text_L11:
; return
    rts
    jmp typewriter_text_L13
typewriter_text_L12:
typewriter_text_L13:
; VALID = 1
    lda #1
    sta VALID
; if SKIP != 0:
    lda SKIP
    cmp #0
    bne typewriter_text_L19
typewriter_text_L20:
    jmp typewriter_text_L17
typewriter_text_L19:
    jmp typewriter_text_L16
typewriter_text_L16:
; ADDED = LENGTH - REVEALED
    lda LENGTH
    sec
    sbc REVEALED
    sta ADDED
; REVEALED = LENGTH
    lda LENGTH
    sta REVEALED
; TICKS = 0
    lda #0
    sta TICKS
    jmp typewriter_text_L18
typewriter_text_L17:
; if REVEALED < LENGTH:
    lda REVEALED
    cmp LENGTH
    bcc typewriter_text_L24
typewriter_text_L25:
    jmp typewriter_text_L22
typewriter_text_L24:
    jmp typewriter_text_L21
typewriter_text_L21:
; TICKS = TICKS + 1
    lda TICKS
    clc
    adc #1
    sta TICKS
; if TICKS == INTERVAL:
    lda TICKS
    cmp INTERVAL
    beq typewriter_text_L29
typewriter_text_L30:
    jmp typewriter_text_L27
typewriter_text_L29:
    jmp typewriter_text_L26
typewriter_text_L26:
; TICKS = 0
    lda #0
    sta TICKS
; REVEALED = REVEALED + 1
    lda REVEALED
    clc
    adc #1
    sta REVEALED
; ADDED = 1
    lda #1
    sta ADDED
    jmp typewriter_text_L28
typewriter_text_L27:
typewriter_text_L28:
    jmp typewriter_text_L23
typewriter_text_L22:
typewriter_text_L23:
typewriter_text_L18:
; if REVEALED == LENGTH:
    lda REVEALED
    cmp LENGTH
    beq typewriter_text_L34
typewriter_text_L35:
    jmp typewriter_text_L32
typewriter_text_L34:
    jmp typewriter_text_L31
typewriter_text_L31:
; DONE = 1
    lda #1
    sta DONE
    jmp typewriter_text_L33
typewriter_text_L32:
typewriter_text_L33:
    rts
component_end:
