; SPDX-License-Identifier: MIT
; Reveal Counted Text Over Time. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
typewriter_text_init:
    ld a,0
    ld (REVEALED),a
    ld (TICKS),a
    ld (DONE),a
    ld (ADDED),a
    ld (VALID),a
    ld (LENGTH),a
    ld (INTERVAL),a
    ld (SKIP),a
    ret
typewriter_text_step:
; DONE = 0
    ld a,0
    ld (DONE),a
; ADDED = 0
    ld a,0
    ld (ADDED),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if INTERVAL == 0:
    ld a,(INTERVAL)
    cp 0
    jp z,typewriter_text_L1
    jp typewriter_text_L2
typewriter_text_L1:
; return
    ret
    jp typewriter_text_L3
typewriter_text_L2:
typewriter_text_L3:
; if TICKS >= INTERVAL:
    ld a,(TICKS)
    ld b,a
    ld a,(INTERVAL)
    ld c,a
    ld a,b
    cp c
    jp nc,typewriter_text_L4
    jp typewriter_text_L5
typewriter_text_L4:
; return
    ret
    jp typewriter_text_L6
typewriter_text_L5:
typewriter_text_L6:
; if REVEALED > LENGTH:
    ld a,(REVEALED)
    ld b,a
    ld a,(LENGTH)
    ld c,a
    ld a,b
    cp c
    jp z,typewriter_text_L8
    jp nc,typewriter_text_L7
    jp typewriter_text_L8
typewriter_text_L7:
; return
    ret
    jp typewriter_text_L9
typewriter_text_L8:
typewriter_text_L9:
; VALID = 1
    ld a,1
    ld (VALID),a
; if SKIP != 0:
    ld a,(SKIP)
    cp 0
    jp nz,typewriter_text_L10
    jp typewriter_text_L11
typewriter_text_L10:
; ADDED = LENGTH - REVEALED
    ld a,(LENGTH)
    ld b,a
    ld a,(REVEALED)
    ld c,a
    ld a,b
    sub c
    ld (ADDED),a
; REVEALED = LENGTH
    ld a,(LENGTH)
    ld (REVEALED),a
; TICKS = 0
    ld a,0
    ld (TICKS),a
    jp typewriter_text_L12
typewriter_text_L11:
; if REVEALED < LENGTH:
    ld a,(REVEALED)
    ld b,a
    ld a,(LENGTH)
    ld c,a
    ld a,b
    cp c
    jp c,typewriter_text_L13
    jp typewriter_text_L14
typewriter_text_L13:
; TICKS = TICKS + 1
    ld a,(TICKS)
    add a,1
    ld (TICKS),a
; if TICKS == INTERVAL:
    ld a,(TICKS)
    ld b,a
    ld a,(INTERVAL)
    ld c,a
    ld a,b
    cp c
    jp z,typewriter_text_L16
    jp typewriter_text_L17
typewriter_text_L16:
; TICKS = 0
    ld a,0
    ld (TICKS),a
; REVEALED = REVEALED + 1
    ld a,(REVEALED)
    add a,1
    ld (REVEALED),a
; ADDED = 1
    ld a,1
    ld (ADDED),a
    jp typewriter_text_L18
typewriter_text_L17:
typewriter_text_L18:
    jp typewriter_text_L15
typewriter_text_L14:
typewriter_text_L15:
typewriter_text_L12:
; if REVEALED == LENGTH:
    ld a,(REVEALED)
    ld b,a
    ld a,(LENGTH)
    ld c,a
    ld a,b
    cp c
    jp z,typewriter_text_L19
    jp typewriter_text_L20
typewriter_text_L19:
; DONE = 1
    ld a,1
    ld (DONE),a
    jp typewriter_text_L21
typewriter_text_L20:
typewriter_text_L21:
    ret
component_end:
