; SPDX-License-Identifier: MIT
; Service a Logical Attack–Decay–Sustain–Release Envelope. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
logical_envelope_init:
    move.b #0,d0
    move.b d0,LEVEL
    move.b d0,PHASE
    move.b d0,PREVIOUS
    move.b d0,VALID
    move.b d0,GATE
    move.b d0,ATTACK
    move.b d0,DECAY
    move.b d0,SUSTAIN
    move.b d0,RELEASE
    move.b d0,T0
    rts
logical_envelope_step:
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if LEVEL > 15:
    move.b LEVEL,d0
    cmp.b #15,d0
    bhi logical_envelope_L1
    jmp logical_envelope_L2
logical_envelope_L1:
; return
    rts
    jmp logical_envelope_L3
logical_envelope_L2:
logical_envelope_L3:
; if PHASE > 4:
    move.b PHASE,d0
    cmp.b #4,d0
    bhi logical_envelope_L4
    jmp logical_envelope_L5
logical_envelope_L4:
; return
    rts
    jmp logical_envelope_L6
logical_envelope_L5:
logical_envelope_L6:
; if ATTACK == 0:
    move.b ATTACK,d0
    cmp.b #0,d0
    beq logical_envelope_L7
    jmp logical_envelope_L8
logical_envelope_L7:
; return
    rts
    jmp logical_envelope_L9
logical_envelope_L8:
logical_envelope_L9:
; if ATTACK > 15:
    move.b ATTACK,d0
    cmp.b #15,d0
    bhi logical_envelope_L10
    jmp logical_envelope_L11
logical_envelope_L10:
; return
    rts
    jmp logical_envelope_L12
logical_envelope_L11:
logical_envelope_L12:
; if DECAY == 0:
    move.b DECAY,d0
    cmp.b #0,d0
    beq logical_envelope_L13
    jmp logical_envelope_L14
logical_envelope_L13:
; return
    rts
    jmp logical_envelope_L15
logical_envelope_L14:
logical_envelope_L15:
; if DECAY > 15:
    move.b DECAY,d0
    cmp.b #15,d0
    bhi logical_envelope_L16
    jmp logical_envelope_L17
logical_envelope_L16:
; return
    rts
    jmp logical_envelope_L18
logical_envelope_L17:
logical_envelope_L18:
; if RELEASE == 0:
    move.b RELEASE,d0
    cmp.b #0,d0
    beq logical_envelope_L19
    jmp logical_envelope_L20
logical_envelope_L19:
; return
    rts
    jmp logical_envelope_L21
logical_envelope_L20:
logical_envelope_L21:
; if RELEASE > 15:
    move.b RELEASE,d0
    cmp.b #15,d0
    bhi logical_envelope_L22
    jmp logical_envelope_L23
logical_envelope_L22:
; return
    rts
    jmp logical_envelope_L24
logical_envelope_L23:
logical_envelope_L24:
; if SUSTAIN > 15:
    move.b SUSTAIN,d0
    cmp.b #15,d0
    bhi logical_envelope_L25
    jmp logical_envelope_L26
logical_envelope_L25:
; return
    rts
    jmp logical_envelope_L27
logical_envelope_L26:
logical_envelope_L27:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; if GATE != 0:
    move.b GATE,d0
    cmp.b #0,d0
    bne logical_envelope_L28
    jmp logical_envelope_L29
logical_envelope_L28:
; if PREVIOUS == 0:
    move.b PREVIOUS,d0
    cmp.b #0,d0
    beq logical_envelope_L31
    jmp logical_envelope_L32
logical_envelope_L31:
; LEVEL = 0
    move.b #0,d0
    move.b d0,LEVEL
; PHASE = 1
    move.b #1,d0
    move.b d0,PHASE
    jmp logical_envelope_L33
logical_envelope_L32:
logical_envelope_L33:
; PREVIOUS = 1
    move.b #1,d0
    move.b d0,PREVIOUS
    jmp logical_envelope_L30
logical_envelope_L29:
; PREVIOUS = 0
    move.b #0,d0
    move.b d0,PREVIOUS
; if PHASE != 0:
    move.b PHASE,d0
    cmp.b #0,d0
    bne logical_envelope_L34
    jmp logical_envelope_L35
logical_envelope_L34:
; PHASE = 4
    move.b #4,d0
    move.b d0,PHASE
    jmp logical_envelope_L36
