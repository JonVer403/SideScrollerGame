1. ~~De sprite van de auto staat niet gelijk met de collision.~~ ✅ GEDAAN
   - Collision box en sprite offset toegevoegd in player.lua
   - Auto tekening verbeterd met car-shape placeholder
   
2. ~~Achtergrond moet een foto zijn die blijft scrollen.~~ ✅ GEDAAN
   - background.lua ondersteunt nu afbeeldingen
   - Parallax scrolling met 4 lagen
   - Fallback met visuele details (wolken, gebouwen, wegstrepen)
   
3. ~~Sprites voor de obstakels en ramp.~~ ✅ GEDAAN
   - obstacle.lua ondersteunt nu sprites
   - Verbeterde fallback tekeningen (verkeerskegel, vogel, ramp met pijl)
   - Sprites laden vanuit Sprites/ folder
   
4. ~~Soundeffects.~~ ✅ GEDAAN
   - sound.lua uitgebreid met meer geluiden
   - Ramp geluid, land geluid, gameover geluid toegevoegd
   - Engine/wind ambient loops ondersteuning

5. ~~Levels kunnen beter.~~ ✅ GEDAAN
   - 6 levels in plaats van 4
   - Tutorial Track voor beginners
   - Endless Mode voor experts
   - Betere level selector (2 rijen, 3 kolommen)
   - Descriptions en difficulty indicators

6. (als tijd over) spritesheets.
   - Basis spritesheet ondersteuning in sprites.lua (al aanwezig)

---

## Benodigde assets (optioneel)

### Sprites (plaats in Sprites/ folder):
- `background.png` of aparte lagen:
  - `background_sky.png`
  - `background_clouds.png`
  - `background_city.png`
  - `background_road.png`
- `obstacle_ground.png` (50x60px)
- `obstacle_flying.png` (60x50px)
- `obstacle_ramp.png` (80x50px)
- `player.png` (80x80px)

### Sounds (plaats in sounds/ folder):
- `jump.wav`, `land.wav`
- `hit.wav`, `ramp.wav`
- `nos_pickup.wav`, `nos_activate.wav`, `nos_end.wav`
- `finish.wav`, `gameover.wav`
- `select.wav`, `confirm.wav`, `highscore.wav`
