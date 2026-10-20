# Guest Read Track boundaries

This MIT fixture is cold-loaded from DISK/DIAG.BIN through the +3 ROM. The Z80
then seeks to cylinder 39 and reads authored fields using the public FDC ports.
The host observes RAM; it does not inject code, restore a snapshot or drive the
controller on behalf of the guest.

`fixture.py` freezes six cases: N0 DTL1/127, N5, commanded N0/recorded N2,
represented 128-byte data against N2, and reversed two fields with EOT3 wrap.
The builder takes a freshly mastered standard 180 KiB Build198x disk. It retains
all first 39 tracks' bytes except for the explicit 512-byte EDSK length metadata,
and replaces track39. The small loader/CODE files fit in the preserved tracks;
the umbrella verifier checks the original filesystem and exact boot payloads.
This is fixture rearrangement, not a production mastering option.

A checked-in `case.inc` selects N0/DTL1 for standalone sample builds.
The recipe writes a case-specific `case.inc` with nine command bytes alongside a copy of
`diagnostic.asm`; Asm198x assembles that source at $8000. Build198x `plus3`
masters `loader.bas` and CODE, then `fixture.make` authors the EDSK test track.
`$7000`/`$7001` receive a constructed completion signature; `$7002` holds the
returned payload length; `$7004` counts seven result bytes. `$7010` holds the
result and `$7017` the subsequent Sense Drive Status. Payload is captured at
`$a000`, bounded below `$e000`. Polling is bounded by the runner's emulated-frame
and host limits; send/receive helpers also have finite polling counters.

From the umbrella checkout, use `ops/qualification/read_track_guest.py` with
explicit released tool manifest and local English v4.0 firmware. Its README and
retained evidence document exact commands, versions, expectations and reference
observations. These are regression expectations for the current sector-image
model. They do not establish physical timing, raw gaps/flux or all Read Track
semantics. Firmware is never included.

Run fixture checks here with `python3.14 -m unittest test_fixture`.


The v2 umbrella campaign also calls the additive `missing_entry_case()` fixture.
Its track39 EDSK table entry is zero and there is no track block. This is a valid
container omission decoded as an empty track placeholder, not a raw missing DAM
or ID mark. The guest seeds16 bytes of $c3 at $a000 before command service. The
new case must return zero payload bytes, leave those guards unchanged, drain
seven result bytes, recover with a real next command and signal completion.
The existing `cases()` list and checked-in N0/DTL1 default remain unchanged.
The missing-entry raw reference result is recorded separately from the released
Emu regression expectation; no physical search-time or chip equivalence follows.

The v3 campaign additionally calls `reverse_size_case()`: the guest commands N2
(512 bytes) while the EDSK descriptor records N0 with128 data bytes. The existing
program and standalone default are unchanged. The host checks the full512-byte
Emu-model transfer, including every zero-padding byte after the128 represented
bytes, all seven result bytes and recovery. Independent MAME observations remain
separate; this does not establish magnetic field length or hardware CRC/timing.

`n2_dtl_cases()` adds the v4 paired contrast: an ordinary recorded N2 field
with 512 represented bytes of $21, commanded as N2 with DTL255 and DTL1.
The native test track is identical; only the last guest command byte differs.
The umbrella campaign checks every byte, all seven results and command recovery,
and compares the pair within each runtime. This is bounded sector-image evidence.
