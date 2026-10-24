; SPDX-License-Identifier: MIT
; Service a Small Spawn Timeline. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
spawn_timeline_init:
    ld a,0
    ld (EVENT),a
    ld (FIRED),a
    ld (INDEX),a
    ld (WAIT),a
    ld (COUNT),a
    ld (DONE),a
    ld (VALID),a
    ld (E0),a
    ld (E1),a
    ld (E2),a
    ld (E3),a
    ld (L0),a
    ld (L1),a
    ld (L2),a
    ld (L3),a
    ld (T0),a
    ret
spawn_timeline_step:
; EVENT = 255
    ld a,255
    ld (EVENT),a
; FIRED = 0
    ld a,0
    ld (FIRED),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if COUNT == 0:
    ld a,(COUNT)
    cp 0
    jp z,spawn_timeline_L1
    jp spawn_timeline_L2
spawn_timeline_L1:
; return
    ret
    jp spawn_timeline_L3
spawn_timeline_L2:
spawn_timeline_L3:
; if COUNT > 4:
    ld a,(COUNT)
    cp 4
    jp z,spawn_timeline_L5
    jp nc,spawn_timeline_L4
    jp spawn_timeline_L5
spawn_timeline_L4:
; return
    ret
    jp spawn_timeline_L6
spawn_timeline_L5:
spawn_timeline_L6:
; if INDEX >= COUNT:
    ld a,(INDEX)
    ld b,a
    ld a,(COUNT)
    ld c,a
    ld a,b
    cp c
    jp nc,spawn_timeline_L7
    jp spawn_timeline_L8
spawn_timeline_L7:
; return
    ret
    jp spawn_timeline_L9
spawn_timeline_L8:
spawn_timeline_L9:
; VALID = 1
    ld a,1
    ld (VALID),a
; if DONE != 0:
    ld a,(DONE)
    cp 0
    jp nz,spawn_timeline_L10
    jp spawn_timeline_L11
spawn_timeline_L10:
; return
    ret
    jp spawn_timeline_L12
spawn_timeline_L11:
spawn_timeline_L12:
; T0 = L[INDEX]
    ld a,(INDEX)
    ld e,a
    ld d,0
    ld hl,L0
    add hl,de
    ld a,(hl)
    ld (T0),a
; if WAIT < T0:
    ld a,(WAIT)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    cp c
    jp c,spawn_timeline_L13
    jp spawn_timeline_L14
spawn_timeline_L13:
; WAIT = WAIT + 1
    ld a,(WAIT)
    add a,1
    ld (WAIT),a
; return
    ret
    jp spawn_timeline_L15
spawn_timeline_L14:
spawn_timeline_L15:
; EVENT = E[INDEX]
    ld a,(INDEX)
    ld e,a
    ld d,0
    ld hl,E0
    add hl,de
    ld a,(hl)
    ld (EVENT),a
; FIRED = 1
    ld a,1
    ld (FIRED),a
; WAIT = 0
    ld a,0
    ld (WAIT),a
; T0 = COUNT - 1
    ld a,(COUNT)
    sub 1
    ld (T0),a
; if INDEX < T0:
    ld a,(INDEX)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    cp c
    jp c,spawn_timeline_L16
    jp spawn_timeline_L17
spawn_timeline_L16:
; INDEX = INDEX + 1
    ld a,(INDEX)
    add a,1
    ld (INDEX),a
    jp spawn_timeline_L18
spawn_timeline_L17:
; DONE = 1
    ld a,1
    ld (DONE),a
spawn_timeline_L18:
    ret
component_end:
