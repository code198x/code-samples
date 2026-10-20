# Sense Drive Status input diagnostic

The program loads through the normal +3 ROM disk loader, moves drive A to
cylinder9, drains its interrupt and records Sense Drive Status for all eight
logical unit/head selections. Units0/2 select A and1/3 select B; selected head
and logical unit must be echoed independently of drive inputs.

This fixture names protected mounted A and absent B. It checks TS, T0, READY,
WP and Fault separately, together with one-byte result framing and following
MSR. It does not establish empty physical A write protection, attached-empty
external B, exact mechanical/multiplex timing or another hardware revision.

The five-byte trace protocol and bounded send/receive/drain routines follow
`../sense-interrupt/diagnostic.asm`. Stage0 retains both setup drains; stages1–8
record SDS selections0–7. The program writes its A5/5A completion signature
only after those transactions and fills the screen with AA bitmap /47 attributes.
No host memory writes, snapshot restoration or quickload are used.

Build with Asm198x pasmo/Z80 at origin and entry32768. Master the accompanying
BASIC loader and assembled CODE using Build198x plus3. The umbrella SDS guest
consumer validates native metadata and observes loaded CODE, execution-created
writes, trace, PC and full screen in fresh processes with bounded emulated and
host execution. Reference results remain separate observations.

Source/assets: MIT (SPDX identifiers in the assembly); local firmware is not
redistributed. This fixture alone does not qualify the complete SDS operation.
