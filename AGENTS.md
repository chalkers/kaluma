# AGENTS Guide — Kaluma Boards (RP2040/RP2350)

This file outlines how to extend and maintain RP2 (RP2040) board support for Kaluma, and the conventions for agents working on this repository.

## Repository
- Baseline for RP2 work: tag `1.2.1`
- Default branch: `master`
- Working branch convention: `feature/<board>-support`
- Commit style: squash to a single, tidy commit when opening a PR

## Build & Flash

### Docker (recommended)
- Image: `kaluma-kb2040`
- Script: `tools/docker/build_kb2040.sh`
- Outputs UF2 to: `./build`
- Flash: Hold BOOTSEL, plug board in, copy `*.uf2` to `RPI-RP2` mass storage

### Manual (local toolchain)
- `npm install`
- `node build.js --target rp2 --board kb2040`
- Flash via BOOTSEL by copying UF2 from `build/`

## Flash Partitioning

### RP2040 (e.g., KB2040)
- A (firmware): `KALUMA_BINARY_MAX = 0xFC000` (1008 KB)
- B (storage): 16 KB → sectors 0–3
- C (user program): 512 KB → sectors 4–131
- D (filesystem): remainder of flash after A/B/C
- Sector size: 4096 bytes; Flash page size: 256 bytes

### RP2350 (e.g., Pico 2)
- Total flash (default): 4 MB
- A (firmware): `KALUMA_BINARY_MAX = 0xF0000` (960 KB)
- B (storage): 64 KB → sectors 0–15
- C (user program): 1536 KB → sectors 16–399
- D (filesystem): remainder of flash after A/B/C
- Sector size: 4096 bytes

### Dynamic D example for RP2350 (Pico 2):

```js
// in board.js (Pico 2)
const fs = require('fs');
const { VFSLittleFS } = require('vfs_lfs');
const { Flash } = require('flash');
fs.register('lfs', VFSLittleFS);
const total = new Flash().count;       // sectors after A
const bd = new Flash(400, total - 400); // B=16, C=384 → start=400
fs.mount('/', bd, 'lfs', true);
```

### Dynamic D (preferred)
Mount LittleFS using the full available space after A/B/C.

```js
// in board.js
const fs = require('fs');
const { VFSLittleFS } = require('vfs_lfs');
const { Flash } = require('flash');
fs.register('lfs', VFSLittleFS);
const total = new Flash().count;     // sectors after A
const bd = new Flash(132, total - 132); // B=4, C=128 → start=132
fs.mount('/', bd, 'lfs', true);
```

## RP2 Board Porting Checklist
1) Create `targets/rp2/boards/<board>/` with:
   - `board.h`: partitions and macros (copy pico as baseline; adjust flash counts)
   - `board.c`: `void board_init() {}` (or board-specific init)
   - `board.js`: set `global.board.name`, optional pins (`LED`, `BUTTON`, `NEOPIXEL`), and dynamic LFS mount
2) Add to `targets/rp2/target.cmake`:
   - RP2040: `elseif(BOARD STREQUAL "<board>")` → `set(PICO_BOARD pico)`; set defaults (e.g., `PICO_FLASH_SIZE_BYTES`, XOSC delay)
   - RP2350: `elseif(BOARD STREQUAL "<board>")` → `set(PICO_BOARD pico2 or pico2_w)`; toolchain switches to Cortex-M33
3) Build and flash (Docker or manual)
4) Verify in REPL:
   - `board.name`
   - Pin constants (`board.BUTTON`, etc.)
   - Flash probe: `new (require('flash').Flash)().count`
   - FS works: `require('fs').readdir('/')`

## Sources for Pin/Board Data
- Vendor pinouts (e.g., Adafruit Learning System: KB2040 Pinouts)
- CircuitPython boards repo: `ports/raspberrypi/boards/<board>/pins.c`
- Pico SDK board headers: `lib/pico-sdk/src/boards/include/boards/*.h`
- Datasheets/schematics (RP2040 + board PDF)
- Community firmware (QMK, CircuitPython, MicroPython) for cross-checks

## Docker Environment Notes
- Tools: `gcc-arm-none-eabi`, `libnewlib-arm-none-eabi`, `libstdc++-arm-none-eabi-newlib`, `cmake`, `python3`, `nodejs`, `npm`
- Provide `python` symlink to `python3` inside the image
- Initialize submodules inside the container; run a `node build.js --clean` before building to avoid host cache conflicts

## Do / Don’t
- Do: keep changes scoped; keep a single clean commit for PRs
- Do: prefer dynamic D filesystem sizing
- Don’t: change Kaluma core behavior without explicit approval
- Don’t: introduce breaking changes for existing targets

## PR Contents (example for a new board)
- New `targets/rp2/boards/<board>/board.{h,c,js}` and `README.md`
- `targets/rp2/target.cmake` mapping
- Optional Dockerfile and `tools/docker/build_<board>.sh`
- Single squashed commit with concise message
