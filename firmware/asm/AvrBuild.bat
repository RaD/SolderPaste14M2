@ECHO OFF
"C:\Program Files\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "C:\Projects\solderpaste\labels.tmp" -fI -W+ie -o "C:\Projects\solderpaste\solderpaste.hex" -d "C:\Projects\solderpaste\solderpaste.obj" -e "C:\Projects\solderpaste\solderpaste.eep" -m "C:\Projects\solderpaste\solderpaste.map" -O3 "C:\Projects\solderpaste\solderpaste.asm"
