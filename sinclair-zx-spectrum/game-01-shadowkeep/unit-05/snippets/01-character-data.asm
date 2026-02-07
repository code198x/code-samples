            ; Player character — 8 bytes, one per pixel row
            ;
            ; Each bit = one pixel. 1 = INK colour, 0 = PAPER colour.
            ;
            ;   Byte    Binary      Pattern
            ;   $18     00011000    ...##...
            ;   $3C     00111100    ..####..
            ;   $7E     01111110    .######.
            ;   $FF     11111111    ########
            ;   $FF     11111111    ########
            ;   $7E     01111110    .######.
            ;   $3C     00111100    ..####..
            ;   $18     00011000    ...##...

player_gfx: db      $18, $3c, $7e, $ff
            db      $ff, $7e, $3c, $18
