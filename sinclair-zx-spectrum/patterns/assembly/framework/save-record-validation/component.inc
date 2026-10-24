; SPDX-License-Identifier: MIT
; Validate a Save Before Replacing Live State. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
save_record_validation_init:
    ld a,0
    ld (ACCEPTED),a
    ld (VALID),a
    ld (MODE),a
    ld (L0),a
    ld (L1),a
    ld (L2),a
    ld (L3),a
    ld (C0),a
    ld (C1),a
    ld (C2),a
    ld (C3),a
    ld (C4),a
    ld (C5),a
    ld (C6),a
    ld (C7),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ret
save_record_validation_step:
; ACCEPTED = 0
    ld a,0
    ld (ACCEPTED),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if MODE > 1:
    ld a,(MODE)
    cp 1
    jp z,save_record_validation_L2
    jp nc,save_record_validation_L1
    jp save_record_validation_L2
save_record_validation_L1:
; return
    ret
    jp save_record_validation_L3
save_record_validation_L2:
save_record_validation_L3:
; VALID = 1
    ld a,1
    ld (VALID),a
; if C0 != 198:
    ld a,(C0)
    cp 198
    jp nz,save_record_validation_L4
    jp save_record_validation_L5
save_record_validation_L4:
; return
    ret
    jp save_record_validation_L6
save_record_validation_L5:
save_record_validation_L6:
; if C1 != 1:
    ld a,(C1)
    cp 1
    jp nz,save_record_validation_L7
    jp save_record_validation_L8
save_record_validation_L7:
; return
    ret
    jp save_record_validation_L9
save_record_validation_L8:
save_record_validation_L9:
; if C2 != 4:
    ld a,(C2)
    cp 4
    jp nz,save_record_validation_L10
    jp save_record_validation_L11
save_record_validation_L10:
; return
    ret
    jp save_record_validation_L12
save_record_validation_L11:
save_record_validation_L12:
; if C3 > 15:
    ld a,(C3)
    cp 15
    jp z,save_record_validation_L14
    jp nc,save_record_validation_L13
    jp save_record_validation_L14
save_record_validation_L13:
; return
    ret
    jp save_record_validation_L15
save_record_validation_L14:
save_record_validation_L15:
; if C4 > 31:
    ld a,(C4)
    cp 31
    jp z,save_record_validation_L17
    jp nc,save_record_validation_L16
    jp save_record_validation_L17
save_record_validation_L16:
; return
    ret
    jp save_record_validation_L18
save_record_validation_L17:
save_record_validation_L18:
; if C5 > 9:
    ld a,(C5)
    cp 9
    jp z,save_record_validation_L20
    jp nc,save_record_validation_L19
    jp save_record_validation_L20
save_record_validation_L19:
; return
    ret
    jp save_record_validation_L21
save_record_validation_L20:
save_record_validation_L21:
; if C6 > 15:
    ld a,(C6)
    cp 15
    jp z,save_record_validation_L23
    jp nc,save_record_validation_L22
    jp save_record_validation_L23
save_record_validation_L22:
; return
    ret
    jp save_record_validation_L24
save_record_validation_L23:
save_record_validation_L24:
; T0 = 0
    ld a,0
    ld (T0),a
; T1 = 0
    ld a,0
    ld (T1),a
; while T0 < 7:
save_record_validation_L25:
    ld a,(T0)
    cp 7
    jp c,save_record_validation_L26
    jp save_record_validation_L27
save_record_validation_L26:
; T2 = C[T0]
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,C0
    add hl,de
    ld a,(hl)
    ld (T2),a
; T1 = T1 ^ T2
    ld a,(T1)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    xor c
    ld (T1),a
; T0 = T0 + 1
    ld a,(T0)
    add a,1
    ld (T0),a
    jp save_record_validation_L25
save_record_validation_L27:
; if T1 != C7:
    ld a,(T1)
    ld b,a
    ld a,(C7)
    ld c,a
    ld a,b
    cp c
    jp nz,save_record_validation_L28
    jp save_record_validation_L29
save_record_validation_L28:
; return
    ret
    jp save_record_validation_L30
save_record_validation_L29:
save_record_validation_L30:
; ACCEPTED = 1
    ld a,1
    ld (ACCEPTED),a
; if MODE == 1:
    ld a,(MODE)
    cp 1
    jp z,save_record_validation_L31
    jp save_record_validation_L32
save_record_validation_L31:
; L0 = C3
    ld a,(C3)
    ld (L0),a
; L1 = C4
    ld a,(C4)
    ld (L1),a
; L2 = C5
    ld a,(C5)
    ld (L2),a
; L3 = C6
    ld a,(C6)
    ld (L3),a
    jp save_record_validation_L33
save_record_validation_L32:
save_record_validation_L33:
    ret
component_end:
