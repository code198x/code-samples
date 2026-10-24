; SPDX-License-Identifier: MIT
; Limit Hits to an Attack Window. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
attack_hit_window_init:
    move.b #0,d0
    move.b d0,HIT
    move.b d0,VALID
    move.b d0,SEEN
    move.b d0,FRAME
    move.b d0,START_FRAME
    move.b d0,END_FRAME
    move.b d0,TARGET
    move.b d0,CONTACT
    move.b d0,NEW_ATTACK
    move.b d0,T0
    move.b d0,T1
    rts
attack_hit_window_step:
; HIT = 0
    move.b #0,d0
    move.b d0,HIT
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if START_FRAME >= END_FRAME:
    move.b START_FRAME,d0
    move.b END_FRAME,d1
    cmp.b d1,d0
    bcc attack_hit_window_L1
    jmp attack_hit_window_L2
attack_hit_window_L1:
; return
    rts
    jmp attack_hit_window_L3
attack_hit_window_L2:
attack_hit_window_L3:
; if TARGET >= 8:
    move.b TARGET,d0
    cmp.b #8,d0
    bcc attack_hit_window_L4
    jmp attack_hit_window_L5
attack_hit_window_L4:
; return
    rts
    jmp attack_hit_window_L6
attack_hit_window_L5:
attack_hit_window_L6:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; if NEW_ATTACK != 0:
    move.b NEW_ATTACK,d0
    cmp.b #0,d0
    bne attack_hit_window_L7
    jmp attack_hit_window_L8
attack_hit_window_L7:
; SEEN = 0
    move.b #0,d0
    move.b d0,SEEN
    jmp attack_hit_window_L9
attack_hit_window_L8:
attack_hit_window_L9:
; if FRAME < START_FRAME:
    move.b FRAME,d0
    move.b START_FRAME,d1
    cmp.b d1,d0
    bcs attack_hit_window_L10
    jmp attack_hit_window_L11
attack_hit_window_L10:
; return
    rts
    jmp attack_hit_window_L12
attack_hit_window_L11:
attack_hit_window_L12:
; if FRAME >= END_FRAME:
    move.b FRAME,d0
    move.b END_FRAME,d1
    cmp.b d1,d0
    bcc attack_hit_window_L13
    jmp attack_hit_window_L14
attack_hit_window_L13:
; return
    rts
    jmp attack_hit_window_L15
attack_hit_window_L14:
attack_hit_window_L15:
; if CONTACT == 0:
    move.b CONTACT,d0
    cmp.b #0,d0
    beq attack_hit_window_L16
    jmp attack_hit_window_L17
attack_hit_window_L16:
; return
    rts
    jmp attack_hit_window_L18
attack_hit_window_L17:
attack_hit_window_L18:
; T0 = 1
    move.b #1,d0
    move.b d0,T0
; T1 = TARGET
    move.b TARGET,d0
    move.b d0,T1
; while T1 != 0:
attack_hit_window_L19:
    move.b T1,d0
    cmp.b #0,d0
    bne attack_hit_window_L20
    jmp attack_hit_window_L21
attack_hit_window_L20:
; T0 = T0 << 1
    move.b T0,d0
    lsl.b #1,d0
    move.b d0,T0
; T1 = T1 - 1
    move.b T1,d0
    sub.b #1,d0
    move.b d0,T1
    jmp attack_hit_window_L19
attack_hit_window_L21:
; T1 = SEEN & T0
    move.b SEEN,d0
    move.b T0,d1
    and.b d1,d0
    move.b d0,T1
; if T1 == 0:
    move.b T1,d0
    cmp.b #0,d0
    beq attack_hit_window_L22
    jmp attack_hit_window_L23
attack_hit_window_L22:
; SEEN = SEEN | T0
    move.b SEEN,d0
    move.b T0,d1
    or.b d1,d0
    move.b d0,SEEN
; HIT = 1
    move.b #1,d0
    move.b d0,HIT
    jmp attack_hit_window_L24
attack_hit_window_L23:
attack_hit_window_L24:
    rts
component_end:
