# Playing a sample on Paula

The maintained source for the Playing a Sample pattern. Target: A500 PAL,
OCS, Kickstart 1.3, started from its own boot disk. `make` builds `demo` and
the bootable `demo.adf` with Asm198x and Build198x. The demo plays three
one-second tones on audio channel 0, then stays silent with a green screen.

The contract is in `paula-sample.inc`. `play_sample` takes the custom-chip
base in A5, an even chip-RAM sample address in A0, its length in words in D0,
the period in D1 and the volume in D2. It writes AUD0LC, AUD0LEN, AUD0PER and
AUD0VOL, then sets DMAEN and AUD0EN in DMACON. Channel 0 repeats the sample
until `stop_sample` clears AUD0EN. Neither routine changes a register.

The caller owns channel 0, the audio and master DMA bits, and channel 0's
interrupt. The demo takes over the whole machine to get that: it disables
every interrupt and DMA channel and never returns to AmigaDOS. A program that
shares the machine with the operating system allocates channels through
`audio.device` instead.

The period is colour clocks per output sample, not a note. The tone's
frequency is `clock / (period * samples per cycle)`, with a PAL clock of
3,546,895 Hz. The demo plays a 16-byte cycle at period 424 (522.8 Hz), the
same cycle at period 212 (1045.7 Hz), and a 32-byte cycle at period 212
(522.8 Hz again).

Run the executable check with:

```sh
python3 verification/verify.py --emulator /path/to/emu198x-amiga \
  --kickstart /path/to/kick13.rom --output /tmp/playing-a-sample
```

Add `--build198x /path/to/build198x` if it is not on the path, and
`--vasm /path/to/vasmm68k_mot` to require byte-identical executables from vasm. The check
assembles and masters the demo and `verification/probe.asm`, cold-boots each
on the A500 PAL profile and reads the emulator's chipset write log and audio
capture. It asserts:

- the takeover writes, then each tone's AUD0LCH/LCL, LEN, PER, VOL and
  DMACON writes in order, with about 50 frames between start and stop;
- each tone's measured frequency within 0.1% of the formula above;
- that a polling loop in chip RAM runs the same number of times with all four
  channels fetching at period 124 as with no DMA, while a six-bitplane control
  slows it;
- that channel 0's first interrupt request arrives within two scan lines of
  the DMACON write, the second about seven words of playback later (as the
  last word starts), then one per pass of eight words, within one scan line;
- that queuing a one-word silent loop on the first request plays an eight-cycle
  burst exactly once.

Output goes to the supplied directory; Kickstart is not distributed. The
retained [results](verification/evidence/results.json) identify the emulator,
Kickstart, source, binary and capture hashes and the measured values;
[baseline](verification/evidence/baseline.json) identifies the original page.
Regenerate results when the routine changes. Two runs produce identical
results apart from load addresses.

Hardware sources: Commodore-Amiga, *Amiga Hardware Reference Manual*, third
edition, chapter 5 (Audio Hardware: forming and playing a sound, period
limits, joining tones, the equal-tempered table, direct output and the audio
state machine) and chapter 6 (DMA time-slot allocation and 68000 bus
sharing). *Amiga ROM Kernel Reference Manual: Devices*, third edition, Audio
Device: channel allocation. Abacus, *Amiga System Programmer's Guide*,
chapter 1: odd bus cycles reserved for DMA, including audio. Results are emulator observations, not hardware tests. They make no
claim about which stereo jack carries channel 0: primary sources disagree
(emu198x#1514). Listening remains a human check.
