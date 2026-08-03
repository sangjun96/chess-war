# Chess War

Minimal [LÖVE](https://love2d.org/) project setup.

## Run

From this directory:

```sh
love .
```

The project opens an interactive 16 by 16 isometric chess board. Each side has
one 16-piece army: four rooks, four bishops, six knights, and one each of the
unique queen and king. A full line of 16 pawns stands in front of each army.
The queen and king occupy the center two files.

- Click a piece to select it. Its tile receives a gold highlight and the piece receives a pointer above its head.
- Drag from a pawn to draw a selection box. Only pawns inside the box are selected, so multiple-piece selection is limited to pawns.
- Every piece has HP and a pixel-style health gauge above it. Pawns have 3 HP, minor pieces 5 HP, rooks 7 HP, the queen 9 HP, and the king 12 HP. Pieces also become darker and less saturated as their HP falls.
- Press `Q` to open the action wheel at the cursor. Choose **Move**, then click a cyan tile to move the selection. Moving onto an enemy deals the mover's damage; the attacker only takes that tile once the enemy's HP reaches zero. With multiple selected pawns, cyan tiles show only shared moves that every pawn can legally make; the move is applied to all of them together or not at all.
- Choose **Attack**, then click an orange tile to fire the selected piece's skill without moving it. Skill targeting uses its own range instead of the piece's chess movement. When multiple pawns are selected, orange tiles cover their shared formation range and every selected pawn fires with the same target offset. For area skills, hover an orange tile to preview the red tiles that will be hit; area skills damage every enemy in their effect radius.
- Skill effects play as a timed cast, travel, impact, and particle-tail sequence. Sound cues land on the impact frame; a multi-pawn volley keeps each visual hit while playing its shared sound only once.
- `Guard` is a visible future action and currently reports that it is unavailable.
- Each piece type has a replaceable combat skill. Edit the assignments in
  `piece_skills.lua` to switch effects without changing combat or rendering code.
  Edit `range` and `effectRadius` in `skill_catalog.lua` to tune its targeting.
  Piece sounds live at `assets/audio/skills/<piece-name>.mp3`; custom packs can
  still fall back to `assets/audio/skills/<skill-id>.ogg`.
- Drag with the left mouse button from anywhere else to pan.
- Hold `W`, `A`, `S`, or `D` to move the camera. Diagonal key combinations move at the same speed as a single direction.
- Use the mouse wheel to zoom toward the cursor.
- Press `Home` to return to the center. Press `Esc` to close a menu or cancel a move; press it again to quit.

## Artwork

The tile and piece artwork in `assets/isocubic-chess/` is by Nikoichu and is
licensed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/).
See `assets/isocubic-chess/License.txt` for the full license.

The combat effects in `assets/skill-effects/` are selected from **Super Pixel
Effects Gigapack (Free Version)** by Will Tice / unTied Games. See
`assets/skill-effects/License.txt` for its license summary and attribution terms.

Several composite combat effects also use the supplied **Magic Pack 9** by Luis
Zuno. Its bundled license is at
`assets/skill-effects/royal-calamity/Magic-Pack-9-license.pdf`.
