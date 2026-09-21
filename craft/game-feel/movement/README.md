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
