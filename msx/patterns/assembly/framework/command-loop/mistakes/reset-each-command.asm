; Deliberately broken: erase rule state inside the iteration.
; SPDX-License-Identifier: MIT
    org $C000
INITIAL equ 0
STEP equ 1
RESET_EACH equ 1
NO_EDGE equ 0
    include "caller.inc"
    include "routines.inc"
    include "presentation.inc"
