all: blink

###########################################
# AVR toolchain detection
###########################################

# Use Arduino toolchain if available
ifeq ($(shell uname), Darwin)
ARDUINO_DIR = /Applications/Arduino.app/Contents/Java/
endif

ifneq "$(wildcard $(ARDUINO_DIR) )" ""
AVR_DIR 	= $(ARDUINO_DIR)hardware/tools/avr/
AVR_BIN 	= $(AVR_DIR)bin/
endif

ifneq "$(wildcard $(AVR_DIR) )" ""
AVRDUDE_ARGS = -C "$(AVR_DIR)/etc/avrdude.conf"
endif

AVR_CC 		= $(AVR_BIN)avr-gcc
AVR_OBJCOPY = $(AVR_BIN)avr-objcopy
AVR_OBJDUMP = $(AVR_BIN)avr-objdump
AVR_SIZE 	= $(AVR_BIN)avr-size
AVRDUDE 	= $(AVR_BIN)avrdude

###########################################
# Default ISP options
###########################################

ISP_SPEED 	= 115200
ISP_PORT 	= $(word 1, $(shell ls /dev/tty.usbmodem*))
ISP_MCU 	= $(subst atmega,m,$(subst attiny,t,$(MCU)))
ISP_TOOL 	= arduinog

AVRDUDE_ARGS = $(AVRDUDE_ARGS) -P $(ISP_PORT) -p $(ISP_MCU) -c $(ISP_TOOL) -b $(ISP_SPEED)

###########################################
# Functions
###########################################

# Replace .c extensions to .o in $(2) and prefix the results by $(1)
TO_OBJECTS = $(addprefix $(1), $(patsubst %.c,%.o,$(2)))

###########################################
# Build configuration
###########################################

SRC			= ./
BIN			= ./bin/
OBJ         = $(BIN)$(MCU)/

CC			= $(AVR_CC)
INCLUDES	= -I "$(AVR_DIR)avr/$(MCU)/include"
CFLAGS	 	= -std=gnu99 -c -g -Os -Wall -Wextra -MMD -mmcu=$(MCU) -DF_CPU=$(F_CPU) -fno-exceptions -ffunction-sections -fdata-sections -fdiagnostics-color=auto $(INCLUDES)
LDFLAGS 	= -mmcu=$(MCU) -fdiagnostics-color=auto -Wl,-static -Wl,--gc- -finline-functions

MCU			= atmega328p
F_CPU		= 16000000

SRC_FILES_BLINK 	= blink.c

OBJECTS_BLINK       = $(call TO_OBJECTS, $(BIN)attiny85/, $(SRC_FILES_BLINK))

blink: MCU			= attiny85
blink: F_CPU		= 1000000
blink: INCLUDES	= -I~/Library/Arduino15/packages/attiny/hardware/avr/1.0.2/variants/tiny8
blink: OBJECTS 	= $(OBJECTS_BLINK)

blink: $(OBJECTS_BLINK) $(BIN)blink.hex

blink-isp: ISP_SPEED 	= 19200
blink-isp: ISP_TOOL 	= arduino
blink-isp: MCU			= attiny85
blink-isp: avr-upload-blink

blink-size: MCU		= attiny85
blink-size: avr-size-blink

.PHONY: blink blink-isp blink-size
.PRECIOUS: $(BIN)%.elf

###########################################
# Build rules
###########################################

$(BIN)atmega328p/%.o: %.c
	@mkdir -p $(shell dirname $@)
	$(CC) $< $(CFLAGS) -c -o $@

$(BIN)attiny85/%.o: %.c
	@mkdir -p $(shell dirname $@)
	$(CC) $< $(CFLAGS) -c -o $@

$(BIN)%.elf:
	@mkdir -p $(shell dirname $@)
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@

$(BIN)%.hex: $(BIN)%.elf
	@mkdir -p $(shell dirname $@)
	$(AVR_OBJCOPY) -O ihex -R .eeprom $< $@

$(BIN)%.eep: $(BIN)%.elf
	@mkdir -p $(shell dirname $@)
	$(AVR_OBJCOPY) -O ihex -j .eeprom --set-section-flags=.eeprom=alloc,load --no-change-warnings --change-section-lma .eeprom=0 $< $@

$(BIN)%.dump: $(BIN)%.hex
	$(AVR_OBJDUMP) -m avr -D $< > $@

###########################################
# AVR tool targets
###########################################

avr-upload-%:
	$(AVRDUDE) $(AVRDUDE_ARGS) $(ISP_FUSES) -U flash:w:$(BIN)$*.hex:i

avr-size-%:
	$(AVR_SIZE) --mcu=$(MCU) $(BIN)$*.elf

###########################################
# Housekeeping
###########################################

clean:
	rm -rf $(BIN)

# include deps lists build with gcc -MMD flag
ifneq "$(wildcard $(BIN) )" ""
-include $(shell find $(BIN) -name "*.d")
endif
