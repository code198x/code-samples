; VIC-II Character Memory Pointer ($D018)
;
; The VIC-II chip uses $D018 to find both screen memory and character data.
;
; Bits 4-7: Screen memory location (within VIC bank)
; Bits 1-3: Character memory location (within VIC bank)
; Bit 0:    Not used for memory selection
;
; Character memory calculation:
;   Location = (bits 1-3) * $0800
;
;   %000 = $0000  (not usable - zero page)
;   %001 = $0800
;   %010 = $1000  (default: character ROM mapped here)
;   %011 = $1800
;   %100 = $2000
;   %101 = $2800
;   %110 = $3000  <- We use this
;   %111 = $3800
;
; For charset at $3000 with screen at $0400:
;   Screen: $0400 / $0400 = 1, bits 4-7 = %0001 = $10
;   Charset: $3000 / $0800 = 6, bits 1-3 = %110 = $0C
;   Combined: $10 | $0C = $1C

CHARPTR     = $D018

            lda #$1C            ; Screen at $0400, charset at $3000
            sta CHARPTR         ; VIC now uses our custom characters
