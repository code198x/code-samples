# Reuse a fixed set of object slots in Ace FORTH

The caller fills eight slots, refuses a ninth object, releases slot 0 and
acquires slot 0 again. The final display starts with `SLOT 0 OK 1`. The owner
resets the acquired object's payload to 60. A full pool returns `SLOT 8 OK 0`;
8 is a sentinel, so it must never become a payload subscript.

This is a small reusable pool, separate from a particular game's drawing,
collision and lifetime rules. Occupancy belongs to the pool. Position,
energy and other object data belong to the caller.

## Load and call it

Run `make` in this directory to produce `build/demo.fth`. Enter that text
through the original Ace interpreter. The generated file contains, in order:

1. `routines.fth`: the seven context variables and reusable words.
2. `storage.fth`: the caller's occupancy bytes and payload cells.
3. `caller.fth`: initialisation, payload setup and the small display.
4. `settings.fth`: capacity 8.
5. `demo.fth`: initialisation, nine requests, release 0 and one more request.

The files use decimal numbers. Each line fits within the two-line input
editor. They use the original vocabulary; `2 *` multiplies a cell index by
the two-byte cell size. Do not substitute a modern FORTH library or assume
that the exercise word `2*` is already defined.

For a game, load the first four files and replace the demo with your owner:

```forth
PNEW U.
NEWOBJ
```

The first line prints 1 after successful initialisation. `NEWOBJ` leaves a
slot and a success flag. Consume the flag before using the slot:

```forth
: REQUEST NEWOBJ IF U. ELSE DROP ." FULL " THEN ;
```

Here `U.` consumes the successful slot number. Your owner could instead use
that index to initialise more payload arrays. The unsuccessful branch drops
the sentinel. This extra example word consumes dictionary space; it is not
part of the measured small caller.

When the object finishes, pass its occupied slot to `PREL`. For example,
`0 PREL U.` prints 1 if slot 0 was occupied. A second release prints 0. Stop
updating or drawing an object as soon as its owner releases it.

## Word contracts

| Word | Stack effect | Result |
| --- | --- | --- |
| `PINIT` | `( base capacity -- ok )` | Select and clear a valid occupancy buffer. |
| `PGET` | `( -- slot ok )` | Occupy the lowest free slot, or return the extent and 0. |
| `PREL` | `( slot -- ok )` | Release an occupied slot; reject a free or invalid slot. |
| `PNEW` | `( -- ok )` | Initialise this caller's `SLOTS` using `PC`. |
| `NEWOBJ` | `( -- slot ok )` | Acquire a slot and set only its payload cell to 60. |
| `PSHOW` | `( -- )` | Clear the screen and print the last slot and success flag. |

The routines preserve earlier data-stack cells. Flags returned by this
helper are 0 or 1. Both result cells from `PGET` and `NEWOBJ` belong to the
caller and must be consumed. An unused result pair stays on the
data stack and consumes space on each request.

The reserved context is:

| Cell | Meaning |
| --- | --- |
| `PB` | Selected occupancy-buffer address. |
| `PC` | Capacity passed to the last initialisation. `PNEW` reads it. |
| `PS` | Selected private extent, 1 through 8; 0 disables the pool. |
| `PK` | Most recent result or requested release index. |
| `PF` | Most recent operation's success flag. |
| `PX` | Error: 0 for a valid operation, 1 for invalid context, 2 for an invalid release. |
| `PI` | Search position: the found index or the extent after a full scan. |

`PCHK` is an internal validation word. It clears `PF` and checks `PS` and
`PB` before any indexed byte access. Call the three public pool operations
instead of using `PCHK` as an allocation operation.

A full pool is a valid result: `PF=0`, `PX=0`, and `PK=PS`. Invalid context
also returns a failed result, but sets `PX=1`. In that case `PGET` returns
the current `PS` as its sentinel; it is still unsafe to subscript it.
An invalid release sets `PX=2` and leaves occupancy and payload unchanged.

## Storage and ownership

Pass the base of a live caller-owned dictionary buffer with at least the
configured number of bytes. Capacity must be 1 through 8. A zero byte means
free; every nonzero byte means occupied. Successful acquisition writes 1,
and release writes 0. The scan stops at the first free byte.

The helper checks that the selected base is at least 15441, below `HERE`,
and has room for the extent before `HERE`. These checks reject out-of-range
addresses before access. They cannot discover the boundaries of a `CREATE`
object or distinguish data from compiled words. An arbitrary address in
the dictionary, or a smaller allocation followed by other words, is not a
supported buffer. Always pass the actual allocation you own. Do not
`FORGET` it while the pool is selected. The helper does not accept screen,
ROM or arbitrary external RAM buffers.

