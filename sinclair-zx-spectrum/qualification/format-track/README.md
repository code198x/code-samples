# Format Track through the +3 ROM disk loader

MIT. The authored BASIC loader loads CODE at 32768 and executes it. The guest
seeks scratch track 39, acknowledges Seek, selects non-DMA mode and formats two
128-byte sectors in physical order 5,2 with filler 0x6D. It records Format and
Read ID results, reads both sectors and checks every byte. Only then does it
fill screen RAM with 0xAA/0x47 and write A5/5A at 0x7000 outside the loaded CODE.

Build with the family tools:

```sh
asm198x --dialect pasmo --cpu z80 --message-format=json diagnostic.asm -o diagnostic.bin
build198x plus3 --basic loader.bas --code diagnostic.bin --load-address 32768 -o diagnostic.dsk --format json
```

Cold boot a PAL+3 with English 4.0 ROMs, mount a disposable writable copy of
this disk in A and select Loader. Track39 lies outside these small loader/CODE
allocations. Emu keeps writes in memory; other runtimes may write to their
input image, which is why the reference runner uses a separate copy.
No injection, quickload or snapshot restoration is part of the loading path.

The trace starts at 0x7010 in five-byte rows. Stage 0 records bounded SIS drains
and the track 39 Seek acknowledgement. Stages 1–3 each use two rows for seven
result bytes and following MSR: stage,ST0,ST1,ST2,C then stage,H,R,N,MSR.
Stages 4–5 add a payload row: stage,128,128,sum-mod256,XOR. The observed sum is 128
and XOR 0; the guest also compares every byte, so matching checksums alone
cannot produce success. Metadata at 0x7000 is signature, row count and stage 5.

Tight INI/OUTI loops service MFM transfers before doing payload comparisons.
Every send/receive polling loop has a 65536-poll bound. Settling is finite;
the host must also bound frames and wall time. Completion/failure loops remain
observable. The umbrella `format_guest.py` supplies the bounds and records
source, tools, firmware, native structure and expected/observed results.

The [December 1978 NEC datasheet](https://bitsavers.org/components/nec/_dataSheets/uPD765_Data_Sheet_Dec78.pdf), printed page 14, specifies command N, filler D,
supplied CHRN and result R+1. This fixture records independent-runtime
disagreements separately. It does not qualify all Format cases, active READY,
Fault, interrupted hardware CHRN, raw gaps/flux, physical timing, other models
or neighbouring operations.
