/* Copyright (c) 2017 Kaluma
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#ifndef __RP2_PICO2_W_H
#define __RP2_PICO2_W_H

#include "jerryscript.h"

// system
#define KALUMA_SYSTEM_ARCH "cortex-m33"
#define KALUMA_SYSTEM_PLATFORM "rp2"
#define PICO_CYW43

// repl
#define KALUMA_REPL_BUFFER_SIZE 1024
#define KALUMA_REPL_HISTORY_SIZE 10

// Flash allocation map 4MB for pico 2W
//
// |------------------------------------------------|
// |      A         | B |     C     |       D       |
// |----------------|---|-----------|---------------|
// |      1024K     |64K|  1472K    |     1536K     |
// |------------------------------------------------|
//                  |----------- flash.c -----------|

// |------ 1MB -----|------------- 3MB -------------|
// |---------------------- 4MB ---------------------|
//
// - A : binary (firmware)
// - B : storage (key-value database)
// - C : user program (js)
// - D : file system (lfs)
// (Total : 4MB)

// binary (1024K)
#define KALUMA_BINARY_MAX 0x100000

// flash (B + C + D = 3072KB (=64KB + 1472KB + 1536KB))
#define KALUMA_FLASH_OFFSET KALUMA_BINARY_MAX
#define KALUMA_FLASH_SECTOR_SIZE 4096
#define KALUMA_FLASH_SECTOR_COUNT 768
#define KALUMA_FLASH_PAGE_SIZE 256

// user program on flash (1472KB)
#define KALUMA_PROG_SECTOR_BASE 16
#define KALUMA_PROG_SECTOR_COUNT 368

// storage on flash (64KB)
#define KALUMA_STORAGE_SECTOR_BASE 0
#define KALUMA_STORAGE_SECTOR_COUNT 16

// file system on flash (1024K)
// - sector base : 400
// - sector count : 384
// - use block device : new Flash(400, 384)

// -----------------------------------------------------------------

#define KALUMA_GPIO_COUNT 29
// #define KALUMA_ADC_NUM 3
#define KALUMA_PWM_NUM 27
#define KALUMA_I2C_NUM 2
#define KALUMA_SPI_NUM 2
#define KALUMA_UART_NUM 2
// #define KALUMA_LED_NUM 1
// #define KALUMA_BUTTON_NUM 0
#define KALUMA_PIO_NUM 2
#define KALUMA_PIO_SM_NUM 4

#define ADC_RESOLUTION_BIT 12
#define PWM_CLK_REF 1250
#define I2C_MAX_CLOCK 1000000
#define SCR_LOAD_GPIO 22  // GPIO 22
#ifdef PICO_CYW43
#define WIFI_EN_GPIO 23  // GPIO 23
#endif                   /* PICO_CWY43 */
void board_init();

#endif /* __RP2_PICO2_W_H */