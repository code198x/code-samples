# A counted-byte two-word parser for Z80

`make` validates `vocabulary.json`, emits `build/vocabulary.inc`, assembles with
Asm198x's Pasmo dialect and produces `build/demo.tap`. Load it on a 48K Spectrum.
The command inspector has a 63-byte editor, Enter to submit and Delete to edit.
It shows status/verb/noun IDs. A rejected 64th character latches overflow: submitting
reports status 2 rather than executing a truncated command. Delete clears an
overflowed entry; an ordinary Delete removes the last stored character. After
submission the command stays visible until the next key starts a new entry.
Reset to leave. This is a parser/editor caller; the complete adventure is the
BASIC companion, not hidden inside the assembly library.

## Reuse the parser

Include `parser.inc` once in executable RAM and the generated tables once. Give
it a valid stack and writable state, then:

```z80
    call parser_init
    ld hl,command_buffer
    ld bc,command_length
    call parse_command
    or a
    jr nz,rejected
    ld a,(verb_id)
    ; dispatch the action; noun_id is a concept, not an object address
```

HL points at readable bytes; BC is their 16-bit count. A valid input is 0–63 bytes,
and its end must not wrap past the address space. A length above 63 is rejected
before reading input, including a nonzero B. There is no required zero terminator
and no write to the input. Keep it alive while using the borrowed `word1_ptr` /
`word2_ptr` and length bytes for diagnostics. They describe the most recent call
and are cleared at its start; early rejection may leave them empty. A token's
bytes retain the player's original case. Never print them as zero-terminated
strings without copying or explicitly respecting their counts.

A returns status; `parse_status` mirrors it. Both output IDs reset to 0 on every
call, including all failures. Status 0 is success; 1 empty; 2 long; 3 unsupported byte;
4 extra word ; 5 unknown verb ; 6 unknown noun ; 7 missing noun ; 8 unexpected noun ; 9 not ready.
The BASIC companion explains error precedence and the same ASCII grammar in full.
`parser_init` clears status/IDs and sets readiness. Scratch/diagnostic fields only
have a meaningful command lifetime after `parse_command` runs.

AF, BC, DE and HL change. IX and IY survive. The longest parser path uses 10 extra
stack bytes, excluding the caller's two-byte return address and any interrupt
handler's needs. The 16-byte state area must remain writable and exclusively
owned. Do not call concurrently or from an interrupt; an ISR must preserve the
registers it interrupts. The parser itself makes no ROM, display, input, sound,
frame-wait or interrupt-mode call. On another Z80 machine the calling environment,
encoding and available RAM still need their own checks; this is not a claim of
an executed port.

## Vocabulary is validated at build time

Edit the JSON and rebuild. Verb aliases require `word`, `id` and `noun_policy`;
nouns require `word` and `id`. Word spellings are 1–12 uppercase letters/digits.
IDs are integers 1–255; noun policy is 0 none, 1 required or 2 optional. There are 1–32 verb
aliases and 0–32 noun aliases. Counts describe alias records, not distinct concepts.
Duplicate spellings within a table and conflicting policies for one verb ID fail
the build. Booleans, missing/misspelt fields and overlong aliases are rejected.
An invalid input cannot replace an earlier successfully generated table.

Each compiled record stores length, ID, policy and exactly that many word bytes;
a zero-length sentinel ends the table. The scanner reads only within the counted
input. Lookup folds input ASCII case as it compares and requires equal lengths,
so GETTER cannot match GET. Tables may be read-only; generated data contains no
input or world state. The complete example uses 157 table bytes including both
sentinels. The measured parser itself is 342 code bytes plus 16 writable bytes in
the recorded Asm198x build. The tape/editor/font helpers are additional costs.
No universal cycle cost is claimed: input length, alias order, misses and lookup
count change the work.

This trades BASIC's runtime DATA validation and string allocation for checked
static tables and borrowed spans. The assembly routine does not revalidate its
tables at runtime or return BASIC's configuration status 10. Hand-edited/corrupted
record lengths break its precondition; do not bypass the generator. Remapping a
verb ID also requires updating the game dispatch, and saved worlds may depend on
stable concept IDs.

## The working inspector

`demo.asm` supplies the editor, declared 64-byte storage (63 input bytes plus a
spare displayed space), rendering and the lifetime. It reuses the maintained frame
wait, character printer and number printer. Standard 48K ROM IM1 interrupts and IY
system variables are retained; the ROM key latch is consumed once per frame. It
is a latch, not a queue: the keyboard test uses deliberately paced input. The
caller owns stack, bitmap, attributes, key latch and border output, and resets to
leave instead of returning to BASIC. The parser has none of those extra demands.

## Check it

From the samples root, `python scripts/verify-z80-adventure-parser.py --help`
describes the firmware-free CPU fixture. It compares the parser with independent
command rules, consecutive stale-state cases, custom vocabulary, page-crossing
input and guard bytes. A broken extra-word check must fail. The ROM keyboard
caller is checked separately by `verify-adventure-callers.py`; local firmware
is identified by hash and never exported. Snapshot CPU execution is not proof of
ROM input, original hardware or arbitrary composed-game frame budgets.
