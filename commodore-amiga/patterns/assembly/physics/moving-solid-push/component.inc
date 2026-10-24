; SPDX-License-Identifier: MIT
; Push an Actor with a Moving Solid. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
moving_solid_push_init:
    move.b #0,d0
    move.b d0,POSITION
    move.b d0,PUSHED
    move.b d0,BLOCKED
    move.b d0,VALID
    move.b d0,ACTOR_POSITION
    move.b d0,ACTOR_SIZE
    move.b d0,SOLID_OLD
    move.b d0,SOLID_NEW
    move.b d0,SOLID_SIZE
    move.b d0,MINIMUM
    move.b d0,MAXIMUM
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    move.b d0,T3
    rts
moving_solid_push_step:
; POSITION = ACTOR_POSITION
    move.b ACTOR_POSITION,d0
    move.b d0,POSITION
; PUSHED = 0
    move.b #0,d0
    move.b d0,PUSHED
; BLOCKED = 0
    move.b #0,d0
    move.b d0,BLOCKED
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if ACTOR_SIZE == 0:
    move.b ACTOR_SIZE,d0
    cmp.b #0,d0
    beq moving_solid_push_L1
    jmp moving_solid_push_L2
moving_solid_push_L1:
; return
    rts
    jmp moving_solid_push_L3
moving_solid_push_L2:
moving_solid_push_L3:
; if SOLID_SIZE == 0:
    move.b SOLID_SIZE,d0
    cmp.b #0,d0
    beq moving_solid_push_L4
    jmp moving_solid_push_L5
moving_solid_push_L4:
; return
    rts
    jmp moving_solid_push_L6
moving_solid_push_L5:
moving_solid_push_L6:
; if MINIMUM > MAXIMUM:
    move.b MINIMUM,d0
    move.b MAXIMUM,d1
    cmp.b d1,d0
    bhi moving_solid_push_L7
    jmp moving_solid_push_L8
moving_solid_push_L7:
; return
    rts
    jmp moving_solid_push_L9
moving_solid_push_L8:
moving_solid_push_L9:
; if ACTOR_POSITION < MINIMUM:
    move.b ACTOR_POSITION,d0
    move.b MINIMUM,d1
    cmp.b d1,d0
    bcs moving_solid_push_L10
    jmp moving_solid_push_L11
moving_solid_push_L10:
; return
    rts
    jmp moving_solid_push_L12
moving_solid_push_L11:
moving_solid_push_L12:
; if ACTOR_POSITION > MAXIMUM:
    move.b ACTOR_POSITION,d0
    move.b MAXIMUM,d1
    cmp.b d1,d0
    bhi moving_solid_push_L13
    jmp moving_solid_push_L14
moving_solid_push_L13:
; return
    rts
    jmp moving_solid_push_L15
moving_solid_push_L14:
moving_solid_push_L15:
; T0 = ACTOR_POSITION + ACTOR_SIZE
    move.b ACTOR_POSITION,d0
    move.b ACTOR_SIZE,d1
    add.b d1,d0
    move.b d0,T0
; if T0 < ACTOR_POSITION:
    move.b T0,d0
    move.b ACTOR_POSITION,d1
    cmp.b d1,d0
    bcs moving_solid_push_L16
    jmp moving_solid_push_L17
moving_solid_push_L16:
; return
    rts
    jmp moving_solid_push_L18
moving_solid_push_L17:
moving_solid_push_L18:
; T1 = SOLID_OLD + SOLID_SIZE
    move.b SOLID_OLD,d0
    move.b SOLID_SIZE,d1
    add.b d1,d0
    move.b d0,T1
; if T1 < SOLID_OLD:
    move.b T1,d0
    move.b SOLID_OLD,d1
    cmp.b d1,d0
    bcs moving_solid_push_L19
    jmp moving_solid_push_L20
moving_solid_push_L19:
; return
    rts
    jmp moving_solid_push_L21
moving_solid_push_L20:
moving_solid_push_L21:
; T2 = SOLID_NEW + SOLID_SIZE
    move.b SOLID_NEW,d0
    move.b SOLID_SIZE,d1
    add.b d1,d0
    move.b d0,T2
; if T2 < SOLID_NEW:
    move.b T2,d0
    move.b SOLID_NEW,d1
    cmp.b d1,d0
    bcs moving_solid_push_L22
    jmp moving_solid_push_L23
moving_solid_push_L22:
; return
    rts
    jmp moving_solid_push_L24
moving_solid_push_L23:
moving_solid_push_L24:
; if SOLID_OLD < T0:
    move.b SOLID_OLD,d0
    move.b T0,d1
    cmp.b d1,d0
    bcs moving_solid_push_L25
    jmp moving_solid_push_L26
moving_solid_push_L25:
; if T1 > ACTOR_POSITION:
    move.b T1,d0
    move.b ACTOR_POSITION,d1
    cmp.b d1,d0
    bhi moving_solid_push_L28
    jmp moving_solid_push_L29
