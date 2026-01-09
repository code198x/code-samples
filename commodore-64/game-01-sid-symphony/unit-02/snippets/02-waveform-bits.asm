; Waveform selection bits (combine with GATE_ON using OR)
GATE_ON         = %00000001         ; Bit 0: Gate on/off
WAVE_TRI        = %00010000         ; Bit 4: Triangle wave
WAVE_SAW        = %00100000         ; Bit 5: Sawtooth wave
WAVE_PULSE      = %01000000         ; Bit 6: Pulse wave
WAVE_NOISE      = %10000000         ; Bit 7: Noise

; Example: Sawtooth with gate on
lda #WAVE_SAW | GATE_ON             ; = %00100001 = $21
sta SID_V1_CTRL
