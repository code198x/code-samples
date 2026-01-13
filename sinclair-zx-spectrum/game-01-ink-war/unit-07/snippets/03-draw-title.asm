; ----------------------------------------------------------------------------
; Draw Title Screen
; ----------------------------------------------------------------------------
; Displays game title and prompt

draw_title_screen:
            ; Draw "INK WAR" title
            ld      b, TITLE_ROW
            ld      c, TITLE_COL
            ld      hl, msg_title
            ld      e, TEXT_ATTR
            call    print_message

            ; Draw "PRESS ANY KEY TO START" prompt
            ld      b, PROMPT_ROW
            ld      c, PROMPT_COL
            ld      hl, msg_prompt
            ld      e, TEXT_ATTR
            call    print_message

            ret

; Messages
msg_title:      defb    "INK WAR", 0
msg_prompt:     defb    "PRESS ANY KEY TO START", 0
