# Heartbeat video

Captured 22 September 2026 for the unit 09 lesson, using the unchanged program.
Emu198x workspace 0.25.0, release `emu198x-amiga` built without default features;
A500, default PAL configuration, Kickstart 1.3; cold boot from `heartbeat.adf`.
No memory pokes, synthetic colour animation or input were used.

Baseline SHA-256:

- Source: `42110d3ee9c7ead898805ac8a540c1bed0fcfae8752d3da51a975f22d6b0d187`
- Hunk executable: `b9dc6b87f8aa932a32e348e0cbc28f1d1beb8ead7ad00dc323db19b67016bccd`
- ADF: `3696ddbb492b6a04de093fddb1edcc48a2036c387b650899fe73089932c7b017`

Reassembling the source with Asm198x 0.0.58 (`--dialect vasm --exe`) produced a
byte-identical executable. The existing ADF was loaded, not rebuilt.

From the code-samples root:

```sh
python3 _capture/capture.py commodore-amiga/assembly/meet-the-machine/unit-09/capture/video.manifest.json --emu /path/to/emu198x-amiga
```

The manifest uses the capture runner's existing Kickstart lookup. Firmware is
not included. The expanded script alongside it uses a portable output filename;
the runner regenerates it with the selected website output location.

After 1,600 boot frames, the script requests 600 recording frames. The recorder
reported 12,000 ms and 600 submitted frames; ffprobe reports 598 encoded video
frames. The delivered H.264 clip is 768×576 at 50 fps and 11.96 seconds. Do not
use this compressed demonstration to establish exact per-frame timing.

FFmpeg 9.0.1 removed the recorder's audio stream without re-encoding video and
moved the MP4 index to the front for browser playback:

```sh
ffmpeg -i heartbeat.mp4 -map 0:v:0 -c:v copy -an -movflags +faststart heartbeat-silent.mp4
ffmpeg -i heartbeat-silent.mp4 -frames:v 1 heartbeat-poster.png
```

The website stores `heartbeat-silent.mp4` as `heartbeat.mp4`, together with its
first-frame poster, in `public/images/commodore-amiga/assembly/meet-the-machine/unit-09/`.
The lesson player starts paused, does not loop, and has native playback controls.
A one-second contact sheet confirms varied full-screen colours throughout the
recording. Browser playback was also checked in the rendered lesson. This is
emulator execution evidence, not original-hardware evidence.
