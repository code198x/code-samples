ld a, 22                ; AT command
        rst $10
        ld a, 10                ; Row 10
        rst $10
        ld a, 12                ; Column 12
        rst $10
        ; Now printing starts at row 10, column 12
