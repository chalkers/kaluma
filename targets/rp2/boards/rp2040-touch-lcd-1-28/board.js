// initialize board object
global.board.name = "rp2040-touch-lcd-1-28";
// Optional: define helper pins if desired in future (e.g., LED, BUTTON)
// This board primarily exposes a round SPI LCD + capacitive touch and IMU.

// mount lfs on "/" using dynamic D
const fs = require("fs");
const { VFSLittleFS } = require("vfs_lfs");
const { Flash } = require("flash");
fs.register("lfs", VFSLittleFS);
// Dynamic D: compute from total sectors after A (B=4, C=128)
const total = new Flash().count;
const bd = new Flash(132, total - 132);
fs.mount("/", bd, "lfs", true);

