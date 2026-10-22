*=$1001
    !word basic_end
    !word 10
    !byte $9e
    !text "4112"
    !byte 0
basic_end:
    !word 0
    !fill $1010-*,0
    !source "caller.inc"
    !source "routines.inc"
    !source "presentation.inc"
