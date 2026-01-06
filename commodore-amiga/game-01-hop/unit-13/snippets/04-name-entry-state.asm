; Name entry state variables
entry_position: ds.w    1       ; Current position (0-2)
entry_chars:    ds.b    4       ; Three characters + null
hs_position:    ds.w    1       ; Which high score slot

init_name_entry:
            ; Initialise for name entry
            clr.w   entry_position
            move.b  #'A',entry_chars
            move.b  #'A',entry_chars+1
            move.b  #'A',entry_chars+2
            clr.b   entry_chars+3   ; Null terminator
            move.w  #MODE_ENTRY,game_mode
            rts
