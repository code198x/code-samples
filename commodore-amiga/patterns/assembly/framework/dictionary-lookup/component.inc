; SPDX-License-Identifier: MIT
; Look Up a Bounded Byte Dictionary. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
dictionary_lookup_init:
    move.b #0,d0
    move.b d0,VALUE
    move.b d0,FOUND
    move.b d0,VALID
    move.b d0,KEY
    move.b d0,COUNT
    move.b d0,K0
    move.b d0,K1
    move.b d0,K2
    move.b d0,K3
    move.b d0,K4
    move.b d0,K5
    move.b d0,K6
    move.b d0,K7
    move.b d0,Q0
    move.b d0,Q1
    move.b d0,Q2
    move.b d0,Q3
    move.b d0,Q4
    move.b d0,Q5
    move.b d0,Q6
    move.b d0,Q7
    move.b d0,T0
    move.b d0,T1
    rts
dictionary_lookup_step:
; VALUE = 0
    move.b #0,d0
    move.b d0,VALUE
; FOUND = 0
    move.b #0,d0
    move.b d0,FOUND
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if COUNT > 8:
    move.b COUNT,d0
    cmp.b #8,d0
    bhi dictionary_lookup_L1
    jmp dictionary_lookup_L2
dictionary_lookup_L1:
; return
    rts
    jmp dictionary_lookup_L3
dictionary_lookup_L2:
dictionary_lookup_L3:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; T0 = 0
    move.b #0,d0
    move.b d0,T0
; while T0 < COUNT:
dictionary_lookup_L4:
    move.b T0,d0
    move.b COUNT,d1
    cmp.b d1,d0
    bcs dictionary_lookup_L5
    jmp dictionary_lookup_L6
dictionary_lookup_L5:
; T1 = K[T0]
    moveq #0,d1
    move.b T0,d1
    lea K0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T1
; if KEY == T1:
    move.b KEY,d0
    move.b T1,d1
    cmp.b d1,d0
    beq dictionary_lookup_L7
    jmp dictionary_lookup_L8
dictionary_lookup_L7:
; T1 = Q[T0]
    moveq #0,d1
    move.b T0,d1
    lea Q0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T1
; VALUE = T1
    move.b T1,d0
    move.b d0,VALUE
; FOUND = 1
    move.b #1,d0
    move.b d0,FOUND
; return
    rts
    jmp dictionary_lookup_L9
dictionary_lookup_L8:
dictionary_lookup_L9:
; T0 = T0 + 1
    move.b T0,d0
    add.b #1,d0
    move.b d0,T0
    jmp dictionary_lookup_L4
dictionary_lookup_L6:
    rts
component_end:
