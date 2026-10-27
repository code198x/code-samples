# AMOS object pool: reuse a released slot

Fill the working pool and the next acquisition reports full. Release slot 0, then acquire again: the result is slot 0 with success 1. The deliberate wrong caller omits release, so it remains full at slot 8 with success 0. The repair restores the original two calls. Existing payload stays 60 and the extra guard stays 99.

## Build and run

Run `make` here. Import `build/working.asc` into a blank AMOS Professional 2.00 project with Merge ASCII; check with F 2 and run with F 1 after the original checker finishes. Press `q` to leave the result screen. Import complete variants into separate blank projects so old labels do not remain.

These are ASCII sources for import, not native tokenised `.AMOS` saves. The builder joins settings, the small caller and helper routines after `End`. `small`, `working` and `repaired` have identical source. `custom` sets capacity 4; `single` sets capacity 1. `wrong` removes release. The larger `cases`, `wrong-cases`, `repaired-cases`, `boundaries`, `age` and `extremes` builds are diagnostics, separate from the small caller.

## Include the helper

Include `routines.amos` after the owner's `End` and reserve its `PL_OP_` names. Allocate the occupancy array before calling the helper. The maintained caller uses `Dim PL_OP_LIVE(8)`: AMOS includes the upper bound, so this allocates nine elements. Slots 0..7 support capacity 8; element 8 is an external diagnostic guard. Payload and lifetime arrays belong to the caller and use corresponding slot indices.

This is one pool with one owner, ordinary signed integer variables, and normal `Gosub`/`Return` calls. It is not reentrant. The owner must allocate the stated array and keep it alive. The helper cannot discover an undersized or missing array. Its accepted capacity range does not prove that arbitrary caller storage was allocated correctly.

| Field | Contract |
| --- | --- |
| `PL_OP_CAP` | Init input: whole capacity 1..8 |
| `PL_OP_SIZE` | Private configured extent;0 means disabled |
| `PL_OP_SLOT` | Acquire output or Release input |
| `PL_OP_OK` |1 on success;0 otherwise |
| `PL_OP_ERROR` |0 valid operation/full;1 invalid context/init;2 invalid or already-free release |
| `PL_OP_I` | Private bounded scan index |
| `PL_OP_LIVE()` | Occupancy only:0 free, nonzero occupied; helper writes 0 or 1 |

Set `PL_OP_CAP`, then `Gosub PL_OP_INIT`. Valid init clears only the configured occupancy slots, sets size and returns success. Payload and lifetime storage are untouched. Invalid init sets size 0 and returns error 1 without writing any occupancy element, even when an earlier configuration was valid. Changing capacity later has no effect until another init; do not edit private size or scan state.

Call `Gosub PL_OP_ACQUIRE`. Success returns the lowest free index, marks it occupied and sets OK 1. Full returns slot equal to size, OK 0, error 0. Check OK before using the returned slot as an array index. The scan completes its bounded `For` loop before returning, so acquisition does not abandon an interpreter loop frame.

To release, set `PL_OP_SLOT` and `Gosub PL_OP_RELEASE`. The helper checks context and both index bounds before subscripting. Releasing a free slot is rejected. Payload is never cleared. An occupied slot keeps its index until release; after reuse, an old saved index can refer to a different object. Generation counters and stale-handle detection are outside this component.

## Keep lifetime policy in the caller

`age.amos` allocates four objects with lifetimes 1,2,1,3. Each pass visits only occupied slots, decrements their lifetimes and releases expired slots. Only after the complete first traversal does the owner acquire another object; it reuses slot 0 with lifetime 2. Spawning during traversal would let traversal order decide whether the new object ages immediately.

The observed live counts after the three passes are 3,2,0; expiry counts are 2,1,2. Full occupancy, lifetime and payload arrays remain observable, including unused elements and guards. The helper has no clock, lifetime, spawn, drawing, input or hardware policy. Use your game's chosen unit for a lifetime; one pass does not automatically mean one second.

## Customise and diagnose

Capacity 4 and capacity 1 use the same routines and a smaller configured extent. Keep the allocation contract and the full-result check. Changing payload or lifetime policy does not require changing the occupancy helper.

All six usable caller imports have run in original AMOS: default 8, custom 4 and single 1 fill to exhaustion and reuse the lowest released slot. The wrong caller stays full because it omits release; the independently imported repair restores reuse. A syntax error, requester or missing completion is not the intended fault.

The mask diagnostics cover every byte occupancy mask at capacities 1,4,8:768 records per variant. Full 32-bit snapshots follow init, acquisition, release, repeated release and invalid release; payload and the extra guard are checked too. Separate boundary records cover invalid capacities, invalid contexts, invalid init followed by acquire/release and negative or oversized indices. The signed-minimum diagnostic constructs -2147483648 with a guest decrement from -2147483647 before supplying it as capacity, context extent or index. All six native signed-minimum records complete with preserved flags, payload and guard values.

## Costs and limits

The six helper scalar integers hold 24 bytes of numeric payload. The caller's nine-element occupancy allocation holds 36 bytes of integer payload; its optional payload and lifetime arrays each add 36 more. Names, labels, array descriptors, interpreter tables and GOSUB return frames add overhead. These counts are not total heap, executable-size, minimum-memory or peak-stack claims. Maintained ASCII file lengths are source lengths, not tokenised or compiled instruction sizes.

Native `Length(1)` pixels confirm separate diagnostic banks of 190,468 bytes for each mask run,4,972 bytes for the boundary run and 388 bytes for the lifetime run. These banks belong to diagnostics; the small caller does not reserve one. The six signed-minimum records request 652 bytes, also confirmed by native allocation pixels. Bank headers, the resident AMOS/editor/runtime and screen storage are additional. No frame-time, throughput or bus-bandwidth claim follows from completion.

Qualification uses original AMOS Professional 2.00 interpreted on a PAL A1200 with 2 MiB chip RAM and no fast RAM through released Emu 198 x 0.44.1. It does not qualify another interpreter/compiler, NTSC, original hardware or a minimum-memory Amiga.

## Verify retained evidence

The topic-local Python models compute independent expectations; they do not substitute host execution for original-runtime proof. Native observers write their own complete banks and completion markers. The verifier reads the guest-selected bank address from actual screen digits and checks every record byte, native count/status/allocation pixels, imported program identity and source/runtime/capture hashes. No fixed memory address or injected program-counter jump runs the helper.

Use the matching `scripts/verify-amos-object-pool*.py` tools with lawful local firmware/runtime media, recorded released tools and a fresh private source-bound fixture. Private snapshots and licensed disks are not distributed. The retained checker and corruption tests validate records in CI; they do not boot AMOS there. The retained records cover the complete maintained inputs. Re-run the original-runtime verifiers when changing the helper, owner or diagnostic inputs.

For Maths for Games, occupancy is a finite set: acquisition chooses the smallest missing member and release removes one member. For Craft, separate storage reuse from the owner's object lifetime and update order. The pool answers which slot is available; the game decides what belongs in it.

## Published native captures

`verification/published-working.png` and `published-wrong.png` export the retained caller captures at the existing Amiga publication aspect. Every adjacent source framebuffer column pair is checked for equality before one duplicate is removed. The resulting 768x576pixels preserve every unique source pixel. The original 1536x576captures and their native identities remain retained. `published-images.json` binds both files; the source evidence job checks complete decoded pixels and deliberately altered identities.
