// initialize board object
global.board.name = "kb2040";
global.board.NEOPIXEL = 17;
global.board.BUTTON = 11;
// Note: KB2040 does not have a simple GPIO LED; it has a NeoPixel.

// mount lfs on "/"
const fs = require("fs");
const { VFSLittleFS } = require("vfs_lfs");
const { Flash } = require("flash");
fs.register("lfs", VFSLittleFS);
// Dynamic D: compute from total sectors after A (B=4, C=128)
const total = new Flash().count;
const bd = new Flash(132, total - 132);
fs.mount("/", bd, "lfs", true);
