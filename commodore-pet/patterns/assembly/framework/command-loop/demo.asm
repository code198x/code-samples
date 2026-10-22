*=$0401
    !word basic_end
    !word 10
    !byte $9e
    !text "1040"
    !byte 0
basic_end:
    !word 0
    !fill $0410-*,0
    !source "caller.inc"
    !source "routines.inc"
    !source "presentation.inc"
