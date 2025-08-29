// initialize board object
global.board.name = "rp2040-pizero";

// This board does not expose a simple on-board LED or BUTTON for general use.
// Keep pin aliases minimal unless confirmed by vendor docs.

// mount lfs on "/" using dynamic D
const fs = require("fs");
const { VFSLittleFS } = require("vfs_lfs");
const { Flash } = require("flash");
fs.register("lfs", VFSLittleFS);
// Dynamic D: compute from total sectors after A (B=4, C=128)
const total = new Flash().count;
const bd = new Flash(132, total - 132);
fs.mount("/", bd, "lfs", true);

