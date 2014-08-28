;
; This code is based on:
; * https://github.com/DeadBugPrototypes/SolderPaste14M2/
; * http://habrahabr.ru/post/110894/
;

.include "tn13def.inc"

; Port usage
; PB0-3 - output for stepper motor
; PB4   - control button
; PB5   - mode button

; Set FUSES: CKSEL1=0, CKSEL0=1 (4800KhZ system clock)

; Register defines:
.def	TMP		= R21
.def	SHIFT	= R16
.def	MASK	= R17
.def	MODE	= R18	; current mode
.def	CHG		= R19	; 
.def	DELAY 	= R20	; delay counter

		.CSEG
		.org	0x0000

		rjmp	RESET
		rjmp	EXT_INT0	; IRQ0 Handler
		rjmp	PC_INTO0	; Pin Change Interrupt Handler
		rjmp	TIM0_OVF	; Timer0 Overflow Handler
		rjmp	EE_RDY		; EEPROM Ready Handler
		rjmp	ANA_COMP	; Analog Comparator Handler
		rjmp	TIM0_COMPA	; Timer0 CompareA Handler
		rjmp	TIM0_COMPB	; Timer0 CompareB Handler
		rjmp	WDT_OVF		; Watchdog Timer Overflow Handler
		rjmp	ADC_RDY		; ADC Conversion Complete Interrupt Handler

; Unused vectors are simple return to program

		.org	0x000A
EXT_INT0:
TIM0_OVF:
EE_RDY:
ANA_COMP:
TIM0_COMPA:
TIM0_COMPB:
WDT_OVF:
ADC_RDY:
		reti

; MCU initialization and main loop

RESET:
		; stack init
		ldi		TMP, low(RAMEND)
		out		SPL, TMP

		; check the reset type
		in		TMP, MCUSR
		cpi		TMP, (1<<EXTRF)
		breq	MODE_SWITCH

		; set initial TMPues
		ldi		SHIFT, 0b00110011		; shift TMPue
		ldi		MASK, 0b00001111		; shift mask
		ldi		MODE, 1					; current mode
		ldi		CHG, 1					; switcher

MODE_SWITCH:
		; switch current mode
		eor		MODE, CHG			; 0 x 1 => 1, 1 x 1 => 0


		; clear MCUSR register after Reset
		ldi		TMP, 0
		out		MCUSR, TMP

		; setup interrupt
		ldi		TMP, (1<<PCIE)			; enable Pin Change interrupt
		out		GIMSK, TMP
		ldi		TMP, (1<<PCINT4)		; on PB4
		out		PCMSK, TMP

		; setup port
		ldi		TMP, (1<<DDB3)|(1<<DDB2)|(1<<DDB1)|(1<<DDB0)
		out		DDRB, TMP

		sbi		PORTB, PORTB4		; enable pullup on PB4

		; enable interrupt on any change and activate pullups
		ldi		TMP, (1<<ISC00) | (1<<PUD)
		out		MCUCR, TMP

		sei							; global interrupt enable

; Main Loop
MAIN:
		nop
		;sleep
		rjmp	MAIN
		

; Button handler
PC_INTO0:
		push	TMP

		cp		TMP, CHG
		breq	REVERSE

		rol		SHIFT
		rjmp	ROTATE

REVERSE:
		ror		SHIFT

ROTATE:
		mov		TMP, SHIFT
		and		TMP, MASK
		out     PORTB, TMP

		pop		TMP
		reti

		.exit
