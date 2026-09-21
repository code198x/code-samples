# Movement and response playground

Local Game Feel prototype: three ships receive identical input with a common
maximum speed. Responsive changes velocity immediately; slippery accelerates at
600 units/s² and brakes at 70; heavy accelerates at 140 and brakes at 200.
Release targets zero velocity. Reversal targets the opposite maximum velocity
using acceleration. This is a chosen control law, not realistic vehicle physics.

Positions start at 140 in a 900-unit track. Walls clamp the centre to 20–880 and
zero velocity; the marker spans 520–600. Simulation runs at fixed 1/60-second
steps, with each display frame contributing at most 0.1 seconds to avoid large
catch-up jumps after stalls. Tab hiding or loss of window focus clears input and
stops the scripted comparison. No native machine timing is implied.

The comparison holds right for 1.2 s, releases for 1.2 s, holds left for 1.2 s,
then releases until eight seconds. Keyboard controls are scoped to the focused
tracks or direction buttons. Pointer capture supports held touch controls and
clears input on cancellation. Reset and speed changes restore a common start.
There is no decorative animation or automatic demonstration; motion is the
subject of this user-controlled experiment.

Serve the folder over HTTP and open `index.html`, or build the website, whose
`/experiments/game-feel/` endpoint reads these maintained files. The footer link
targets the website's Game Feel outline.

Run `node --test model.test.mjs` for numerical checks. Browser verification is
maintained at `website/scripts/verification/game-feel.mjs`.

## Focused controls-and-response lessons

`lessons.html?step=1` through `?step=4` provide paired comparisons for the four
local lesson drafts. Invalid step parameters fall back to the first experiment.
Only one setting differs between the reference and adjustable ship:

1. Top speed, with immediate velocity changes in both ships.
2. Acceleration, with identical top speed and immediate release stops.
3. Release braking, with identical held-input acceleration and top speed.
4. Braking against existing motion, with identical acceleration and release rules.

The last experiment reaches zero before accelerating the other way. This is a
stated alternative to the original playground's direct approach towards the
opposite target velocity. The lessons explain the rules with pseudocode and offer
a small download link to the exact imported velocity routine; they do not display
JavaScript listings.

Both ships start at 120; the marker is 560. Reset or a setting change restores the
common start. Input recording, pause and explicit 1/60-second stepping use the
same update function as manual play. The trace names old/new velocity and position.
The model caps catch-up time at 0.1 seconds per rendered frame. Losing window focus
or hiding the document pauses simulation and clears held input. There is no
automatic demonstration or decorative motion.

Run `node --test *.test.mjs` for the ten model checks. Website verification is
`scripts/verification/game-feel-lessons.mjs`; it checks worked values, setting
resets, controls, sequence navigation, source downloads, light/dark
accessibility, narrow/desktop overflow and iframe height synchronisation.
