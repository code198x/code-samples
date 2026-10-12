# Draw the prepared event QR in Sinclair BASIC

The approved trial draws a prepared pattern; it does not implement QR encoding on the Spectrum.

1. Store the verified event QR's 29 rows as decimal numbers in `_capture/crash-live/typein-qr.bas`. Generate those numbers from the existing event SVG and retain the input, generator and matrix evidence under umbrella `output/crash-live-2026/qr-pattern-v1/`.
2. Use ordinary BASIC arithmetic, PLOT and DRAW to unpack each row into four-pixel black squares on a white screen, with the required quiet margin. Keep the source suitable for a printed type-in.
3. Run that exact source in the existing Emu198x Spectrum BASIC browser integration. Save its actual screen and a tape download. Check every module against the prepared pattern and independently decode the captured screen to the exact event URL.
4. Record the listing length, execution evidence and limits; show the user the result before expanding the flyer design or publishing a new lesson.

No new dependencies or emulator changes are required. Physical camera/CRT scanning remains a separate check.

## Result

The 19-line, 649-byte listing executes in the published Emu198x 48K BASIC integration. The completion caption appeared after 61.937 seconds of host wall time, including preparation and loading. No browser page errors occurred.

All 841 modules match the original pattern. The pixel comparison includes 21,904 pixels across the QR and its four-module white margin; a deliberately flipped module fails the check. Core Image independently decodes the full capture and active-screen crop to the exact event URL. The 867-byte tape has two valid checksum blocks and autostarts at line 10.

The prepared numbers are decoded from right to left with division by two. Each set bit draws four horizontal four-pixel lines. No machine-code helper or special graphics characters are used. The trial draws an existing QR pattern; it does not implement QR encoding. Physical hardware and camera scanning remain untested.

Capture, generator, tape and verification evidence are retained in the umbrella output directory `output/crash-live-2026/qr-pattern-v1/`. The public website is unchanged.
