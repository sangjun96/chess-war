# Skill sounds

The bundled sounds use the piece name as an MP3 filename:

- `pawn.mp3`
- `knight.mp3`
- `bishop.mp3`
- `rook.mp3`
- `queen.mp3`
- `king.mp3`

Each skill definition selects its audio by its `audio` field. Missing files are
ignored. For compatibility with existing custom packs, a skill-named Ogg file
(such as `impact.ogg`) is used when the corresponding piece MP3 is unavailable.
