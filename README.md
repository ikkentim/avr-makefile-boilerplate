AVR template with Makefile
==========================

A Makefile I use for tinkering with AVR microcontrollers.

```
# make blink binaries
$ make blink
> avr-gcc blink.c -std=gnu99 -c -g -Os -Wall -Wextra -MMD -mmcu=attiny85 -DF_CPU=16000000 -fno-exceptions -ffunction-sections -fdata-sections -fdiagnostics-color=auto -I~/Library/Arduino15/packages/attiny/hardware/avr/1.0.2/variants/tiny8 -c -o bin/attiny85/blink.o
> avr-gcc bin/attiny85/blink.o -mmcu=attiny85 -fdiagnostics-color=auto -Wl,-static -Wl,--gc- -finline-functions -o bin/blink.elf
> avr-objcopy -O ihex -R .eeprom bin/blink.elf bin/blink.hex

# show size of blink binaries
$ make blink-size
>   text	   data	    bss	    dec	    hex	filename
>     98	      0	      0	     98	     62	./bin/blink.elf

# upload blink to microcontroller
make blink-isp
> avrdude -C "/Applications/Arduino.app/Contents/Java/hardware/tools/avr//etc/avrdude.conf" -P /dev/tty.usbmodem11201 -p t85 -c stk500v1 -b 19200  -U flash:w:./bin/blink.hex:i
>
> avrdude: AVR device initialized and ready to accept instructions
>
> Reading | ################################################## | 100% 0.02s
>
> avrdude: Device signature = 0x1e930b (probably t85)
> avrdude: NOTE: "flash" memory has been specified, an erase cycle will be performed
>          To disable this feature, specify the -D option.
> avrdude: erasing chip
> avrdude: reading input file "./bin/blink.hex"
> avrdude: writing flash (98 bytes):
>
> Writing | ################################################## | 100% 0.18s
>
> avrdude: 98 bytes of flash written
> avrdude: verifying flash memory against ./bin/blink.hex:
> avrdude: load data flash data from input file ./bin/blink.hex:
> avrdude: input file ./bin/blink.hex contains 98 bytes
> avrdude: reading on-chip flash data:
>
> Reading | ################################################## | 100% 0.09s
>
> avrdude: verifying ...
> avrdude: 98 bytes of flash verified
>
> avrdude: safemode: Fuses OK (E:FF, H:DF, L:F1)
>
> avrdude done.  Thank you.
```
