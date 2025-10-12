######################################
# building variables
######################################

# debug build?
set(DEBUG 1)

# optimization
set(OPT -Og)

# default board: pico2-w
if(NOT BOARD)
  set(BOARD "pico2-w")
endif()

if(BOARD STREQUAL "pico")
  message(FATAL_ERROR "KalumaJS does not support pico board from version 1.3.0 please use 1.2.x version.")
  # set(PICO_BOARD pico)
elseif(BOARD STREQUAL "pico-w")
  message(FATAL_ERROR "KalumaJS does not support pico-w board from version 1.3.0 please use 1.2.x version.")
  # set(PICO_BOARD pico_w)
elseif(BOARD STREQUAL "pico2")
  set(PICO_BOARD pico2)
elseif(BOARD STREQUAL "pico2-w")
  set(PICO_BOARD pico2_w)
elseif(BOARD STREQUAL "kb2040")
  # Use default PICO board configuration for RP2040
  set(PICO_BOARD pico)
  # KB2040 defaults to 8MB external flash and longer XOSC startup
  add_compile_definitions(PICO_FLASH_SIZE_BYTES=8388608)
  add_compile_definitions(PICO_XOSC_STARTUP_DELAY_MULTIPLIER=64)
else()
  message(FATAL_ERROR "KalumaJS does not support this board yet.")
endif()

# default modules
if(NOT MODULES)
  set(MODULES
    events
    gpio
    led
    button
    pwm
    adc
    i2c
    spi
    uart
    graphics
    at
    storage
    wifi
    stream
    net
    http
    url
    rp2
    rtc
    path
    flash
    fs
    vfs_lfs
    vfs_fat
    sdcard
    wdt
    startup)
endif()

if(BOARD STREQUAL "pico-w")
  set(PICO_SDK_PATH ${CMAKE_SOURCE_DIR}/lib/pico-sdk-2.0.0)
else()
  set(PICO_SDK_PATH ${CMAKE_SOURCE_DIR}/lib/pico-sdk)
endif()
include(${PICO_SDK_PATH}/pico_sdk_init.cmake)

project(kaluma-project C CXX ASM)

# initialize the Pico SDK
pico_sdk_init()

# Optional vendor prefix for artifact naming; defaults to empty.
set(VENDOR_PREFIX "")
if(BOARD STREQUAL "kb2040")
  # Adafruit KB2040 artifacts: kaluma-<target>-adafruit-kb2040-<ver>.*
  set(VENDOR_PREFIX "adafruit-")
elseif(BOARD STREQUAL "rp2040-touch-lcd-1-28")
  # Waveshare RP2040-Touch-LCD-1.28 artifacts: kaluma-<target>-waveshare-rp2040-touch-lcd-1-28-<ver>.*
  set(VENDOR_PREFIX "waveshare-")
endif()

set(OUTPUT_TARGET kaluma-${TARGET}-${VENDOR_PREFIX}${BOARD}-${VER})
set(TARGET_SRC_DIR ${CMAKE_CURRENT_LIST_DIR}/src)
set(TARGET_INC_DIR ${CMAKE_CURRENT_LIST_DIR}/include)
set(BOARD_DIR ${CMAKE_CURRENT_LIST_DIR}/boards/${BOARD})

set(SOURCES
  ${SOURCES}
  ${TARGET_SRC_DIR}/adc.c
  ${TARGET_SRC_DIR}/system.c
  ${TARGET_SRC_DIR}/gpio.c
  ${TARGET_SRC_DIR}/pwm.c
  ${TARGET_SRC_DIR}/tty.c
  ${TARGET_SRC_DIR}/flash.c
  ${TARGET_SRC_DIR}/uart.c
  ${TARGET_SRC_DIR}/i2c.c
  ${TARGET_SRC_DIR}/spi.c
  ${TARGET_SRC_DIR}/rtc.c
  ${TARGET_SRC_DIR}/wdt.c
  ${TARGET_SRC_DIR}/main.c
  ${BOARD_DIR}/board.c)

include_directories(${TARGET_INC_DIR} ${BOARD_DIR})

if(BOARD STREQUAL "pico2" OR BOARD STREQUAL "pico2-w")
  # For RP2350
  set(CMAKE_SYSTEM_PROCESSOR cortex-m33)
  set(CMAKE_C_FLAGS "-march=armv8-m.main+dsp+fp -mcpu=cortex-m33 -mthumb -mfloat-abi=softfp")
  set(JERRY_TOOLCHAIN toolchain_mcu_cortexm33.cmake)
  set(TARGET_HEAPSIZE 384)
else() # pico and pico-w have the same settings
  # For RP2040
  set(CMAKE_SYSTEM_PROCESSOR cortex-m0plus)
  set(CMAKE_C_FLAGS "-march=armv6-m -mcpu=cortex-m0plus -mthumb")
  set(JERRY_TOOLCHAIN toolchain_mcu_cortexm0plus.cmake)
  set(TARGET_HEAPSIZE 180)
endif()

if(DEBUG EQUAL 1)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g -gdwarf-2")
endif()
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OPT} -Wall -fdata-sections -ffunction-sections -MMD -MP")
set(PREFIX arm-none-eabi-)
set(CMAKE_ASM_COMPILER ${PREFIX}gcc)
set(CMAKE_C_COMPILER ${PREFIX}gcc)
set(CMAKE_CXX_COMPILER ${PREFIX}g++)
set(CMAKE_LINKER ${PREFIX}ld)
set(CMAKE_OBJCOPY ${PREFIX}objcopy)

set(TARGET_LIBS c nosys m
  pico_stdlib
  pico_unique_id
  hardware_adc
  hardware_pwm
  hardware_i2c
  hardware_spi
  hardware_uart
  hardware_pio
  hardware_flash
  pico_aon_timer
  pico_rand
  hardware_watchdog
  hardware_sync)
set(CMAKE_EXE_LINKER_FLAGS "-specs=nano.specs -u _printf_float -Wl,-Map=${OUTPUT_TARGET}.map,--cref,--gc-sections")

# For the pico-w board
if(BOARD STREQUAL "pico-w" OR BOARD STREQUAL "pico2-w")
  # modules for pico-w
  set(MODULES
  ${MODULES}
  pico_cyw43)
  # libs for pico-w
  set(TARGET_LIBS
  ${TARGET_LIBS}
  pico_lwip
  pico_cyw43_arch_lwip_poll)
endif()

include(${CMAKE_SOURCE_DIR}/tools/kaluma.cmake)
add_executable(${OUTPUT_TARGET} ${SOURCES} ${JERRY_LIBS})
target_link_libraries(${OUTPUT_TARGET} ${JERRY_LIBS} ${TARGET_LIBS})
# Enable USB output, disable UART output
pico_enable_stdio_usb(${OUTPUT_TARGET} 1)
pico_enable_stdio_uart(${OUTPUT_TARGET} 0)

pico_add_extra_outputs(${OUTPUT_TARGET})

# Turn off PICO_STDIO_DEFAULT_CRLF
add_compile_definitions(PICO_STDIO_DEFAULT_CRLF=0)
add_compile_definitions(PICO_MALLOC_PANIC=0)
