## Waveshare RP2040-PiZero — Kaluma Board Details

- Name: `rp2040-pizero`
- MCU: RP2040
- Default flash size: 16 MB (PICO_FLASH_SIZE_BYTES=16777216)
- USB: CDC enabled via TinyUSB; stdio over USB

## Flash Partitioning
- A (firmware): 1008 KB (KALUMA_BINARY_MAX=0xFC000)
- B (storage): 16 KB (sectors 0–3)
- C (user program): 512 KB (sectors 4–131)
- D (filesystem): remainder of flash after A/B/C (dynamically mounted)

In code:
- `board.h`: `KALUMA_FLASH_SECTOR_COUNT=3844` (for 16 MB total minus A)
- `board.js`: mounts LittleFS with dynamic D size using `new Flash().count`:
  - `const total = new Flash().count;`
  - `const bd = new Flash(132, total - 132);`
  - `fs.mount("/", bd, "lfs", true);`

This auto-sizes the filesystem for the configured flash size.

## Notes
- The board form factor matches Raspberry Pi Zero, with Micro SD, DVI (via PIO), and USB-C. No generic user LED or button constants are defined here.

## Build
- CMake: `-DTARGET=rp2 -DBOARD=rp2040-pizero`
- Node: `node build.js --target rp2 --board rp2040-pizero`

Outputs include `*.uf2` suitable for BOOTSEL flashing.

## Docker (optional)
- Image: `kaluma-rp2040-pizero`
- Script: `tools/docker/build_rp2040_pizero.sh`
- Output UF2: `./build/*.uf2`
- Flash: Hold BOOTSEL, plug board in, copy UF2 to `RPI-RP2`

