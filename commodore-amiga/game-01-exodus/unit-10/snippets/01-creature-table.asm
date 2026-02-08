; Creature data table offsets (bytes per field)
CR_X                equ 0           ; .w x position
CR_Y                equ 2           ; .w y position
CR_DX               equ 4           ; .w direction
CR_STATE            equ 6           ; .w state (0=walk, 1=fall)
CR_STEP             equ 8           ; .w step timer
CR_SIZE             equ 10          ; Total bytes per creature

NUM_CREATURES       equ 3

            ; ...

creatures:
            dcb.b   CR_SIZE*NUM_CREATURES,0
