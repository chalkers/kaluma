/* Kaluma board configuration for Waveshare RP2040-Touch-LCD-1.28 (RP2040)
 */

#ifndef __RP2_RP2040_TOUCH_LCD_1_28_H
#define __RP2_RP2040_TOUCH_LCD_1_28_H

#include "jerryscript.h"

// system
#define KALUMA_SYSTEM_ARCH "cortex-m0-plus"
#define KALUMA_SYSTEM_PLATFORM "rp2"

// repl
#define KALUMA_REPL_BUFFER_SIZE 1024
#define KALUMA_REPL_HISTORY_SIZE 10

// Flash allocation map (board ships with 16MB external flash)
//
// |         A        | B |     C     |                     D                     |
// |------------------|---|-----------|-------------------------------------------|
// |      1008K       |16K|   512K    |  remainder (~14.99MB after A/B/C)         |
//
// - A : binary (firmware)
// - B : storage (key-value database)
// - C : user program (js)
// - D : file system (lfs)

// binary (1008KB)
#define KALUMA_BINARY_MAX 0xFC000

// flash (B + C + D)
#define KALUMA_FLASH_OFFSET KALUMA_BINARY_MAX
#define KALUMA_FLASH_SECTOR_SIZE 4096
#define KALUMA_FLASH_SECTOR_COUNT 3844
#define KALUMA_FLASH_PAGE_SIZE 256

// user program on flash (512KB)
#define KALUMA_PROG_SECTOR_BASE 4
#define KALUMA_PROG_SECTOR_COUNT 128

// storage on flash (16KB)
#define KALUMA_STORAGE_SECTOR_BASE 0
#define KALUMA_STORAGE_SECTOR_COUNT 4

// file system on flash (dynamic)
// - sector base : 132
// - sector count : (KALUMA_FLASH_SECTOR_COUNT - 132)
// - board.js computes dynamically via `new Flash().count`

// -----------------------------------------------------------------

#define KALUMA_GPIO_COUNT 29
// #define KALUMA_ADC_NUM 3
#define KALUMA_PWM_NUM 27
#define KALUMA_I2C_NUM 2
#define KALUMA_SPI_NUM 2
#define KALUMA_UART_NUM 2
#define KALUMA_PIO_NUM 2
#define KALUMA_PIO_SM_NUM 4

#define ADC_RESOLUTION_BIT 12
#define PWM_CLK_REF 1250
#define I2C_MAX_CLOCK 1000000
#define SCR_LOAD_GPIO 22  // GPIO 22

void board_init();

#endif /* __RP2_RP2040_TOUCH_LCD_1_28_H */

