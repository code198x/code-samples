# Supplementary ROM-socket probe: memotech-mtx

This original diagnostic replaces the stock ROM. It isolates direct keyboard, display-status polling and RAM state while bringing up a machine. It is **not** the normal developer loading route.

Use [the stock-firmware caller](../input-loop/README.md) for the maintained qualified example. That caller proves program loading and input together. The ROM diagnostic can still be assembled with make, but it is not counted separately in the 30-machine inventory.