`PINIT` disables the old selection before checking the new request. On
failure it returns 0, leaves `PS=0`, and writes no occupancy bytes. On
success it clears exactly the configured extent. It does not clear any
payload. Changing `PC` later does not resize `PS`; call `PNEW` deliberately
to select and clear a new capacity. Reinitialisation makes all old slot
references invalid.

The caller allocates eight occupancy bytes plus a guard byte 99, and eight
two-byte payload cells plus a guard cell 65535. Neither guard is a ninth
object. The helper never addresses payload. `NEWOBJ` initialises payload
only after a successful acquisition; `PREL` preserves it. A new occupant
therefore receives fresh payload from its owner.

An index stays attached to its object while that slot is occupied. After
release, the next request can reuse it. There are no generation numbers:
an old reference to slot 0 cannot distinguish the previous object from a
new occupant of slot 0. Keep references within the owner's lifetime rules.
These words share one context and are not re-entrant.

## Smaller pools and the deliberate mistake

`make` also creates `custom.fth` with capacity 4 and `single.fth` with
capacity 1. The same storage can back either smaller extent. Unused bytes
and payload cells remain outside the selected pool; they are not cleared
or initialised by a successful request for another slot.

`wrong.fth` replaces the owner's `0 PREL DROP` with `0 DROP`. The object
finishes in the owner's story, but the occupancy byte stays nonzero. Once
the pool is full, the next request still fails: `SLOT 8 OK 0`. The helper
cannot infer that an object has finished. Restore the release at the point
where the owner ends the object's lifetime. `repaired.fth` is byte-for-byte
identical to the working program and should run from a fresh interpreter.

## Original-ROM resource observations

The small source fits the unexpanded 3 KiB configuration with RAM top 16384.
Original-ROM dictionary growth was 656 bytes for `routines.fth`,53 for
`storage.fth`, and 110 for `caller.fth`: 819 bytes in total. The capacity
assignment adds no definition. These are compiled dictionary bytes,
including word headers, rather than text-file sizes.

Numeric storage within that total is 14 context bytes, 9 occupancy/guard
bytes, and 18 payload/guard bytes: 41 bytes. The remaining dictionary bytes
hold headers and compiled words. The external `NUMBER` observation word
used by verification costs another 19 bytes and puts `HERE` at 16279 after
these files load. The empty data stack starts at `HERE+12` in this ROM.

The space above `HERE` also serves interpreter input and stacks. Observed
CPU/data-stack separation during stopped-at-prompt checks is not a peak
stack measurement or an allocation budget for more words. This proof does
not establish that this pool, the separate game-flow sample and a game
fit together in stock RAM. Measure the final combined program separately.

## Verification

`scripts/verify-ace-object-pool.py` uses keyboard entry in the original ROM,
with the locked emulator/firmware configuration in `docs/ace-map-tools.json`.
Each group boots independently. It records full context, all nine occupancy
bytes, all nine payload cells, data-stack results with a retained 77 prefix,
compiled dictionary bytes, CPU/data-stack observations and native captures.
It never injects source through RAM or changes the entry PC.

The retained checker requires all 274 occupancy masks across capacities 1, 4, 8;
99 invalid-context, pointer and index observations; five owners, including
300 release/reuse cycles in the single-slot owner; exact source/load and
compiled-byte identities; and every active capture pixel against native
screen and character RAM. Occupied mask bytes include 1, 128 and 255. Payload
seeds differ between slots so an out-of-extent write cannot hide behind a
repeated 60. The checker replays the typed pool operation and seed recipe with
the independent occupancy-list model. Deliberately altered evidence must
fail, including code bytes, guards, upper cell bits and an empty case set.

A separate five-boot proof executes every line of all five complete
generated callers, including their nine requests and final printed payload
and guards. Its retained checker binds each complete builder output to the
actual typed program and checks all context, arrays, compiled bytes, stack
and final pixels after the owner runs.

Run the retained checks without firmware:

```sh
python3 scripts/check-ace-object-pool.py
python3 scripts/check-ace-object-pool-callers.py
python3 -m unittest discover -s scripts -p 'test_ace_object_pool*.py'
```

The original *Jupiter Ace User's Manual* (1982) explains the dictionary and
memory layout, `CREATE`, byte and cell access, and the control-flow words
used here. Its `LEAVE` discussion matters: `LEAVE` takes effect at the next
`LOOP`. This search uses `BEGIN`/`WHILE`/`REPEAT`, so its early `EXIT` does
not abandon a `DO` loop. The initial clear uses a positive bounded `DO`
loop which completes before returning.
