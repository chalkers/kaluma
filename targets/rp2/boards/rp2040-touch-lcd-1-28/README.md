## Waveshare RP2040-Touch-LCD-1.28 — Kaluma Board Details

- Name: `rp2040-touch-lcd-1-28`
- MCU: RP2040
- Default flash size: 16 MB (`PICO_FLASH_SIZE_BYTES=16777216`)
- USB: CDC enabled via TinyUSB; stdio over USB

## Flash Partitioning
- A (firmware): 1008 KB (`KALUMA_BINARY_MAX=0xFC000`)
- B (storage): 16 KB (`KALUMA_STORAGE_SECTOR_BASE=0`, `COUNT=4`)
- C (user program): 512 KB (`KALUMA_PROG_SECTOR_BASE=4`, `COUNT=128`)
- D (filesystem): remainder of flash after A/B/C (dynamically mounted)

In code:
- `board.h`: `KALUMA_FLASH_SECTOR_COUNT=3844` (for 16 MB total minus A)
- `board.js`: mounts LittleFS with dynamic D size using `new Flash().count`:
  - `const total = new Flash().count;`
  - `const bd = new Flash(132, total - 132);`
  - `fs.mount("/", bd, "lfs", true);`

This auto-sizes the filesystem for the configured flash size. For 16 MB:
- Total sectors after A: 3844
- D sectors: `3844 - 132 = 3712` (~14.5 MiB)

## Notes
- The board integrates a round 1.28" SPI LCD, capacitive touch, and an IMU over I2C/SPI. These peripherals are driven by application code; Kaluma board config exposes only generic MCU features and filesystem.
- No explicit `LED`/`BUTTON` pin constants are defined in `board.js`. Add them later if you want convenient aliases.

## Build
- CMake: `-DTARGET=rp2 -DBOARD=rp2040-touch-lcd-1-28`
- Node: `node build.js --target rp2 --board rp2040-touch-lcd-1-28`

Outputs include `*.uf2` suitable for BOOTSEL flashing.

## Docker (recommended)
- Image: `kaluma-rp2040-touch-lcd-1-28`
- Script: `tools/docker/build_rp2040_touch_lcd_1_28.sh`
- Output UF2: `./build/*.uf2`
- Flash: Hold BOOTSEL, plug board in, copy UF2 to `RPI-RP2`
