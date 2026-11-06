# Le Gardien du Savoir — GamePix submission

- Studio: Darkwood
- Engine: Godot 4.7.2 (GL Compatibility), GamePix Godot SDK 1.2r (`Godot/addons/gpx-godot-plugin`, autoload `GPX`)
- Build: `gamepix/build.sh` → `Exports/lgs-gamepix.zip` (index.html at root; only external URL is the official SDK)
- Orientation: Landscape; fits resized iframes without cropping at 800×450
- Default language: English
- Official GamePix title: Le Gardien du Savoir
- Namespace: `le-gardien-du-savoir` (retained, matching the official title).
- Main tag: Puzzle (alternatives: Trivia / Quiz, Adventure)

## Description
Le Gardien du Savoir is a medieval point-and-click quiz adventure. Guide a young monk through towns, monasteries and the island of Histora. Meet unusual characters, collect useful objects and answer questions about science, history and culture. Earn Talents, find three Talismans and prove you are worthy to inherit the Great Book of Knowledge. Explore at your own pace, with English text and a built-in save slot.

## Controls
Desktop: click choices or the scenery to explore. Use the bag for inventory, the disk to save, and the angel for hints. Scroll text panels to read longer messages and answers. Mobile: tap to interact; play in landscape. Answer quizzes to earn Talents and collect the three Talismans. Resume your saved adventure from the main menu.

## Assets
- Icon 256x256: `gamepix/icon-256.png`
- Cover 1360x850: `gamepix/cover-1360x850.jpg`
- Promotional images are original illustrated key art, not screenshots.
- Official submission title: Le Gardien du Savoir.

## Resubmission QA
- 2026-11-05: Withdrew the French-title resubmission at the owner's request. Restored `The Keeper of Knowledge` and resubmitted; portal confirmed `New release REVIEW`. Release notes request GamePix to change the namespace to `the-keeper-of-knowledge`, since the dashboard has no editable namespace field. Namespace migration remains pending GamePix action.
- Final uploaded version: `3LgrcM92E8r9aHyIgQ6d0T0a2Bf` (Game ID `4RS3SV`).
- Final package: `Exports/lgs-gamepix.zip` (black links, no underlines, original lgsfont.ttf).
- Automated checks: 4 viewport sizes, 4 scenes, 129 locations, 117 questions, 856 interactions; zero assertion failures.
- Native 800x450 mouse/keyboard, quiz scoring, inventory and save/load passed.
- Final GamePix Preview verified loading, game start, English signs, save restoration, compact 620x349/mobile 640x360 sizes, pause/resume and sound callbacks.
- Submitted successfully; portal verified `New release REVIEW` and `Game in review!`. Original-font final build rechecked in GamePix Preview before submission.

- Latest revision removes link/action underlines, preserves original font and click handling; controls wording updated. Latest hosted build verified in GamePix Preview and resubmitted; portal confirmed `Game in review!`.

- 2026-11-05: Uploaded black-link build `3LgqCaOJ7NAY7KhDRnqewYwmtVR`; verified loading and black clickable menu actions at 620×349 in GamePix Preview. Resubmitted with English title retained and namespace migration request repeated; portal confirmed `New release REVIEW` and `Game in review!`. ZIP SHA-256: `ffc6801fdbbe5b74577d85b9ea092cd4b9df189ce59e1d41feb40dff8c463dc7`.

- 2026-11-05: Uploaded parchment-introduction build `3LgrcM92E8r9aHyIgQ6d0T0a2Bf` from commit `b4e92e0`. Both original parchment backgrounds restored with centered English text and black links; visual QA at 800×450 and navigation, quiz, inventory, save/load checks passed. Portal confirmed `New release REVIEW`. English title retained; namespace migration request repeated. ZIP SHA-256: `b36e4c33b96ed86f15a01d040550b53cec66c369a6a97b6b47edb093ad8d6112`.

- 2026-11-06: Prepared title alignment to `le-gardien-du-savoir`: official title, in-game headings, browser title, cover and loading background now use `Le Gardien du Savoir`. Gameplay remains English. Saved on GamePix as `New release EDIT`: title and description updated, corrected cover uploaded successfully, build `3LjQm1gDuHi9SqVJA1XFelrhg85` uploaded. ZIP SHA-256: `b8f458b8d936c3168296cfb0facb7f57eb88dd856d2f5f38c3e2279b9fd9caeb`. Automated QA passed (856 interactions, 4 viewport sizes, 129 locations, 117 questions). No submission; awaiting owner validation.

- GamePix Preview verified for build `3LjQm1gDuHi9SqVJA1XFelrhg85`: corrected loading art and French menu title displayed; SDK reached LOADED. Draft remains `edit`, not submitted.
