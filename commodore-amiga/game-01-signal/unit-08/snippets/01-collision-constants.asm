; Collision Detection Constants
; Frog and car dimensions for bounding box checks

; Frog dimensions
FROG_HEIGHT     equ 16
FROG_WIDTH      equ 16

; Car dimensions
CAR_WIDTH_PX    equ 32          ; Pixels (not words!)
CAR_HEIGHT      equ 12

; Death animation
DEATH_FRAMES    equ 30          ; 0.6 seconds at 50fps
FLASH_COLOUR    equ $0f00       ; Red flash

; Road boundaries (grid rows)
ROAD_ROW_FIRST  equ 7
ROAD_ROW_LAST   equ 11

; Frog states
STATE_IDLE      equ 0
STATE_HOPPING   equ 1
STATE_DYING     equ 2           ; New state for death animation
