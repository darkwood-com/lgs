# Le Gardien du Savoir — GamePix submission

- Studio: Darkwood
- Engine: Godot 4.7.2 (GL Compatibility), GamePix Godot SDK 1.2r (`Godot/addons/gpx-godot-plugin`, autoload `GPX`)
- Build: `gamepix/build.sh` → `Exports/lgs-gamepix.zip` (index.html at root; only external URL is the official SDK)
- Orientation: Landscape; fits resized iframes without cropping at 800×450
- Default language: English
- Main tag: Puzzle (alternatives: Trivia / Quiz, Adventure)

## Description
The Keeper of Knowledge is a medieval point-and-click quiz adventure. Guide a young monk through towns, monasteries and the island of Histora. Meet unusual characters, collect useful objects and answer questions about science, history and culture. Earn Talents, find three Talismans and prove you are worthy to inherit the Great Book of Knowledge. Explore at your own pace, with English text and a built-in save slot.

## Controls
Desktop: click choices or the scenery to explore. Use the bag for inventory, the disk to save, and the angel for hints. Scroll text panels to read longer messages and answers. Mobile: tap to interact; play in landscape. Answer quizzes to earn Talents and collect the three Talismans. Resume your saved adventure from the main menu.

## Assets
- Icon 256x256: `gamepix/icon-256.png`
- Cover 1360x850: `gamepix/cover-1360x850.jpg`
- Promotional images are original illustrated key art, not screenshots.
- Original title: Le Gardien du Savoir; English title: The Keeper of Knowledge.

## Resubmission QA
- Final uploaded version: `3LfBIiLc7O6XlO2xGn1QV7INFKR` (Game ID `4RS3SV`).
- Final package: `Exports/lgs-gamepix-no-underlines.zip` (original lgsfont.ttf).
- Automated checks: 4 viewport sizes, 4 scenes, 129 locations, 117 questions, 856 interactions; zero assertion failures.
- Native 800x450 mouse/keyboard, quiz scoring, inventory and save/load passed.
- Final GamePix Preview verified loading, game start, English signs, save restoration, compact 620x349/mobile 640x360 sizes, pause/resume and sound callbacks.
- Submitted successfully; portal verified `New release REVIEW` and `Game in review!`. Original-font final build rechecked in GamePix Preview before submission.

- Latest revision removes link/action underlines, preserves original font and click handling; controls wording updated. Latest hosted build verified in GamePix Preview and resubmitted; portal confirmed `Game in review!`.
