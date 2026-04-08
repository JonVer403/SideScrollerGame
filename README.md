# Pixel Racer - Side Scroller Game

Een LÖVE2D side-scroller racegame met NOS boost systeem, levels, en leaderboards.

## Features

### ✅ Geïmplementeerd

- **Achtergrond Scroller** - Parallax scrolling background met meerdere lagen
- **NOS Boost Systeem** - Verzamel NOS pickups en activeer boost (zoals Asphalt)
- **Level Kiezer** - 4 levels met verschillende moeilijkheidsgraden
- **Leaderboard** - Aparte high scores per level, opgeslagen lokaal
- **Jump Charge** - Houd SPACE ingedrukt voor een hogere sprong
- **Sound Framework** - Klaar voor geluidseffecten

## Besturing

| Toets | Actie |
|-------|-------|
| `SPACE` (indrukken) | Start jump charge |
| `SPACE` (loslaten) | Sprong uitvoeren |
| `LEFT/RIGHT` | Bewegen |
| `SHIFT` | NOS boost activeren |
| `R` | Level herstarten |
| `ESC` | Terug naar level selectie |
| `L` | Leaderboard tonen |
| `M` | Geluid mute/unmute |
| `1-4` | (In leaderboard) Bekijk level scores |
| `TAB` | (In leaderboard) Naam invoeren |

## NOS Boost Systeem

- Verzamel blauwe **N** pickups om je NOS meter te vullen
- Elke pickup geeft 25% charge
- Druk op **SHIFT** om boost te activeren (minimaal 25% nodig)
- Tijdens boost:
  - Snelheid verdubbelt
  - Achtergrond scrollt sneller
  - Timer telt langzamer af

## Levels

| Level | Naam | Snelheid | Tijd |
|-------|------|----------|------|
| 1 | Easy Street | 150 | 60s |
| 2 | Highway Rush | 200 | 50s |
| 3 | Night Race | 250 | 45s |
| 4 | Extreme Circuit | 300 | 40s |

## Assets Toevoegen

### Sprites
Maak een `sprites` folder met:
```
sprites/
├── player.png         (320x80 spritesheet, 4 frames van 80x80)
├── player_jump.png    (160x80 spritesheet, 2 frames)
├── obstacle.png       (80x80)
├── nos_pickup.png     (160x40 spritesheet, 4 frames van 40x40)
├── bg_sky.png         (1280x290, tileable)
├── bg_mountains.png   (1280x220, tileable)
└── bg_ground.png      (1280x50, tileable)
```

### Geluidseffecten
Maak een `sounds` folder met:
```
sounds/
├── jump.wav
├── nos_pickup.wav
├── nos_activate.wav
├── nos_end.wav
├── hit.wav
├── finish.wav
├── select.wav
└── highscore.wav
```

## Installatie

1. Download [LÖVE2D](https://love2d.org/)
2. Run: `love .` in de game folder
3. Of gebruik `run.bat` op Windows

## Bestanden

| Bestand | Beschrijving |
|---------|--------------|
| `main.lua` | Hoofd game loop en state management |
| `player.lua` | Speler beweging en jump charge |
| `obstacle.lua` | Obstakels en collision |
| `background.lua` | Parallax scrolling achtergrond |
| `nos.lua` | NOS pickup en boost systeem |
| `levels.lua` | Level definities en selector |
| `leaderboard.lua` | Score opslag per level |
| `sound.lua` | Geluid framework |
| `sprites.lua` | Sprite management |
| `conf.lua` | LÖVE configuratie |