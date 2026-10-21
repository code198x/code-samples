# Read ID through the +3 ROM disk loader

MIT. The authored loader loads DIAG.BIN at32768 and executes it. The guest
seeks physical A to track9, acknowledges completion, then issues twelve MFM
Read ID commands, alternating logical units0/2. Both select the +3 internal A.
It records seven-byte results at0x7010, fills screen RAM with0xAA/0x47 and
writes A5/5A to0x7000 outside the CODE payload only after the command sequence.

Use Asm198x --dialect pasmo --cpu z80 --message-format=json diagnostic.asm
-o diagnostic.bin, then Build198x plus3 --basic loader.bas --code diagnostic.bin
--load-address32768 -o diagnostic.dsk --format json (put the option and value
in separate arguments). Cold boot a PAL+3 with English4.0 ROMs and this disk
in A, then select Loader. No injection or snapshot is used.

All send/receive loops have a65536-poll bound. The controller settling loop
is finite; the host must also bound emulated frames and wall time. Completion
and failure loops deliberately remain observable. The umbrella read_id_guest.py
runner supplies those bounds and machine-readable observations.

Twelve successful IDs must have C=9,H=0,N=2 and R in1..9. The Emu call-driven
cursor gives1..9,1..3; the independent reference has real rotation and may start
elsewhere or skip sectors between calls. Its comparison is recorded separately.
This diagnostic does not claim angular/index/mechanical/density fidelity.
