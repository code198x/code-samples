# Blitz object pool: reuse a released slot

Fill eight slots and the next acquisition reports full. Release slot 0, then acquire again: slot 0 succeeds. The wrong owner omits release and remains full at slot 8 with success 0. The independently imported repair restores reuse. Stored payload remains 60 and the extra occupancy guard remains 99.

## Build, include and own

Run `make`, then insert `build/working.asc` into a blank original Blitz BASIC 2.10 / Ted 1.1 project. Amiga-X compiles and runs it; Q closes its result window. Import complete variants into separate blank projects to avoid duplicate labels. ASCII imports are source files, not compiled executables or native editor saves.

The builder joins settings, caller and helper routines. Keep dot-prefixed helper labels after the owner's `End`; use `Gosub PL_OP_INIT`, `Gosub PL_OP_ACQUIRE` and `Gosub PL_OP_RELEASE` without the label's dot. Reserve the six `PL_OP_` long fields and the occupancy array for one owner and one context. It is not reentrant.

The caller allocates `Dim PL_OP_LIVE.l(8)`: nine four-byte long elements. Slots 0..7 support capacity eight; element 8 is an external diagnostic guard. The owner must allocate and retain that storage. The helper cannot discover a missing or undersized array. Payload and optional lifetime arrays belong to the owner, indexed by the acquired slot.

| Long field | Contract |
| --- | --- |
| `PL_OP_CAP` | Init input: integer capacity 1..8 |
| `PL_OP_SIZE` | Private configured extent; zero disables |
| `PL_OP_SLOT` | Acquisition output or release input |
| `PL_OP_OK` | One on success, zero otherwise |
| `PL_OP_ERROR` | Zero valid/full, one invalid context/init, two invalid or already-free release |
| `PL_OP_I` | Private bounded scan index |

Occupancy is zero for free and nonzero for occupied; the helper writes zero or one. Init clears only configured occupancy and leaves payload/lifetimes alone. Invalid init disables the context without writing any array element, including after an earlier valid configuration. Changing capacity has no effect until another init. Do not edit private size or scan state.

Acquire returns the lowest free index and marks it occupied. Check `PL_OP_OK` before subscripting: full returns slot equal to size, success zero and error zero. The search completes its `For`/`Next` before returning. Release validates context and both index bounds before subscripting; it rejects an already-free slot and never clears payload.

An active object keeps its index until release. Once reused, an old saved index can refer to a new object. Generation counters and stale-handle detection are outside this component. There is no clock, input, drawing, spawning or lifetime policy inside the helper.

## Lifetime is an owner decision

`age.bb2` starts four objects with lifetimes 1,2,1,3. Each pass visits occupied slots, reduces lifetime and releases expired objects. Only after the first complete traversal does it acquire a new object in slot 0 with lifetime 2. Spawning during traversal would let index order decide whether the new object ages immediately.

The independent model expects live counts 3,2,0 and expiry counts 2,1,2. Every occupancy, lifetime and payload element remains observable, including unused elements and guards. One pass means the game's chosen unit, not automatically one second.

## Customise and repair

`custom` configures four slots and `single` configures one, with the same helpers. Keep the allocation and full-result checks. Changing payload or lifetime rules needs no occupancy-helper change.

The wrong small owner omits `Gosub PL_OP_RELEASE` before reacquiring. It compiles and completes but cannot reuse the slot. Restore that call, with `PL_OP_SLOT=0`, before `Gosub PL_OP_ACQUIRE`. `small`, `working` and `repaired` have identical generated source. The separate wrong diagnostic omits the first release at every mask; the second release exposes the resulting occupancy and return-value differences. A compiler error or missing completion would not establish this fault.

## Resources and original-runtime limits

Six scalar longs hold 24 bytes of numeric payload. The nine-element occupancy array holds 36 bytes; optional nine-element payload and lifetime arrays add 36 bytes each. Compiled instructions, descriptors, runtime bookkeeping, call-stack use, editor, screen and window storage are additional and have not been isolated. These counts are not total heap, executable size, minimum memory or peak stack measurements. ASCII source length is not compiled instruction size.

The small owner opens a 420×180 Workbench window and reserves no bank. Normal Q exit restores default input/output and closes that window. It does not promise cleanup after arbitrary interruption. Diagnostic owners separately reserve bank 0 and free it on normal exit; coordinate that resource with other code.

The full mask observer stores 768 records of 496 bytes plus two final long guards: 380,936 bytes, confirmed by native bank-size pixels in the first complete working run. Each record contains three input longs, then five snapshots of all six context longs, all nine occupancy longs and all nine payload longs, followed by a row marker. Compact native loops generate masks; no large generated DATA table consumes the original compiler's object buffer.

Separate boundary and signed-minimum banks request 5,344 and 704 bytes for 46 and six 116-byte records. Each includes inputs, all context fields, every occupancy/payload element and guards. The lifetime bank requests 464 bytes for three 152-byte records, including all context and owner arrays. These are diagnostic allocations, not helper requirements; bank headers are additional. No timing or throughput budget follows from completion.

## Verification

The maintained native runner is `scripts/verify-blitz-object-pool.py`. It uses lawful matching local runtime/firmware media and released tools, fresh source-bound fixture media and original Ted compile/run operations. It reads the guest-selected bank address from screen digits, compares every byte against independent models, checks actual count/exit/allocation/font pixels, and records result and normal-exit captures. No fixed bank address or injected instruction pointer executes the helper. Private firmware-bearing snapshots and licensed disks are not distributed.

The models cover every byte occupancy mask at capacities one, four and eight, including init, acquisition, release, repeated release and invalid release. Boundary runs cover disabled/negative/oversized contexts and capacities, invalid init followed by another operation, and invalid indices. Signed minimum is constructed in the guest by subtracting one from -2147483647. Full long observations expose upper-bit corruption; unused flags, payload 65537 and guard 99 expose writes outside helper ownership. Completed helper scans leave the private scan index equal to capacity on the observed original compiler.

`scripts/check-blitz-object-pool.py` requires all twelve imports: six usable owners, full working/wrong/repaired observations, boundaries, signed minimum and lifetime. It checks exact source/program/fixture/configuration/capture identities, full packets and actual native pixels. `scripts/test_blitz_object_pool.py` deliberately damages records, upper bits, context, owner arrays, guards, identities, coverage and pixels. Recomputing the hash of a false packet cannot make it pass. CI validates retained proof without booting the licensed runtime. Changes to qualified runtime inputs require fresh original-runtime verification.

Qualification is specific to Blitz BASIC 2.10 / Ted 1.1 compiled through Emu198x 0.44.1 on a PAL A1200 with 2 MiB chip RAM and no fast RAM. It does not qualify another compiler/runtime, original hardware, NTSC or a smaller machine.

For Maths for Games, occupancy is a finite set: acquire selects the smallest missing member and release removes one member. For Craft, keep storage reuse separate from the game's object lifetime and update order.

## Published native captures

The working and wrong captures also have 768×576 publication exports, `verification/published-working.png` and `published-wrong.png`. Every omitted framebuffer column has an identical retained partner across the complete decoded image. Original 1536×576 captures remain retained; no unique pixels are removed or invented. `published-images.json` binds original and published identities, and the image checks challenge altered geometry, unique pixels and hashes.
