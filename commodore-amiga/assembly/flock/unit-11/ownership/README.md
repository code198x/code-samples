# Who keeps channel 0?

An optional unit-11 experiment, starting from the existing `flock.asm`. The
normal game is unchanged. The companion freezes gameplay and replaces input,
traffic and collision updates with three controlled pairs of sound requests.
Do not use this fixture as the next game checkpoint.

## Build and run

We need Python 3, Asm198x and Build198x. From this folder:

```sh
python3 prepare.py /tmp/flock-ownership
asm198x --dialect vasm --exe /tmp/flock-ownership/latest.asm -o /tmp/flock-ownership/latest
asm198x --dialect vasm --exe /tmp/flock-ownership/priority.asm -o /tmp/flock-ownership/priority
build198x adf /tmp/flock-ownership/latest -o /tmp/flock-ownership/latest.adf
build198x adf /tmp/flock-ownership/priority -o /tmp/flock-ownership/priority.adf
```

Use a suitable temporary output directory on our own system. Cold-boot each ADF
on an A500 PAL configuration with Kickstart 1.3. Restart the emulator to repeat
the trial. This retains the original takeover program's halt behaviour; it does
not add an operating-system exit. No firmware is distributed.

`prepare.py` checks the original source hash and makes two full sources we can
inspect. They differ only in `USE_PRIORITY`: 0 accepts every request, 1 enables
the guard in [requestsound.asm](requestsound.asm). Both still use the original
`playsound` hardware setup. The only `soundtick` addition clears `sndpriority`
when its timer expires. No game call site, WASM integration or shared build tool
is edited. See [experiment.asm](experiment.asm) for the request schedule.

## Predict, then compare

The trial starts when the farm appears. Each pair happens within one update,
with 60 updates between pairs. At nominal 50 updates/second that is 1.2 seconds.
We call `soundtick` before the requests here so the recorded timer is the full
requested duration. The ordinary game calls it after gameplay and can immediately
subtract one; keep that distinction in the whole-hop trace.

The bottom-right four digits now mean **AA RR**: accepted and rejected requests
in this pair, each as two digits. They are diagnostics, not game points. Counts
reset for each pair. The first sound may be replaced before we hear it: two
accepted requests do not mean two complete sounds played.

| Pair | Request order | Latest wins: predict cue/counts | Priority: predict cue/counts |
|---|---|---|---|
| 1 | Hop (1), pen (2) | Record before booting | Record before booting |
| 2 | Pen (2), hop (1) | Record before booting | Record before booting |
| 3 | Pen (2), pen (2) | Record before booting | Record before booting |

After all three pairs, the last counts remain visible and the sound ends. We
can compare the preserved guest records without needing musical judgement.

<details>
<summary>Hint</summary>

An idle channel accepts. A busy channel accepts only a strictly higher priority.
The comparison is unsigned; equal priorities keep the existing cue. Follow each
request before advancing the clock. Rejection must not reset the timer.

</details>

<details>
<summary>Expected observations and trade-off</summary>

Latest-wins displays 0200 for every pair: pen, hop, pen remain respectively.
Priority displays 0200, 0101, 0101: the pen remains in all three pairs.
In pair 2, the late incidental hop no longer replaces the arrival message.
In pair 3, the second equal-priority request is rejected; nothing is queued or
saved for later. That loss is deliberate, not a missing simulation event.

The two pen requests occur in the same update, so this tie trial diagnoses the
policy through its counts and state. It is not a useful audible retrigger test.
A later spaced-request experiment can make that distinction audible.

</details>

## Small ownership contract

`d4.w` is priority 1 (hop) or 2 (pen). Existing d0–d3 parameters still specify
starting period, later period, positive duration and volume. The wrapper has
the original routine's clobbers: a0, d2 and condition codes. It returns normally;
accepted/rejected counters provide diagnostics. All state access is sequential
in the main loop. This is not an interrupt-safe request mailbox.

`sndtimer=0` means idle. While busy, compare with `sndpriority`; reject equal or
lower requests before writing any playback state or hardware. Acceptance stores
the new priority and enters the unchanged player. Expiry clears the priority
alongside the existing DMA/volume stop. Rejected requests disappear; they do not
resume when the owner ends. The four-channel hardware could support a different
arrangement, but extra channels still need ownership and independent state.

A different game might retrigger equal-priority cues or reserve a channel. We
should choose based on the information the player needs, not make every cue
"most important". Arrival still has its visible game feedback in the ordinary
game; this isolated fixture does not simulate an arrival or award points.