moving_solid_push_L28:
; return
    rts
    jmp moving_solid_push_L30
moving_solid_push_L29:
moving_solid_push_L30:
    jmp moving_solid_push_L27
moving_solid_push_L26:
moving_solid_push_L27:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; if SOLID_NEW > SOLID_OLD:
    move.b SOLID_NEW,d0
    move.b SOLID_OLD,d1
    cmp.b d1,d0
    bhi moving_solid_push_L31
    jmp moving_solid_push_L32
moving_solid_push_L31:
; if T1 <= ACTOR_POSITION:
    move.b T1,d0
    move.b ACTOR_POSITION,d1
    cmp.b d1,d0
    bls moving_solid_push_L34
    jmp moving_solid_push_L35
moving_solid_push_L34:
; if T2 > ACTOR_POSITION:
    move.b T2,d0
    move.b ACTOR_POSITION,d1
    cmp.b d1,d0
    bhi moving_solid_push_L37
    jmp moving_solid_push_L38
moving_solid_push_L37:
; if T2 > MAXIMUM:
    move.b T2,d0
    move.b MAXIMUM,d1
    cmp.b d1,d0
    bhi moving_solid_push_L40
    jmp moving_solid_push_L41
moving_solid_push_L40:
; BLOCKED = 1
    move.b #1,d0
    move.b d0,BLOCKED
; return
    rts
    jmp moving_solid_push_L42
moving_solid_push_L41:
moving_solid_push_L42:
; T3 = T2 + ACTOR_SIZE
    move.b T2,d0
    move.b ACTOR_SIZE,d1
    add.b d1,d0
    move.b d0,T3
; if T3 < T2:
    move.b T3,d0
    move.b T2,d1
    cmp.b d1,d0
    bcs moving_solid_push_L43
    jmp moving_solid_push_L44
moving_solid_push_L43:
; BLOCKED = 1
    move.b #1,d0
    move.b d0,BLOCKED
; return
    rts
    jmp moving_solid_push_L45
moving_solid_push_L44:
moving_solid_push_L45:
; POSITION = T2
    move.b T2,d0
    move.b d0,POSITION
; PUSHED = 1
    move.b #1,d0
    move.b d0,PUSHED
    jmp moving_solid_push_L39
moving_solid_push_L38:
moving_solid_push_L39:
    jmp moving_solid_push_L36
moving_solid_push_L35:
moving_solid_push_L36:
    jmp moving_solid_push_L33
moving_solid_push_L32:
moving_solid_push_L33:
; if SOLID_NEW < SOLID_OLD:
    move.b SOLID_NEW,d0
    move.b SOLID_OLD,d1
    cmp.b d1,d0
    bcs moving_solid_push_L46
    jmp moving_solid_push_L47
moving_solid_push_L46:
; if SOLID_OLD >= T0:
    move.b SOLID_OLD,d0
    move.b T0,d1
    cmp.b d1,d0
    bcc moving_solid_push_L49
    jmp moving_solid_push_L50
moving_solid_push_L49:
; if SOLID_NEW < T0:
    move.b SOLID_NEW,d0
    move.b T0,d1
    cmp.b d1,d0
    bcs moving_solid_push_L52
    jmp moving_solid_push_L53
moving_solid_push_L52:
; if SOLID_NEW < ACTOR_SIZE:
    move.b SOLID_NEW,d0
    move.b ACTOR_SIZE,d1
    cmp.b d1,d0
    bcs moving_solid_push_L55
    jmp moving_solid_push_L56
moving_solid_push_L55:
; BLOCKED = 1
    move.b #1,d0
    move.b d0,BLOCKED
; return
    rts
    jmp moving_solid_push_L57
moving_solid_push_L56:
moving_solid_push_L57:
; T3 = SOLID_NEW - ACTOR_SIZE
    move.b SOLID_NEW,d0
    move.b ACTOR_SIZE,d1
    sub.b d1,d0
    move.b d0,T3
; if T3 < MINIMUM:
    move.b T3,d0
    move.b MINIMUM,d1
    cmp.b d1,d0
    bcs moving_solid_push_L58
    jmp moving_solid_push_L59
moving_solid_push_L58:
; BLOCKED = 1
    move.b #1,d0
    move.b d0,BLOCKED
; return
    rts
    jmp moving_solid_push_L60
moving_solid_push_L59:
moving_solid_push_L60:
; POSITION = T3
    move.b T3,d0
    move.b d0,POSITION
; PUSHED = 1
    move.b #1,d0
    move.b d0,PUSHED
    jmp moving_solid_push_L54
moving_solid_push_L53:
moving_solid_push_L54:
    jmp moving_solid_push_L51
moving_solid_push_L50:
moving_solid_push_L51:
    jmp moving_solid_push_L48
moving_solid_push_L47:
moving_solid_push_L48:
    rts
component_end:
