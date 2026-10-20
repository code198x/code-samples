# +3 mounted-A Track Zero diagnostic

MIT assembly loaded by the normal +3DOS BASIC loader. With motor on and protected
media mounted in A, the program performs Seek9, Recalibrate0 and Seek9. Each phase
records the bounded Sense Interrupt Status drain, including acknowledged PCN9/0/9,
then Sense Drive Status. T0 must change0/1/0; READY, WP and TS stay set and Fault
stays clear. Unit0/head0 is selected throughout.

Five-byte records contain stage, result length, ST3-or-ST0, PCN-or255 and following
MSR. Stage0 drains initial ROM/motor residue; stages1–3 correspond to the three
positions. Each phase ends with a terminal Invalid SIS record and one SDS result.
Every wait/drain is bounded. The finite settling loop is an observation window,
not a step-rate, physical track-sensor or mechanical timing measurement.

After the commands, the guest draws AA bitmap/47 attributes and writes A5/5A at
7000/7001. The runner requires actual program-originated writes, loaded CODE,
completion PC, screen memory, acknowledged positions and independent status bits.
Snapshots and memory injection are not part of the recipe. This does not qualify
Recalibrate/Seek beyond the position observations needed for this SDS case.

Build with the existing native tools:

```sh
asm198x --dialect pasmo --cpu z80 --message-format=json diagnostic.asm -o diagnostic.bin
build198x plus3 --basic loader.bas --code diagnostic.bin --load-address 32768 -o diagnostic.dsk --format json
```

Cold boot the named English v4.0 +3 with the DSK in internal A and select Loader.
The umbrella runner owns exact bounded automation, identities and reference proof.
