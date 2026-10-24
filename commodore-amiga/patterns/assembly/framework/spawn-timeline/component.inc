; SPDX-License-Identifier: MIT
; Service a Small Spawn Timeline. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
spawn_timeline_init:
    move.b #0,d0
    move.b d0,EVENT
    move.b d0,FIRED
    move.b d0,INDEX
    move.b d0,WAIT
    move.b d0,COUNT
    move.b d0,DONE
    move.b d0,VALID
    move.b d0,E0
    move.b d0,E1
    move.b d0,E2
    move.b d0,E3
    move.b d0,L0
    move.b d0,L1
    move.b d0,L2
    move.b d0,L3
    move.b d0,T0
    rts
spawn_timeline_step:
; EVENT = 255
    move.b #255,d0
    move.b d0,EVENT
; FIRED = 0
    move.b #0,d0
    move.b d0,FIRED
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if COUNT == 0:
    move.b COUNT,d0
    cmp.b #0,d0
    beq spawn_timeline_L1
    jmp spawn_timeline_L2
spawn_timeline_L1:
; return
    rts
    jmp spawn_timeline_L3
spawn_timeline_L2:
spawn_timeline_L3:
; if COUNT > 4:
    move.b COUNT,d0
    cmp.b #4,d0
    bhi spawn_timeline_L4
    jmp spawn_timeline_L5
spawn_timeline_L4:
; return
    rts
    jmp spawn_timeline_L6
spawn_timeline_L5:
spawn_timeline_L6:
; if INDEX >= COUNT:
    move.b INDEX,d0
    move.b COUNT,d1
    cmp.b d1,d0
    bcc spawn_timeline_L7
    jmp spawn_timeline_L8
spawn_timeline_L7:
; return
    rts
    jmp spawn_timeline_L9
spawn_timeline_L8:
spawn_timeline_L9:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; if DONE != 0:
    move.b DONE,d0
    cmp.b #0,d0
    bne spawn_timeline_L10
    jmp spawn_timeline_L11
spawn_timeline_L10:
; return
    rts
    jmp spawn_timeline_L12
spawn_timeline_L11:
spawn_timeline_L12:
; T0 = L[INDEX]
    moveq #0,d1
    move.b INDEX,d1
    lea L0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T0
; if WAIT < T0:
    move.b WAIT,d0
    move.b T0,d1
    cmp.b d1,d0
    bcs spawn_timeline_L13
    jmp spawn_timeline_L14
spawn_timeline_L13:
; WAIT = WAIT + 1
    move.b WAIT,d0
    add.b #1,d0
    move.b d0,WAIT
; return
    rts
    jmp spawn_timeline_L15
spawn_timeline_L14:
spawn_timeline_L15:
; EVENT = E[INDEX]
    moveq #0,d1
    move.b INDEX,d1
    lea E0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,EVENT
; FIRED = 1
    move.b #1,d0
    move.b d0,FIRED
; WAIT = 0
    move.b #0,d0
    move.b d0,WAIT
; T0 = COUNT - 1
    move.b COUNT,d0
    sub.b #1,d0
    move.b d0,T0
; if INDEX < T0:
    move.b INDEX,d0
    move.b T0,d1
    cmp.b d1,d0
    bcs spawn_timeline_L16
    jmp spawn_timeline_L17
spawn_timeline_L16:
; INDEX = INDEX + 1
    move.b INDEX,d0
    add.b #1,d0
    move.b d0,INDEX
    jmp spawn_timeline_L18
spawn_timeline_L17:
; DONE = 1
    move.b #1,d0
    move.b d0,DONE
spawn_timeline_L18:
    rts
component_end:
