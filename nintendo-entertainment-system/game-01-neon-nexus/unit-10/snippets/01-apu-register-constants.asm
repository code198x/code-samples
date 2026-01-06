; APU Registers
APU_PULSE1_CTRL = $4000     ; duty, envelope, volume
APU_PULSE1_SWEEP = $4001    ; sweep control
APU_PULSE1_TIMER_LO = $4002 ; frequency low byte
APU_PULSE1_TIMER_HI = $4003 ; frequency high + length

APU_PULSE2_CTRL = $4004
APU_PULSE2_SWEEP = $4005
APU_PULSE2_TIMER_LO = $4006
APU_PULSE2_TIMER_HI = $4007

APU_STATUS = $4015          ; channel enable flags
APU_FRAME = $4017           ; frame counter control
