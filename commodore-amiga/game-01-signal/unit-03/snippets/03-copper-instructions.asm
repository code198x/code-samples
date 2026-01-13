; Copper Instructions
; The Copper has only two instructions, each 32 bits:
;
; MOVE: Write a value to a hardware register
; Format: $XXYY,$VVVV
;   XX = register offset / 2 (bits 8-1 of address)
;   YY = 00 (identifies as MOVE)
;   VVVV = 16-bit value to write
;
; Example: Set COLOR00 ($180) to red ($0f00)
            dc.w    COLOR00,$0f00       ; MOVE $0f00 to $dff180

; WAIT: Pause until beam reaches a position
; Format: $VVHH,$FFFE
;   VV = vertical line to wait for (0-255)
;   HH = horizontal position to wait for
;   $FFFE = identifies as WAIT

; Example: Wait for line 44 ($2c), horizontal 7
            dc.w    $2c07,$fffe         ; WAIT for Y=44, X=7

; Combine them for per-scanline effects:
            dc.w    $4407,$fffe         ; WAIT line 68
            dc.w    COLOR00,$0048       ; MOVE: blue background
            dc.w    $5c07,$fffe         ; WAIT line 92
            dc.w    COLOR00,$0444       ; MOVE: grey background
