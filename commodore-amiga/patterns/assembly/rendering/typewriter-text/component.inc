; SPDX-License-Identifier: MIT
; Reveal Counted Text Over Time. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
typewriter_text_init:
    move.b #0,d0
    move.b d0,REVEALED
    move.b d0,TICKS
    move.b d0,DONE
    move.b d0,ADDED
    move.b d0,VALID
    move.b d0,LENGTH
    move.b d0,INTERVAL
    move.b d0,SKIP
    rts
typewriter_text_step:
; DONE = 0
    move.b #0,d0
    move.b d0,DONE
; ADDED = 0
    move.b #0,d0
    move.b d0,ADDED
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if INTERVAL == 0:
    move.b INTERVAL,d0
    cmp.b #0,d0
    beq typewriter_text_L1
    jmp typewriter_text_L2
typewriter_text_L1:
; return
    rts
    jmp typewriter_text_L3
typewriter_text_L2:
typewriter_text_L3:
; if TICKS >= INTERVAL:
    move.b TICKS,d0
    move.b INTERVAL,d1
    cmp.b d1,d0
    bcc typewriter_text_L4
    jmp typewriter_text_L5
typewriter_text_L4:
; return
    rts
    jmp typewriter_text_L6
typewriter_text_L5:
typewriter_text_L6:
; if REVEALED > LENGTH:
    move.b REVEALED,d0
    move.b LENGTH,d1
    cmp.b d1,d0
    bhi typewriter_text_L7
    jmp typewriter_text_L8
typewriter_text_L7:
; return
    rts
    jmp typewriter_text_L9
typewriter_text_L8:
typewriter_text_L9:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; if SKIP != 0:
    move.b SKIP,d0
    cmp.b #0,d0
    bne typewriter_text_L10
    jmp typewriter_text_L11
typewriter_text_L10:
; ADDED = LENGTH - REVEALED
    move.b LENGTH,d0
    move.b REVEALED,d1
    sub.b d1,d0
    move.b d0,ADDED
; REVEALED = LENGTH
    move.b LENGTH,d0
    move.b d0,REVEALED
; TICKS = 0
    move.b #0,d0
    move.b d0,TICKS
    jmp typewriter_text_L12
typewriter_text_L11:
; if REVEALED < LENGTH:
    move.b REVEALED,d0
    move.b LENGTH,d1
    cmp.b d1,d0
    bcs typewriter_text_L13
    jmp typewriter_text_L14
typewriter_text_L13:
; TICKS = TICKS + 1
    move.b TICKS,d0
    add.b #1,d0
    move.b d0,TICKS
; if TICKS == INTERVAL:
    move.b TICKS,d0
    move.b INTERVAL,d1
    cmp.b d1,d0
    beq typewriter_text_L16
    jmp typewriter_text_L17
typewriter_text_L16:
; TICKS = 0
    move.b #0,d0
    move.b d0,TICKS
; REVEALED = REVEALED + 1
    move.b REVEALED,d0
    add.b #1,d0
    move.b d0,REVEALED
; ADDED = 1
    move.b #1,d0
    move.b d0,ADDED
    jmp typewriter_text_L18
typewriter_text_L17:
typewriter_text_L18:
    jmp typewriter_text_L15
typewriter_text_L14:
typewriter_text_L15:
typewriter_text_L12:
; if REVEALED == LENGTH:
    move.b REVEALED,d0
    move.b LENGTH,d1
    cmp.b d1,d0
    beq typewriter_text_L19
    jmp typewriter_text_L20
typewriter_text_L19:
; DONE = 1
    move.b #1,d0
    move.b d0,DONE
    jmp typewriter_text_L21
typewriter_text_L20:
typewriter_text_L21:
    rts
component_end:
