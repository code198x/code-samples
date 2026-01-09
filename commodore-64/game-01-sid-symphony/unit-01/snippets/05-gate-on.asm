; Control register bits
GATE_ON         = %00000001         ; Bit 0: Gate (triggers ADSR)
WAVEFORM_PULSE  = %01000000         ; Bit 6: Pulse wave

                ; Select pulse waveform and open the gate
                lda #WAVEFORM_PULSE | GATE_ON
                sta SID_V1_CTRL
