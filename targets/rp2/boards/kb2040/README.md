## Adafruit KB2040 (RP2040) — Kaluma Board Details

- Name: `kb2040`
- MCU: RP2040
- Default flash size: 8 MB (`PICO_FLASH_SIZE_BYTES=8388608`)
- XOSC: `PICO_XOSC_STARTUP_DELAY_MULTIPLIER=64`
- USB: CDC enabled via TinyUSB; stdio over USB

## Pin Mappings
- `NEOPIXEL`: GPIO 17 (on-board WS2812 data)
- `BUTTON`: GPIO 11 (user button)
- STEMMA QT (I2C0): SDA=12, SCL=13

## Flash Partitioning
- A (firmware): 1008 KB (`KALUMA_BINARY_MAX=0xFC000`)
- B (storage): 16 KB (`KALUMA_STORAGE_SECTOR_BASE=0`, `COUNT=4`)
- C (user program): 512 KB (`KALUMA_PROG_SECTOR_BASE=4`, `COUNT=128`)
- D (filesystem): remainder of flash after A/B/C

In code:
- `board.h`: `KALUMA_FLASH_SECTOR_COUNT=1796` (for 8 MB total minus A)
- `board.js`: mounts LittleFS with dynamic D size using `new Flash().count`:
  - `const total = new Flash().count;`
  - `const bd = new Flash(132, total - 132);`
  - `fs.mount("/", bd, "lfs", true);`

This auto-sizes the filesystem for the configured flash size. For 8 MB:
- Total sectors after A: 1796
- D sectors: `1796 - 132 = 1664` (~6.5 MiB)

## Build
- CMake: `-DTARGET=rp2 -DBOARD=kb2040`
- Docker (example image name): `kaluma-kb2040`

Outputs include `*.uf2` suitable for BOOTSEL flashing.

## Notes
- The Winbond boot stage selection `PICO_BOOT_STAGE2_CHOOSE_W25Q080` refers to a stub optimized for the Winbond W25Q family; KB2040 typically uses an 8 MB part (e.g., W25Q64). Pico’s default is 2 MB (W25Q16).
