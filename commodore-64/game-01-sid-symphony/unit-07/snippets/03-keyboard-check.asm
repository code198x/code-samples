; Checking a single key using the keyboard matrix
;
; The C64 keyboard is an 8x8 matrix. To read a key:
; 1. Write to $DC00 to select which column (bit=0 selects)
; 2. Read $DC01 to see which rows are pressed (bit=0 means pressed)
;
; Q key is in column 7, row 6

KEYBOARD_COLUMN = $dc00         ; CIA1 Port A - write to select column
KEYBOARD_ROW    = $dc01         ; CIA1 Port B - read to check rows

check_quit:
                ; Select column 7 (bit 7 = 0, others = 1)
                lda #%01111111
                sta KEYBOARD_COLUMN

                ; Read rows - if bit 6 is 0, Q is pressed
                lda KEYBOARD_ROW
                and #%01000000
                bne .not_pressed

                ; Q is pressed - do something
                jmp exit_to_basic

.not_pressed:
                rts

; Keyboard matrix reference:
; Col 0: DEL,RET,→,F7,F1,F3,F5,↓
; Col 1: 3,W,A,4,Z,S,E,LSHIFT
; Col 2: 5,R,D,6,C,F,T,X
; Col 3: 7,Y,G,8,B,H,U,V
; Col 4: 9,I,J,0,M,K,O,N
; Col 5: +,P,L,-,.,COLON,@,COMMA
; Col 6: £,*,;,HOME,RSHIFT,=,↑,/
; Col 7: 1,←,CTRL,2,SPACE,C=,Q,STOP
