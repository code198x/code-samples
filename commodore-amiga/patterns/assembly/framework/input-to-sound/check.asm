    section code,code
    include "input.inc"
    include "presses.inc"
    include "../../audio/playing-a-sample/paula-sample.inc"
    include "use.asm"
    section data,data_c
    even
waveform: dc.b 0,49,90,117,127,117,90,49,0,-49,-90,-117,-127,-117,-90,-49
