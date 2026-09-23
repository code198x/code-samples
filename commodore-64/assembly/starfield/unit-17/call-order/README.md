# Who consumed the next random byte?

This optional C07c experiment reuses C07b's **correct** fixed-seed position
fixture. Both versions make twelve enemy spawns and one cosmetic random draw.
We move only the cosmetic draw: before the first spawn, or immediately after it.
The normal Starfield source and random generator are unchanged. The border draw
is added for this experiment; the normal game's starfield is not claimed to use
this random source.

## Build and run

From this folder, with Python 3.9 or later and Asm198x:

```sh
python3 prepare.py /tmp/starfield-order
asm198x --dialect acme --prg /tmp/starfield-order/before.asm -o /tmp/starfield-order/before.prg
asm198x --dialect acme --prg /tmp/starfield-order/after.asm -o /tmp/starfield-order/after.prg
python3 verify.py --emulator /path/to/emu198x-c64 --build /tmp/starfield-order
```

Use a suitable temporary directory. Load a PRG on a PAL C64 and enter RUN. The
screen shows the first three spawn records in hex. Inspect the full draw log in
memory or the verification results; border colour is optional feedback, not the
only evidence. Each variant is also verified from a second cold launch.

`prepare.py` invokes the neighbouring position generator in a temporary folder,
then uses its baseline only. It inherits the hash-checked step-04 source, seed 1,
initial `$d010=$ab`, enemy slot 0, Y=80 and twelve spawn calls. No C07b fault is
included. The identical RUN press/release schedule supplies no gameplay input.
There are no movement or collision updates between calls.

[cosmetic.asm](cosmetic.asm) consumes one byte from `advance_rng`, stores it, and
uses its low four bits for a decorative border. `log_draw` stores consumer ID
and the byte consumed without advancing the generator. It clobbers A and Y;
the harness calls it at explicit boundaries before loading the registers needed
by the next operation. This is test instrumentation, not a general tracing API.

## Prediction and evidence

From seed 1, the first draws are 2,4,8,16. Before running, assign those bytes to
consumers for each ordering, then calculate the first two spawn positions using
`24 + b + floor(b/8)`. Predict whether every later spawn must differ.

| Draw | Before-first-spawn version | After-first-spawn version |
|---|---|---|
| 1: byte 2 | Cosmetic | Spawn 1: X=26 |
| 2: byte 4 | Spawn 1: X=28 | Cosmetic |
| 3: byte 8 | Spawn 2: X=33 | Spawn 2: X=33 |
| 4: byte 16 | Spawn 3: X=42 | Spawn 3: X=42 |

The raw sequence is identical. Its first two consumers differ; all later
consumers agree. By spawn 2, both versions have already consumed two bytes.
This agreement is specific to the controlled fixture. In a real game the first
changed position may alter a collision, score or subsequent call schedule; later
matching random bytes would not undo those effects.

The original five-byte spawn records remain at `$3803` (twelve records). Additional
state follows: `$383f` is the log length (26), `$3840` is the cosmetic byte, and
`$3841` begins thirteen `(consumer, byte)` pairs. Consumer 0 means cosmetic;
consumer 1 means enemy position. The final seed is 135 in both versions. The
same correct high-bit routine handles X=285 then X=254 in both traces.

[Native results](results.json) include before/after and two repeat runs, with
exact source/PRG/emulator hashes. An independent integer oracle checks all thirteen
draws and twelve coordinate/register records per run, including high-bit set/clear
and preservation of unrelated sprite bits. The first spawn differs; the other
eleven agree. Logs reproduce on both second launches. This is native PAL routine
execution, not gameplay replay, timing equivalence or original-hardware evidence.

## Choose a response to the changed behaviour

Moving the cosmetic call back restores the previous assignment of random bytes.
Accepting the changed first spawn may be appropriate if it is an intended game
change, but the new trace then becomes the baseline. If decoration must never
alter gameplay choices, a separate random state for cosmetics is a possible later
design, with its own seed, storage and initialisation contract. We do not implement
that architecture here.

Explain why changing only the seed is a poor repair for an unexpected consumer
order change. Then name what a useful bug report needs besides the seed: the
build, initial state, inputs and when/how many random calls each consumer makes.
Keep the ordinary step-04 game as the checkpoint to return to. No replay engine,
new generator or broader randomisation change is included.
