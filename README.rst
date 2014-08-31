This is a clone of `Solder Paste Controller`__ project from Dead Bug Prototypes.

__ https://www.tindie.com/products/Dead_Bug_Prototypes/solder-paste-controller/


The main differences are:

- Usage ATtiny13 as a MCU.
- Firmware is written with assembler language.

Flashing:

    sudo \
    avrdude -p attiny13 \
            -c usbasp \
            -P usb
            -U lfuse:w:0x6A:m -U hfuse:w:0xFF:m
            -U flash:w:solderpaste.hex

Fuse online editor: http://www.engbedded.com/fusecalc/
