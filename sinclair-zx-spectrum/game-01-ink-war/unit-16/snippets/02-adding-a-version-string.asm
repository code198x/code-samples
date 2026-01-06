show_title:
        ; ... existing title code ...

        ; Print version at row 21
        ld a, 22
        rst $10
        ld a, 21
        rst $10
        ld a, 14
        rst $10
        ld hl, msg_version
        call print_string

        ret
