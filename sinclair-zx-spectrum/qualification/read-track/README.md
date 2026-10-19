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

The recipe writes `case.inc` with nine command bytes alongside a copy of
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
