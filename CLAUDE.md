# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

A classic Tetris implementation in vanilla JavaScript, HTML5 Canvas, and CSS — no dependencies, no build step, no package.json. The README (in Spanish) is the canonical project documentation; keep it in sync with any gameplay/UI changes.

## Running the game

No install or build required. Either open `index.html` directly in a browser, or serve it statically:

```bash
python3 -m http.server 8000
# or
npx serve .
```

There is no test suite, linter, or build tooling in this repo.

## Architecture

Three files, no modules/bundler — `index.html` loads `game.js` as a single classic script that runs immediately (`init()` is called at the bottom of the file).

- **`index.html`** — DOM shell: the main `#board` canvas (300×600, 10×20 cells at 30px/cell), a `#next-canvas` preview, HUD elements (score/lines/level), and a pause/game-over `#overlay`.
- **`style.css`** — dark/retro arcade visual theme only; no layout logic worth noting beyond flexbox panel layout.
- **`game.js`** — all game logic, structured around a small set of global `let` bindings (`board`, `current`, `next`, `score`, `lines`, `level`, `paused`, `gameOver`, `dropInterval`, etc.) rather than a class or module pattern. Key pieces:
  - **Board model**: `ROWS × COLS` matrix where each cell is `0` (empty) or a piece color index (1–7).
  - **Pieces**: defined as square matrices in `PIECES`; rotation is done via matrix transpose+reverse in `rotateCW`.
  - **Collision** (`collide`): bounds + overlap check against the board.
  - **Wall kicks** (`tryRotate`): after rotating, tries offsets `[0, -1, 1, -2, 2]` columns until a non-colliding position is found.
  - **Game loop** (`loop`): driven by `requestAnimationFrame`, accumulates elapsed time and advances the piece one row when `dropAccum >= dropInterval`.
  - **Line clearing** (`clearLines`): scans bottom-up, splices full rows out and unshifts empty rows at the top.
  - **Scoring**: `LINE_SCORES = [0, 100, 300, 500, 800]` multiplied by `level`; hard drop adds 2 pts/cell dropped, soft drop adds 1 pt/row.
  - **Leveling/speed**: level increases every 10 lines; `dropInterval = max(100, 1000 - (level - 1) * 90)` ms.
  - **Ghost piece** (`ghostY`): projects the current piece straight down to its landing row, drawn at `globalAlpha = 0.2`.
  - Input is handled by a single `keydown` listener (arrow keys, `X` to rotate, `Space` for hard drop, `P` to pause); `spawn()` triggers `endGame()` if a newly spawned piece already collides.

When tuning gameplay constants (`COLS`, `ROWS`, `BLOCK`, `LINE_SCORES`, initial `dropInterval`), note that changing `COLS`/`ROWS`/`BLOCK` requires updating the `width`/`height` attributes of `#board` in `index.html` to match (`COLS × BLOCK` and `ROWS × BLOCK`).
