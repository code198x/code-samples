ORG $0000
FC EQU $3c00
COLS EQU 40
ROWS EQU 25
start:
    di
    ld sp,$3ff0
    ld hl,$3000
    ld de,$3001
    ld bc,1023
    ld (hl),32
    ldir
    ld hl,$3400
    ld de,$3401
    ld bc,1023
    ld (hl),$f0
    ldir
case_0:
    ld hl,pictures
    ld (FC),hl
    ld a,2
    ld (FC+2),a
    ld a,0
    ld (FC+3),a
    ld a,6
    ld (FC+4),a
    ld a,31
    ld (FC+7),a
    call character_span
    ld a,(FC+5)
    or 128
    ld ($3c20),a
case_1:
    ld hl,pictures
    ld (FC),hl
    ld a,0
    ld (FC+2),a
    ld a,1
    ld (FC+3),a
    ld a,40
    ld (FC+4),a
    ld a,31
    ld (FC+7),a
    call character_span
    ld a,(FC+5)
    or 128
    ld ($3c21),a
case_2:
    ld hl,pictures
    ld (FC),hl
    ld a,39
    ld (FC+2),a
    ld a,2
    ld (FC+3),a
    ld a,1
    ld (FC+4),a
    ld a,31
    ld (FC+7),a
    call character_span
    ld a,(FC+5)
    or 128
    ld ($3c22),a
case_3:
    ld hl,pictures
    ld (FC),hl
    ld a,0
    ld (FC+2),a
    ld a,24
    ld (FC+3),a
    ld a,1
    ld (FC+4),a
    ld a,31
    ld (FC+7),a
    call character_span
    ld a,(FC+5)
    or 128
    ld ($3c23),a
case_4:
    ld hl,pictures
    ld (FC),hl
    ld a,40
    ld (FC+2),a
    ld a,0
    ld (FC+3),a
    ld a,1
    ld (FC+4),a
    ld a,31
    ld (FC+7),a
    call character_span
    ld a,(FC+5)
    or 128
    ld ($3c24),a
case_5:
    ld hl,pictures
    ld (FC),hl
    ld a,0
    ld (FC+2),a
    ld a,25
    ld (FC+3),a
    ld a,1
    ld (FC+4),a
    ld a,31
    ld (FC+7),a
    call character_span
    ld a,(FC+5)
    or 128
    ld ($3c25),a
case_6:
    ld hl,pictures
    ld (FC),hl
    ld a,0
    ld (FC+2),a
    ld a,0
    ld (FC+3),a
    ld a,0
    ld (FC+4),a
    ld a,31
    ld (FC+7),a
    call character_span
    ld a,(FC+5)
    or 128
    ld ($3c26),a
case_7:
    ld hl,pictures
    ld (FC),hl
    ld a,39
    ld (FC+2),a
    ld a,0
    ld (FC+3),a
    ld a,2
    ld (FC+4),a
    ld a,31
    ld (FC+7),a
    call character_span
    ld a,(FC+5)
    or 128
    ld ($3c27),a
case_8:
    ld hl,pictures
    ld (FC),hl
    ld a,255
    ld (FC+2),a
    ld a,0
    ld (FC+3),a
    ld a,2
    ld (FC+4),a
    ld a,31
    ld (FC+7),a
    call character_span
    ld a,(FC+5)
    or 128
    ld ($3c28),a
case_9:
    ld hl,pictures
    ld (FC),hl
    ld a,0
    ld (FC+2),a
    ld a,255
    ld (FC+3),a
    ld a,1
    ld (FC+4),a
    ld a,31
    ld (FC+7),a
    call character_span
    ld a,(FC+5)
    or 128
    ld ($3c29),a
case_10:
    ld hl,pictures
    ld (FC),hl
    ld a,0
    ld (FC+2),a
    ld a,0
    ld (FC+3),a
    ld a,255
    ld (FC+4),a
    ld a,31
    ld (FC+7),a
    call character_span
    ld a,(FC+5)
    or 128
    ld ($3c2a),a
case_11:
    ld hl,pictures
    ld (FC),hl
    ld a,0
    ld (FC+2),a
    ld a,0
    ld (FC+3),a
    ld a,1
    ld (FC+4),a
    ld a,31
    ld (FC+7),a
    call character_span
    ld a,(FC+5)
    or 128
    ld ($3c2b),a
    ld a,239
    ld ($3c3f),a
done:
    jp done
    INCLUDE "characters.inc"
pictures:
    db 65,66,67,68,69,70,65,66,67,68,69,70,65,66,67,68,69,70,65,66,67,68,69,70,65,66,67,68,69,70,65,66,67,68,69,70,65,66,67,68,69,70
bad_picture:
    db 118,38
inverse_picture:
    db 166
