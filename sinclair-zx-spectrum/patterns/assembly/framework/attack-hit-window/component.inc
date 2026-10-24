; SPDX-License-Identifier: MIT
; Limit Hits to an Attack Window. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
attack_hit_window_init:
    ld a,0
    ld (HIT),a
    ld (VALID),a
    ld (SEEN),a
    ld (FRAME),a
    ld (START_FRAME),a
    ld (END_FRAME),a
    ld (TARGET),a
    ld (CONTACT),a
    ld (NEW_ATTACK),a
    ld (T0),a
    ld (T1),a
    ret
attack_hit_window_step:
; HIT = 0
    ld a,0
    ld (HIT),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if START_FRAME >= END_FRAME:
    ld a,(START_FRAME)
    ld b,a
    ld a,(END_FRAME)
    ld c,a
    ld a,b
    cp c
    jp nc,attack_hit_window_L1
    jp attack_hit_window_L2
attack_hit_window_L1:
; return
    ret
    jp attack_hit_window_L3
attack_hit_window_L2:
attack_hit_window_L3:
; if TARGET >= 8:
    ld a,(TARGET)
    cp 8
    jp nc,attack_hit_window_L4
    jp attack_hit_window_L5
attack_hit_window_L4:
; return
    ret
    jp attack_hit_window_L6
attack_hit_window_L5:
attack_hit_window_L6:
; VALID = 1
    ld a,1
    ld (VALID),a
; if NEW_ATTACK != 0:
    ld a,(NEW_ATTACK)
    cp 0
    jp nz,attack_hit_window_L7
    jp attack_hit_window_L8
attack_hit_window_L7:
; SEEN = 0
    ld a,0
    ld (SEEN),a
    jp attack_hit_window_L9
attack_hit_window_L8:
attack_hit_window_L9:
; if FRAME < START_FRAME:
    ld a,(FRAME)
    ld b,a
    ld a,(START_FRAME)
    ld c,a
    ld a,b
    cp c
    jp c,attack_hit_window_L10
    jp attack_hit_window_L11
attack_hit_window_L10:
; return
    ret
    jp attack_hit_window_L12
attack_hit_window_L11:
attack_hit_window_L12:
; if FRAME >= END_FRAME:
    ld a,(FRAME)
    ld b,a
    ld a,(END_FRAME)
    ld c,a
    ld a,b
    cp c
    jp nc,attack_hit_window_L13
    jp attack_hit_window_L14
attack_hit_window_L13:
; return
    ret
    jp attack_hit_window_L15
attack_hit_window_L14:
attack_hit_window_L15:
; if CONTACT == 0:
    ld a,(CONTACT)
    cp 0
    jp z,attack_hit_window_L16
    jp attack_hit_window_L17
attack_hit_window_L16:
; return
    ret
    jp attack_hit_window_L18
attack_hit_window_L17:
attack_hit_window_L18:
; T0 = 1
    ld a,1
    ld (T0),a
; T1 = TARGET
    ld a,(TARGET)
    ld (T1),a
; while T1 != 0:
attack_hit_window_L19:
    ld a,(T1)
    cp 0
    jp nz,attack_hit_window_L20
    jp attack_hit_window_L21
attack_hit_window_L20:
; T0 = T0 << 1
    ld a,(T0)
    sla a
    ld (T0),a
; T1 = T1 - 1
    ld a,(T1)
    sub 1
    ld (T1),a
    jp attack_hit_window_L19
attack_hit_window_L21:
; T1 = SEEN & T0
    ld a,(SEEN)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    and c
    ld (T1),a
; if T1 == 0:
    ld a,(T1)
    cp 0
    jp z,attack_hit_window_L22
    jp attack_hit_window_L23
attack_hit_window_L22:
; SEEN = SEEN | T0
    ld a,(SEEN)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    or c
    ld (SEEN),a
; HIT = 1
    ld a,1
    ld (HIT),a
    jp attack_hit_window_L24
attack_hit_window_L23:
attack_hit_window_L24:
    ret
component_end:
