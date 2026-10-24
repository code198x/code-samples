; SPDX-License-Identifier: MIT
; Service a Logical Attack–Decay–Sustain–Release Envelope. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
logical_envelope_init:
    ld a,0
    ld (LEVEL),a
    ld (PHASE),a
    ld (PREVIOUS),a
    ld (VALID),a
    ld (GATE),a
    ld (ATTACK),a
    ld (DECAY),a
    ld (SUSTAIN),a
    ld (RELEASE),a
    ld (T0),a
    ret
logical_envelope_step:
; VALID = 0
    ld a,0
    ld (VALID),a
; if LEVEL > 15:
    ld a,(LEVEL)
    cp 15
    jp z,logical_envelope_L2
    jp nc,logical_envelope_L1
    jp logical_envelope_L2
logical_envelope_L1:
; return
    ret
    jp logical_envelope_L3
logical_envelope_L2:
logical_envelope_L3:
; if PHASE > 4:
    ld a,(PHASE)
    cp 4
    jp z,logical_envelope_L5
    jp nc,logical_envelope_L4
    jp logical_envelope_L5
logical_envelope_L4:
; return
    ret
    jp logical_envelope_L6
logical_envelope_L5:
logical_envelope_L6:
; if ATTACK == 0:
    ld a,(ATTACK)
    cp 0
    jp z,logical_envelope_L7
    jp logical_envelope_L8
logical_envelope_L7:
; return
    ret
    jp logical_envelope_L9
logical_envelope_L8:
logical_envelope_L9:
; if ATTACK > 15:
    ld a,(ATTACK)
    cp 15
    jp z,logical_envelope_L11
    jp nc,logical_envelope_L10
    jp logical_envelope_L11
logical_envelope_L10:
; return
    ret
    jp logical_envelope_L12
logical_envelope_L11:
logical_envelope_L12:
; if DECAY == 0:
    ld a,(DECAY)
    cp 0
    jp z,logical_envelope_L13
    jp logical_envelope_L14
logical_envelope_L13:
; return
    ret
    jp logical_envelope_L15
logical_envelope_L14:
logical_envelope_L15:
; if DECAY > 15:
    ld a,(DECAY)
    cp 15
    jp z,logical_envelope_L17
    jp nc,logical_envelope_L16
    jp logical_envelope_L17
logical_envelope_L16:
; return
    ret
    jp logical_envelope_L18
logical_envelope_L17:
logical_envelope_L18:
; if RELEASE == 0:
    ld a,(RELEASE)
    cp 0
    jp z,logical_envelope_L19
    jp logical_envelope_L20
logical_envelope_L19:
; return
    ret
    jp logical_envelope_L21
logical_envelope_L20:
logical_envelope_L21:
; if RELEASE > 15:
    ld a,(RELEASE)
    cp 15
    jp z,logical_envelope_L23
    jp nc,logical_envelope_L22
    jp logical_envelope_L23
logical_envelope_L22:
; return
    ret
    jp logical_envelope_L24
logical_envelope_L23:
logical_envelope_L24:
; if SUSTAIN > 15:
    ld a,(SUSTAIN)
    cp 15
    jp z,logical_envelope_L26
    jp nc,logical_envelope_L25
    jp logical_envelope_L26
logical_envelope_L25:
; return
    ret
    jp logical_envelope_L27
logical_envelope_L26:
logical_envelope_L27:
; VALID = 1
    ld a,1
    ld (VALID),a
; if GATE != 0:
    ld a,(GATE)
    cp 0
    jp nz,logical_envelope_L28
    jp logical_envelope_L29
logical_envelope_L28:
; if PREVIOUS == 0:
    ld a,(PREVIOUS)
    cp 0
    jp z,logical_envelope_L31
    jp logical_envelope_L32
logical_envelope_L31:
; LEVEL = 0
    ld a,0
    ld (LEVEL),a
; PHASE = 1
    ld a,1
    ld (PHASE),a
    jp logical_envelope_L33
logical_envelope_L32:
logical_envelope_L33:
; PREVIOUS = 1
    ld a,1
    ld (PREVIOUS),a
    jp logical_envelope_L30
logical_envelope_L29:
; PREVIOUS = 0
    ld a,0
    ld (PREVIOUS),a
; if PHASE != 0:
    ld a,(PHASE)
    cp 0
    jp nz,logical_envelope_L34
    jp logical_envelope_L35
