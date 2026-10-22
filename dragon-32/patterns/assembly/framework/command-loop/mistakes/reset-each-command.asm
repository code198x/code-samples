; Deliberately broken: initialisation inside every iteration.
; SPDX-License-Identifier: MIT
    org $7000
INITIAL equ 0
STEP equ 1
RESET_EACH equ 1
DRAW equ 1
SOUND equ 1
    include "caller.inc"
    include "routines.inc"