logical_envelope_L35:
logical_envelope_L36:
logical_envelope_L30:
; if PHASE == 0:
    move.b PHASE,d0
    cmp.b #0,d0
    beq logical_envelope_L37
    jmp logical_envelope_L38
logical_envelope_L37:
; LEVEL = 0
    move.b #0,d0
    move.b d0,LEVEL
; return
    rts
    jmp logical_envelope_L39
logical_envelope_L38:
logical_envelope_L39:
; if PHASE == 1:
    move.b PHASE,d0
    cmp.b #1,d0
    beq logical_envelope_L40
    jmp logical_envelope_L41
logical_envelope_L40:
; T0 = 15 - LEVEL
    move.b #15,d0
    move.b LEVEL,d1
    sub.b d1,d0
    move.b d0,T0
; if ATTACK >= T0:
    move.b ATTACK,d0
    move.b T0,d1
    cmp.b d1,d0
    bcc logical_envelope_L43
    jmp logical_envelope_L44
logical_envelope_L43:
; LEVEL = 15
    move.b #15,d0
    move.b d0,LEVEL
; PHASE = 2
    move.b #2,d0
    move.b d0,PHASE
    jmp logical_envelope_L45
logical_envelope_L44:
; LEVEL = LEVEL + ATTACK
    move.b LEVEL,d0
    move.b ATTACK,d1
    add.b d1,d0
    move.b d0,LEVEL
logical_envelope_L45:
; return
    rts
    jmp logical_envelope_L42
logical_envelope_L41:
logical_envelope_L42:
; if PHASE == 2:
    move.b PHASE,d0
    cmp.b #2,d0
    beq logical_envelope_L46
    jmp logical_envelope_L47
logical_envelope_L46:
; if LEVEL <= SUSTAIN:
    move.b LEVEL,d0
    move.b SUSTAIN,d1
    cmp.b d1,d0
    bls logical_envelope_L49
    jmp logical_envelope_L50
logical_envelope_L49:
; LEVEL = SUSTAIN
    move.b SUSTAIN,d0
    move.b d0,LEVEL
; PHASE = 3
    move.b #3,d0
    move.b d0,PHASE
; return
    rts
    jmp logical_envelope_L51
logical_envelope_L50:
logical_envelope_L51:
; T0 = LEVEL - SUSTAIN
    move.b LEVEL,d0
    move.b SUSTAIN,d1
    sub.b d1,d0
    move.b d0,T0
; if DECAY >= T0:
    move.b DECAY,d0
    move.b T0,d1
    cmp.b d1,d0
    bcc logical_envelope_L52
    jmp logical_envelope_L53
logical_envelope_L52:
; LEVEL = SUSTAIN
    move.b SUSTAIN,d0
    move.b d0,LEVEL
; PHASE = 3
    move.b #3,d0
    move.b d0,PHASE
    jmp logical_envelope_L54
logical_envelope_L53:
; LEVEL = LEVEL - DECAY
    move.b LEVEL,d0
    move.b DECAY,d1
    sub.b d1,d0
    move.b d0,LEVEL
logical_envelope_L54:
; return
    rts
    jmp logical_envelope_L48
logical_envelope_L47:
logical_envelope_L48:
; if PHASE == 3:
    move.b PHASE,d0
    cmp.b #3,d0
    beq logical_envelope_L55
    jmp logical_envelope_L56
logical_envelope_L55:
; LEVEL = SUSTAIN
    move.b SUSTAIN,d0
    move.b d0,LEVEL
; return
    rts
    jmp logical_envelope_L57
logical_envelope_L56:
logical_envelope_L57:
; if RELEASE >= LEVEL:
    move.b RELEASE,d0
    move.b LEVEL,d1
    cmp.b d1,d0
    bcc logical_envelope_L58
    jmp logical_envelope_L59
logical_envelope_L58:
; LEVEL = 0
    move.b #0,d0
    move.b d0,LEVEL
; PHASE = 0
    move.b #0,d0
    move.b d0,PHASE
    jmp logical_envelope_L60
logical_envelope_L59:
; LEVEL = LEVEL - RELEASE
    move.b LEVEL,d0
    move.b RELEASE,d1
    sub.b d1,d0
    move.b d0,LEVEL
logical_envelope_L60:
    rts
component_end:
