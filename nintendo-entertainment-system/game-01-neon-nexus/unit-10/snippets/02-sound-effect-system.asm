.segment "ZEROPAGE"
sfx_timer:      .res 1      ; frames remaining for current sound
sfx_pitch:      .res 1      ; current pitch index (for sweeping)
sfx_type:       .res 1      ; which sound is playing (0=none)
