; ----------------------------------------------------------------------------
; Results Screen with Continue Prompt
; ----------------------------------------------------------------------------
; Shows winner message and "PRESS ANY KEY" prompt

; Constants
CONTINUE_ROW equ    22              ; "PRESS ANY KEY" after results
CONTINUE_COL equ    9               ; (32-13)/2 = 9.5

; Message
msg_continue:   defb    "PRESS ANY KEY", 0

; After displaying winner message, show continue prompt:
.sr_continue:
            ; Display "PRESS ANY KEY" prompt
            ld      b, CONTINUE_ROW
            ld      c, CONTINUE_COL
            ld      hl, msg_continue
            ld      e, TEXT_ATTR
            call    print_message
            ret