logical_envelope_L34:
; PHASE = 4
    ld a,4
    ld (PHASE),a
    jp logical_envelope_L36
logical_envelope_L35:
logical_envelope_L36:
logical_envelope_L30:
; if PHASE == 0:
    ld a,(PHASE)
    cp 0
    jp z,logical_envelope_L37
    jp logical_envelope_L38
logical_envelope_L37:
; LEVEL = 0
    ld a,0
    ld (LEVEL),a
; return
    ret
    jp logical_envelope_L39
logical_envelope_L38:
logical_envelope_L39:
; if PHASE == 1:
    ld a,(PHASE)
    cp 1
    jp z,logical_envelope_L40
    jp logical_envelope_L41
logical_envelope_L40:
; T0 = 15 - LEVEL
    ld a,15
    ld b,a
    ld a,(LEVEL)
    ld c,a
    ld a,b
    sub c
    ld (T0),a
; if ATTACK >= T0:
    ld a,(ATTACK)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    cp c
    jp nc,logical_envelope_L43
    jp logical_envelope_L44
logical_envelope_L43:
; LEVEL = 15
    ld a,15
    ld (LEVEL),a
; PHASE = 2
    ld a,2
    ld (PHASE),a
    jp logical_envelope_L45
logical_envelope_L44:
; LEVEL = LEVEL + ATTACK
    ld a,(LEVEL)
    ld b,a
    ld a,(ATTACK)
    ld c,a
    ld a,b
    add a,c
    ld (LEVEL),a
logical_envelope_L45:
; return
    ret
    jp logical_envelope_L42
logical_envelope_L41:
logical_envelope_L42:
; if PHASE == 2:
    ld a,(PHASE)
    cp 2
    jp z,logical_envelope_L46
    jp logical_envelope_L47
logical_envelope_L46:
; if LEVEL <= SUSTAIN:
    ld a,(LEVEL)
    ld b,a
    ld a,(SUSTAIN)
    ld c,a
    ld a,b
    cp c
    jp c,logical_envelope_L49
    jp z,logical_envelope_L49
    jp logical_envelope_L50
logical_envelope_L49:
; LEVEL = SUSTAIN
    ld a,(SUSTAIN)
    ld (LEVEL),a
; PHASE = 3
    ld a,3
    ld (PHASE),a
; return
    ret
    jp logical_envelope_L51
logical_envelope_L50:
logical_envelope_L51:
; T0 = LEVEL - SUSTAIN
    ld a,(LEVEL)
    ld b,a
    ld a,(SUSTAIN)
    ld c,a
    ld a,b
    sub c
    ld (T0),a
; if DECAY >= T0:
    ld a,(DECAY)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    cp c
    jp nc,logical_envelope_L52
    jp logical_envelope_L53
logical_envelope_L52:
; LEVEL = SUSTAIN
    ld a,(SUSTAIN)
    ld (LEVEL),a
; PHASE = 3
    ld a,3
    ld (PHASE),a
    jp logical_envelope_L54
logical_envelope_L53:
; LEVEL = LEVEL - DECAY
    ld a,(LEVEL)
    ld b,a
    ld a,(DECAY)
    ld c,a
    ld a,b
    sub c
    ld (LEVEL),a
logical_envelope_L54:
; return
    ret
    jp logical_envelope_L48
logical_envelope_L47:
logical_envelope_L48:
; if PHASE == 3:
    ld a,(PHASE)
    cp 3
    jp z,logical_envelope_L55
    jp logical_envelope_L56
logical_envelope_L55:
; LEVEL = SUSTAIN
    ld a,(SUSTAIN)
    ld (LEVEL),a
; return
    ret
    jp logical_envelope_L57
logical_envelope_L56:
logical_envelope_L57:
; if RELEASE >= LEVEL:
    ld a,(RELEASE)
    ld b,a
    ld a,(LEVEL)
    ld c,a
    ld a,b
    cp c
    jp nc,logical_envelope_L58
    jp logical_envelope_L59
logical_envelope_L58:
; LEVEL = 0
    ld a,0
    ld (LEVEL),a
; PHASE = 0
    ld a,0
    ld (PHASE),a
    jp logical_envelope_L60
logical_envelope_L59:
; LEVEL = LEVEL - RELEASE
    ld a,(LEVEL)
    ld b,a
    ld a,(RELEASE)
    ld c,a
    ld a,b
    sub c
    ld (LEVEL),a
logical_envelope_L60:
    ret
component_end:
