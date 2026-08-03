# Skill sounds

The bundled sounds use the piece name as an MP3 filename:

- `pawn.mp3`
- `knight.mp3`
- `bishop.mp3`
- `rook.mp3`
- `queen.mp3`
- `king.mp3`

Each skill definition uses its `audio` cue to select the asset and align its
delay, volume, pitch, fade, and maximum playback duration with the impact
frame. Long clips are faded and stopped with the visual sequence. Missing files
are ignored. For compatibility with existing custom packs, a skill-named Ogg
file (such as `impact.ogg`) is used when the corresponding piece MP3 is
unavailable.

Formation attacks intentionally share one cue while keeping an animation on
every target, so selecting several pawns does not stack the same sound.
