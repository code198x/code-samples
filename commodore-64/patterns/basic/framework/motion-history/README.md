# Remember Previous Positions in a Ring in C64 BASIC

A trailing companion needs where the leader was a few updates ago. A short position history gives it something concrete to follow. Keeping that history in a ring avoids moving every older sample each time a new one arrives.

## Include and initialise

Reserve U(8)/V(8) for X/Y samples; H/C/X/Y/L/M/A/B/O/E and private I. Reserve lines **3000–3340**, combine numbered sources with build.py and prevent fall-through using END, STOP or a jump. C64/BBC use GOSUB and Spectrum GO SUB. The private I must not be an enclosing caller FOR variable.

Call **3000** at a new-history boundary. It clears every scalar and all sixteen coordinate elements. H is the next zero-based write slot, from zero to seven; C is the retained sample count, from zero to eight. The buffer starts empty, even though its numeric elements contain zero.

## Append and query

Set M=1 to append X/Y, or M=0 for a read-only query. L is the requested age: zero means newest, one means one sample older. Call **3100**. A/B return the selected coordinates and O=1 when the age is available. An unavailable age returns A=0,B=0,O=0,E=0. Zero coordinates can be a valid sample, so check O.

Appending writes at H, advances H with wrap at eight and grows C until full. It then answers the query against the updated history. **A valid append remains committed even if L is unavailable.** Query failure is not rollback. M=0 leaves the ring and cursors unchanged and ignores the supplied X/Y.

H/C and all stored coordinate values must be valid integral values: H=0..7, C=0..8, coordinates 0..255. E=1 rejects damaged retained state before writing. E=2 rejects a bad M, non-byte L or invalid appended coordinates. Invalid calls leave H/C/U/V unchanged and return zero outputs. Every valid unavailable query has E=0.

## The reusable routine

See `routines.bas`.

Physical array order stops being chronological after wrap. H points to the next write, so the newest sample is one slot before it. Subtracting L and wrapping once identifies the requested retained position. The helper does not treat U(1) as permanently oldest or newest.

## Follow samples through wrap

The working caller appends twelve positions and reads age two. At its final append the expected result is position 10,20. The custom caller appends nine and reads age seven, reaching the oldest retained position after wrap. Both then try an unavailable read-only age and query the newest sample again.

See the retained-state section in `demo.bas`; the file also contains its boundary table and observation writer.

The earlier table also covers partial/empty buffers, full wrap, unavailable age after a valid append, zero/maximum coordinates and invalid state/request. Line **2000**, the mailbox, AA/BB and JJ/KK (Z/Q on Spectrum) only serve the diagnostic. A game's history does not need them.

## Customise the history

Choose L for a longer or shorter trail, while keeping it below the available C when a result is required. Decide what to do during warm-up: stay still, use the oldest available sample or wait until enough history exists. Those are caller policies; this version reports unavailable honestly.

A lag is measured in **serviced samples**, not seconds. Appending on every movement update differs from appending only when the leader changes position. Variable spacing makes the elapsed time represented by age two vary. Timestamped samples and interpolation need additional state; this pair buffer is not a full-game rewind or a collision-safe follower controller.

Eight pairs are always allocated. A larger history requires changing DIM, cursor bounds, wrap arithmetic and tests together. Independent trails need separate arrays, globals, private scratch and numbered references.

## Mistake and repair

The wrong caller resets H before every append. It repeatedly overwrites one physical slot while C claims that more history exists. Older queries read unrelated zero samples, and both saved coordinate checks print zero. The retained cursor belongs with the retained data.

The repair preserves H across appends. Repaired source and loaded tokenised program match the working caller exactly.

See `verification/wrong.png`.

## Cost and further steps

Writing/querying a slot does not shift older samples. This defensive version also validates all eight stored pairs on every call, so validation work remains even for a read-only query. Sixteen BASIC numeric elements cost more than sixteen machine-code bytes. A trusted internal buffer could use a different validation boundary, but needs a different caller guarantee and evidence.

[Maths for Games](/craft/maths-for-games/) connects circular indices, chronological order and sample age. [The Craft](/craft/) helps decide how a trail should look and respond; copying old positions alone does not give a companion believable movement.

## Machine and measured size

C64 BASIC V2 recognises only the first two significant characters of numeric variable names. Short names make the ownership visible; check for collisions before including another component. Array element zero exists but is unused here. The diagnostic uses a mailbox at $C000, outside the normal BASIC heap.

The numbered helper occupies **637 tokenised program bytes** on this interpreter, including line headers. This excludes the caller, test tables, numeric scalar/array storage, interpreter stacks and ROM. Tokenised size is not machine-code size or a hardware-cycle count. No real-time or whole-game performance budget is inferred from the diagnostic. The caller’s AA/BB, JJ/KK and RAM mailbox are observation machinery, not required game state.

## Execution evidence

Working, custom, deliberately wrong and exact repaired callers executed through C64's stock BASIC interpreter under Emu198x 0.44.2. Build198x 0.2.9 tokenises C64 PRG and Spectrum TAP programs. C64 enters stock RUN, Spectrum uses ROM tape loading, and BBC enters every numbered source line through MOS/BASIC. Actual loaded program bytes, complete state packets, positive completion/count/guards and visible result pixels are checked. After the positive completion marker, the observer advances two complete display frames before capturing, so a partially scanned final character cannot masquerade as a finished picture. Firmware is not distributed.

An independent mathematical/order model checks the trace and rejects altered source, configuration, loaded program, state, completion and image evidence. Host exhaustive checks complement the native boundary/sequential examples; those host ranges are not claimed as natively exhaustive. The supplied diagnostic callers deliberately end with STOP; the interpreter report is expected. The wrong caller prints 0,0 and the normal/custom/repaired callers print 1,1.

Public CI checks retained evidence; it does not execute restricted firmware. Refresh with `python3 scripts/verify-basic-entities.py motion-history commodore-64 --tools /path/to/extracted/releases` and inspect with `python3 scripts/check-basic-entities.py motion-history`.
