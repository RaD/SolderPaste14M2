# SPIEN, CKSEL1, SELFPRGEN
sudo avrdude -p attiny13 -c avrispmkII \
    -U lfuse:w:0x61:m -U hfuse:w:0xff:m \
    -U flash:w:solderpaste.hex
