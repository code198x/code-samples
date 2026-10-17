# Bank or risk browser playtest

Open [index.html](index.html) directly in a browser. It is a self-contained,
source-readable file: no server, installation, network connection or account
is required. Click **Start challenge**, then roll or bank. Sound is optional
and starts off. The page records and sends nothing.

This implements the agreed trial rules: one six-sided die, a limit of 10,
at most five rounds, and a target of 30. Exactly 10 banks automatically;
a bust secures zero while preserving earlier points. The challenge ends when
the target is reached or the remaining rounds cannot reach it. Results stay
visible until the player continues. The round history shows each contribution.

R rolls, B banks, Space starts or continues, A replays after an ending, and Q
ends the challenge. Focused buttons also use Enter or Space. Held keyboard
input is ignored until release; each mouse click or tap is a separate choice.
Ending a challenge returns to its starting screen and clears its score.

## What to try

Play several ordinary challenges before analysing a strategy. Consider whether
another roll is tempting, banking feels satisfying, recovery after a bust feels
credible, and the target invites another attempt. Share impressions in the
conversation; there is no telemetry or automatic feedback collection.

The die, board and short bank/bust/success tones are browser presentation for
this trial. They do not establish an AMOS implementation or final artwork.
Sound on plays a brief preview; a session-success cue replaces the final bank
cue. The numbers and labels carry every outcome with sound off.

Use the [game brief](https://github.com/code198x/docs/blob/amiga-course-and-tooling-briefs/platforms/commodore-amiga/games/bank-or-risk/brief.md)
for the design. The native AMOS source remains in [draft samples PR #102](https://github.com/code198x/code-samples/pull/102).
This JavaScript version does not check AMOS syntax, random generation, graphics,
audio, input timing or saving. Human play feedback and a later beginner trial
remain distinct from code verification.

## Verification

Run the built-in Node checks from this directory:

```sh
node --test rules.test.mjs
```

The tests load the exact rules script from the HTML. They check boundary totals,
score preservation, success, early failure, replay, invalid input, the die
supplier and reachable scoring states. Negative controls change the equal-limit
and bust-award rules and confirm that the relevant checks reject those faults.

Browser verification uses the already-installed Playwright and axe packages
from the sibling website repository, plus local Chrome. It adds no dependency.
Set `CODE198X_WEBSITE_ROOT` if that repository is elsewhere. From this directory:

```sh
node verify.mjs /tmp/bank-or-risk-review
```

The browser checks use a separate injected die supplier for prescribed cases;
the shipped page has no test mode or fixed-roll URL. Browser output includes
screenshots, accessibility findings and a check summary. These checks establish
the browser version's behaviour, not enjoyment or original-runtime behaviour.

The retained [browser check summary](verification/results.json), desktop/mobile
captures and empty axe reports record the executed browser checks. Nine Node
tests pass, including 1,575 reachable states and 3,780 roll transitions. Web
Audio checks verify real oscillator creation and once-only cue selection; they
do not establish audible quality. A separate source and screenshot review found
no material usability issues within this small browser trial's scope.
