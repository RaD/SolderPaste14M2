sudo avrdude -p attiny13 -c avrispmkII \
    -U lfuse:w:0x6a:m -U hfuse:w:0xff:m \
    -U flash:w:motor.hex