## Author verification

```sh
python3 verify.py --emulator /path/to/emu198x-amiga --kickstart /path/to/kick13.rom --build /tmp/flock-ownership
```

The verifier cold-boots both disks, then reads guest-written records from Chip
RAM. It finds the completed marker after AmigaDOS relocation, checks all three
pairs and ownership release, and captures each final display. It never writes
machine memory. The records contain timer, priority, accepted count, rejected
count and later period. Source/executable/disk/emulator/firmware hashes accompany
results. This does not prove original-hardware behaviour or audible quality.

The spaced-request companion below develops release, retriggering and restoration, with a listening comparison in unit 11 and a link to unit 17. No general mixer is introduced.

Recorded on 22 September 2026: [both variants pass](results.json) in native
Emu198x Amiga 0.25.0, A500 PAL with Kickstart 1.3. Built using Asm198x 0.0.58
and Build198x 0.2.6. Final display inspection shows priority's 0101 diagnostic.
The frozen scene is not a gameplay or sprite-rendering regression test. No
subjective listening or original-hardware result is claimed.

## Spaced requests: C06b

Run `prepare.py --spaced /tmp/flock-spaced`, then use the same assembly and ADF
commands above with `/tmp/flock-spaced` as the directory. Verify with the same
command plus `--spaced`. This records native audio during each cold boot as well
as checking eleven guest records per policy. `spaced.asm` is the complete fixed
schedule; `requestsound.asm` and the normal player are unchanged.

| Updates | Work | Essential evidence |
|---|---|---|
| 1, 7, 13 | Pen followed by two hops | Priority timer falls 18→12→6; counts end 1 accepted/2 rejected. Latest accepts all three and changes to the hop. |
| 31 | Hop on idle channel | Both accept priority 1 again. No permanent high-priority lock. |
| 61, 67, 73 | Repeated pen requests | Latest resets to 18 each time; priority falls 18→12→6. |
| 91 | Hop on the last possible expiry boundary | Tick precedes request; latest's pen from 73 has expired, so both accept. |
| 97 | Observe without a request | Timer and owner are zero. |
| 121, 139 | Original pen and expiry | Original 18-update/two-period settings work again, then release. No interrupted cue resumes automatically. |

Counts reset at the start of each group (1, 31, 61, 91, 121). The sound state is
not artificially cleared between groups: normal countdown expiry frees it.
"Retrigger" here means resetting this player's timer and pitch settings, not
promising a restart at a particular sample phase. The wrapper does not redesign
Paula's DMA setup. Final restoration means requesting the original cue again;
to resume the course we use unchanged `../flock.asm`, not either frozen fixture.

[Recorded spaced results](spaced-results.json) pass on 22 September 2026 in
Emu198x Amiga 0.25.0, A500 PAL/Kickstart 1.3, built with Asm198x 0.0.58 and
Build198x 0.2.6. Original C06a generated source hashes still match its accepted
results after adding the optional mode. The ordinary unit-11 source also matches
`prepare.py`'s original hash. No original-hardware or whole-game regression test
is implied.

### Reproduce the listening clips

After `verify.py --spaced` completes:

```sh
python3 extract_audio.py /tmp/flock-spaced /tmp/flock-audio
```

This keeps four seconds from each native recording, starting 0.2 seconds before
the first sample whose magnitude exceeds 300. It preserves sample rate, channels,
relative timing and gain: no normalisation, invented waveform or rearrangement.
The lesson stores the two resulting WAVs under its existing audio directory.
[Excerpt provenance](audio-excerpts.json) records exact sample bounds and hashes;
`input_sha256` identifies the uncompressed PCM payload, not the WAV header.

Both clips contain non-zero audio without 16-bit clipping and finish with silence.
They provide a learner listening comparison; automated state/audio checks do not
establish subjective clarity or original-machine audio fidelity. The excerpts
are not precise frame-timing benchmarks. Discuss what information is easier to
hear, then use the records to explain the cause. The lesson supplies equivalent
state/count evidence without requiring hearing or musical composition skills.

Unit 17 is a later application, not a claimed mixer implementation: its title
path calls `tunetick`, while `startgame` stops audio DMA and clears `sndtimer`.
If a future version permits music and gameplay requests together, it must decide
ownership explicitly. Do not simply assign every musical note the highest priority.

The website build completed with 2,468 pages; both new audio controls entered
playback in the rendered local lesson. This checks delivery, not subjective clarity.
