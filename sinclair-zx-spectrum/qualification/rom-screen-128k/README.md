# 128K ROM and screen selection diagnostic

This 250-byte MIT program produces alternating white/black columns in screen
bank 5 and the opposite columns in bank 7. It computes the sum of every byte
in the CPU's ROM window modulo 65536 at each of nine phases. The host checks
these readbacks and the actual rendered pixels before accepting completion.

Build with Asm198x's existing BASIC+CODE tape writer:

```sh
asm198x --dialect pasmo --cpu z80 --tapbas diagnostic.asm -o diagnostic.tap
```

Cold-boot the named UK PAL Spectrum 128K/7K010E with its two legitimate local
ROMs, insert the tape and select Tape Loader. The BASIC stub loads code at
`$8000` and calls it. Do not inject memory or restore a snapshot for this test.
Code and stack remain in fixed RAM bank 2; generated observations at `$7000`
are outside the payload.

| Phase | Write to `$7FFD` | Expected ROM | Expected display bank |
| --- | --- | --- | --- |
| 1 | `$07` | 0 | 5 |
| 2 | `$17` | 1 | 5 |
| 3 | `$0F` | 0 | 7 |
| 4 | `$1F` | 1 | 7 |
| 5 | `$07` | 0 | 5 |
| 6 | `$3F` | 1, now locked | 7, now locked |
| 7 | `$0F` | 1 | 7 |
| 8 | `$17` | 1 | 7 |
| 9 | `$07` | 1 | 7 |

`$7002` records the current phase; `$7003–7004` hold the little-endian computed
sum. The exact UK ROM pair sums are 29117 and 34348. These distinguish the
two named pages; the runner separately identifies the complete firmware by
SHA-256. The delay at each `phaseN` label allows several full rendered frames.
The program finally computes bytes 90,91 at `$7000–7001` and loops at `$80CB`.
Completion alone does not mean the paging checks passed: the host must verify
all nine phases, including every active display pixel.

Recipe v2 adds the two mixed unlocked pairs, so coupling the ROM and display
selectors cannot pass. The earlier seven-phase v1 evidence remains historical.

The source basis is the [ZX Spectrum 128 Service Manual](https://spectrumforeveryone.com/wp-content/uploads/2017/11/ZX-Spectrum-128-Service-Manual.pdf),
section 1.3, printed page 6: bit 3 selects display page 5/7, bit 4 selects ROM
0/1, and bit 5 prevents further access to the register. This fixture locks
both selectors set; it does not test lock with either selector clear, reset,
other firmware/models, paging-port aliases or timing accuracy.

The umbrella's `ops/qualification/run.py --recipe 128k-rom-screen` supplies the
reviewed recipe, instruction/frame and host limits, pixel assertions, independent
Pasmo/MAME comparison and machine-readable evidence. `--omit-paging-lock`
changes only `$3F` to `$1F`: loading should succeed, but qualification must fail.
