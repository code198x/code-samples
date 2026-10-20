# +3 mounted-A READY diagnostic

MIT assembly loaded by the ordinary +3DOS BASIC loader. The program seeks
protected drive A to cylinder9, acknowledges completion, then records Sense
Drive Status for logical unit0/head0 with motor on, off and on again. Only
1FFD bit3 changes; bit2 stays set and paging/ROM selection is unchanged.

Each five-byte record contains stage, result length, ST3, PCN-or255 and following
MSR. Stage0 is the two bounded setup drains; stages1–3 are the three motor states.
Every controller wait and drain is bounded. Each motor state uses the same finite
guest settling loop. This loop is an observation window, not a physical spin-up
or polling latency measurement. SDS does not acknowledge pending READY interrupts.

Completion writes A5/5A at7000/7001 and a fixed AA bitmap/47 attributes after the
commands. The host observes actual writes, the full loaded CODE and completion
PC, trace framing and all five input bits. No snapshot or memory injection is
part of the loading recipe. Empty drive sensors and other units are not tested.

Build with the existing native tools:

```sh
asm198x --dialect pasmo --cpu z80 --message-format=json diagnostic.asm -o diagnostic.bin
build198x plus3 --basic loader.bas --code diagnostic.bin --load-address 32768 -o diagnostic.dsk --format json
```

Cold boot the named English v4.0 +3 with the disk in internal drive A, select
Loader and let ROM load DISK and DIAG.BIN. Full bounded automation and separate
reference evidence are owned by the umbrella qualification runner.
