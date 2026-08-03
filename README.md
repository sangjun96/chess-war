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
- Press `Q` to open the action wheel at the cursor. Choose **Move**, then click a cyan tile to move the selection (including captures). With multiple selected pawns, cyan tiles show only shared moves that every pawn can legally make; the move is applied to all of them together or not at all.
- `Attack` and `Guard` are visible future actions; they currently report that they are unavailable.
- Drag with the left mouse button from anywhere else to pan.
- Hold `W`, `A`, `S`, or `D` to move the camera. Diagonal key combinations move at the same speed as a single direction.
- Use the mouse wheel to zoom toward the cursor.
- Press `Home` to return to the center. Press `Esc` to close a menu or cancel a move; press it again to quit.

## Artwork

The tile and piece artwork in `assets/isocubic-chess/` is by Nikoichu and is
licensed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/).
See `assets/isocubic-chess/License.txt` for the full license.
