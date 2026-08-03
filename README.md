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

- Red takes the first turn; after each completed move or skill, the turn passes to Blue. Both sides are manually controllable for now, so an AI controller can be added later without changing the turn flow.
- Click a piece belonging to the active team to select it. Its tile receives a gold highlight and the piece receives a pointer above its head.
- Drag from a pawn to draw a selection box. Only pawns inside the box are selected, so multiple-piece selection is limited to pawns.
- Every piece has HP and a pixel-style health gauge above it. Pawns have 3 HP, minor pieces 5 HP, rooks 7 HP, the queen 9 HP, and the king 12 HP. Pieces also become darker and less saturated as their HP falls.
- Press `Q` to open the action wheel at the cursor. Choose **Move**, then click a cyan tile to move the selection. Moving onto an enemy deals the mover's damage; the attacker only takes that tile once the enemy's HP reaches zero. With multiple selected pawns, cyan tiles show only shared moves that every pawn can legally make; the move is applied to all of them together or not at all.
- Choose **Attack**, then click an orange tile to fire the selected piece's skill without moving it. Skill targeting uses its own range instead of the piece's chess movement. When multiple pawns are selected, orange tiles cover their shared formation range and every selected pawn fires with the same target offset. For area skills, hover an orange tile to preview the red tiles that will be hit; area skills damage every enemy in their effect radius.
- Skill effects play as a timed cast, travel, impact, and particle-tail sequence. Sound cues land on the impact frame; a multi-pawn volley keeps each visual hit while playing its shared sound only once.
- `Guard` is a visible future action and currently reports that it is unavailable.
- Removing an opposing king immediately ends the game and declares the other team the winner.
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

The project includes third-party sprite artwork. Copyright remains with the
respective creators; these assets are used under the licenses and terms below.

- **Chess tiles and pieces** — [Isocubic Chess FREE - Chess Set](https://nikoichu.itch.io/isocubic-chess-free)
  by Nikoichu, used in `assets/isocubic-chess/`. Licensed under
  [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/).
  See `assets/isocubic-chess/License.txt` for the full license.
- **Combat effects** — [Super Pixel Effects Gigapack (Free Version)](https://untiedgames.itch.io/super-pixel-effects-gigapack)
  by Will Tice / unTied Games, used in `assets/skill-effects/`. Attribution is
  required; commercial and non-commercial use are permitted, but the assets
  themselves may not be resold. See `assets/skill-effects/License.txt` for the
  full terms.
- **Magic effects** — [Free Magic Pack 9](https://ansimuz.itch.io/gothicvania-magic-pack-9)
  by Luis Zuno (ansimuz), used by composite effects in
  `assets/skill-effects/royal-calamity/`. See the bundled
  `assets/skill-effects/royal-calamity/Magic-Pack-9-license.pdf` for its
  license terms.

## Development Credits

- **Sound effects** — Generated with [ElevenLabs](https://elevenlabs.io/).
- **Code development** — Built with assistance from the ChatGPT desktop app,
  using a mix of Sol, Terra, and Luna models.
