; Digit Font Data
; 8x8 pixel digits 0-9, 16 bytes each (8 words)

            even
digit_font:
; 0 - rounded rectangle with diagonal line
            dc.w    $3c00       ; ..####..
            dc.w    $6600       ; .##..##.
            dc.w    $6e00       ; .##.###.
            dc.w    $7e00       ; .######.
            dc.w    $7600       ; .###.##.
            dc.w    $6600       ; .##..##.
            dc.w    $3c00       ; ..####..
            dc.w    $0000
; 1 - simple vertical line with base
            dc.w    $1800       ; ...##...
            dc.w    $3800       ; ..###...
            dc.w    $1800       ; ...##...
            dc.w    $1800       ; ...##...
            dc.w    $1800       ; ...##...
            dc.w    $1800       ; ...##...
            dc.w    $7e00       ; .######.
            dc.w    $0000
; 2 - curves down then horizontal
            dc.w    $3c00       ; ..####..
            dc.w    $6600       ; .##..##.
            dc.w    $0600       ; .....##.
            dc.w    $1c00       ; ...###..
            dc.w    $3000       ; ..##....
            dc.w    $6000       ; .##.....
            dc.w    $7e00       ; .######.
            dc.w    $0000
; 3 - two bumps right side
            dc.w    $3c00       ; ..####..
            dc.w    $6600       ; .##..##.
            dc.w    $0600       ; .....##.
            dc.w    $1c00       ; ...###..
            dc.w    $0600       ; .....##.
            dc.w    $6600       ; .##..##.
            dc.w    $3c00       ; ..####..
            dc.w    $0000
; 4 - vertical meets horizontal
            dc.w    $0c00       ; ....##..
            dc.w    $1c00       ; ...###..
            dc.w    $3c00       ; ..####..
            dc.w    $6c00       ; .##.##..
            dc.w    $7e00       ; .######.
            dc.w    $0c00       ; ....##..
            dc.w    $0c00       ; ....##..
            dc.w    $0000
; 5 - horizontal then curve
            dc.w    $7e00       ; .######.
            dc.w    $6000       ; .##.....
            dc.w    $7c00       ; .#####..
            dc.w    $0600       ; .....##.
            dc.w    $0600       ; .....##.
            dc.w    $6600       ; .##..##.
            dc.w    $3c00       ; ..####..
            dc.w    $0000
; 6 - curve with internal loop
            dc.w    $1c00       ; ...###..
            dc.w    $3000       ; ..##....
            dc.w    $6000       ; .##.....
            dc.w    $7c00       ; .#####..
            dc.w    $6600       ; .##..##.
            dc.w    $6600       ; .##..##.
            dc.w    $3c00       ; ..####..
            dc.w    $0000
; 7 - diagonal from top
            dc.w    $7e00       ; .######.
            dc.w    $0600       ; .....##.
            dc.w    $0c00       ; ....##..
            dc.w    $1800       ; ...##...
            dc.w    $3000       ; ..##....
            dc.w    $3000       ; ..##....
            dc.w    $3000       ; ..##....
            dc.w    $0000
; 8 - two loops stacked
            dc.w    $3c00       ; ..####..
            dc.w    $6600       ; .##..##.
            dc.w    $6600       ; .##..##.
            dc.w    $3c00       ; ..####..
            dc.w    $6600       ; .##..##.
            dc.w    $6600       ; .##..##.
            dc.w    $3c00       ; ..####..
            dc.w    $0000
; 9 - loop with tail
            dc.w    $3c00       ; ..####..
            dc.w    $6600       ; .##..##.
            dc.w    $6600       ; .##..##.
            dc.w    $3e00       ; ..#####.
            dc.w    $0600       ; .....##.
            dc.w    $0c00       ; ....##..
            dc.w    $3800       ; ..###...
            dc.w    $0000
