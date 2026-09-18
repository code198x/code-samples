# Yearfall prototype

A native-play trial in stock 48K PAL Sinclair BASIC. Manage one settlement for
as long as you choose to continue: trade land, feed people and plant a harvest. The plan displays the
combined cost, food requirement, fed-worker capacity and possible harvest range.

S starts. B buys land; S sells land. Both ask for a positive number of acres,
and zero clears the land plan. Choosing one replaces the other planned land
action. F/P edit feeding and planting. Enter accepts, Delete erases, X cancels.
The plan states how much grain you spend or receive. Space harvests a
valid plan or continues a report. R restarts and Q quits outside the editor.
Blank entry keeps the existing amount. Held keys count once. The game is silent
and has no time limit.

Each person needs three grain; each fed person can farm two acres. Seed costs
one grain per acre; harvest gives two to five. Land prices vary from six to ten.
Travellers visit before planning, first in year 3–5 and then at intervals of
3–5 years. Three to six people offer to join for six grain each. The screen
shows the welcome cost, remaining grain and total food requirement. Y accepts;
N declines at no cost. Acceptance requires enough for the welcome and that
year’s food. They join immediately and can work if fed; the welcome does not
pay their annual food. The harvest ledger includes the welcome expenditure.
When everyone is fed, five per cent of the opening population (rounded down)
arrive after harvest. Extra food does not increase this number. Every year's
report accounts for the grain and shows deaths, newcomers and changed land.
Every ten years, a summary describes resources and cumulative deaths. C
continues ruling the same settlement; R starts again. An empty settlement
cannot continue. R starts a new settlement with a fresh market price; it
does not promise the same random sequence.

## Reproduce

Configure a lawful 48K ROM and set `EMU198X_SPECTRUM` to the built executable.
From this directory:

```sh
python3 verification/model.py
python3 verification/build.py --emulator "$EMU198X_SPECTRUM" --output verification/evidence
python3 verification/check.py --emulator "$EMU198X_SPECTRUM" --output verification/evidence
python3 verification/audit.py
"$EMU198X_SPECTRUM" --machine spectrum_48k --tape verification/evidence/yearfall.tap --autoload-tape --scale 3
```

The build uses actual ROM keyword keys and records `SAVE "yearfall" LINE 10`.
The checks use a separate fresh process to load that tape. The full-run fixture
uses ordinary ROM `RANDOMIZE 17` and `RUN 200` for a reproducible sequence;
the other checks exercise the normal title and random start. Game actions are
ordinary keys, and memory observations are read-only. An incomplete variable
snapshot during a ROM string update is retried for at most eight frames.
The host model separately checks accounting, retains the three-policy ten-year
comparison without events, and compares welcoming/declining across 1,000 Python
seeds each for thirty years. These are neither Spectrum random sequences nor
player success rates, optimal-strategy results or a guarantee of rescuable runs.
Native acceptance, original-hardware timing and independent learner trials
remain unestablished.

The extended native regression covers thirty years. The existing four-digit
allocation editor remains a practical limit for very long runs; indefinite
play at arbitrarily large populations has not been established.
