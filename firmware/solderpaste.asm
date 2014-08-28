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
.def	R_TMP	= R16	; temporary register
.def	R_MODE	= R18	; current mode
.def	R_CHG	= R19	; 
.def	R_DELAY = R20	; delay counter

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
		ldi		R_TMP, low(RAMEND)
		out		SPL, R_TMP

		; check the reset type
		in		R_TMP, MCUSR
		cpi		R_TMP, (1<<EXTRF)
		breq	MODE_SWITCH

		; set initial values
		ldi		R_MODE, 0
		ldi		R_CHG, 0

MODE_SWITCH:
		; switch current mode
		eor		R_MODE, R_CHG
		ldi		R_CHG, 0

		; clear MCUSR register after Reset
		ldi		R_TMP, 0
		out		MCUSR, R_TMP

		; setup interrupt
		ldi		R_TMP, (1<<PCIE)	; enable Pin Change interrupt
		out		GIMSK, R_TMP
		ldi		R_TMP, (1<<PCINT4)	; on PB4
		out		PCMSK, R_TMP

		// enable interrupt on any change and activate pullups
		ldi		R_TMP, (1<<ISC00) | (1<<PUD)
		out		MCUCR, R_TMP

		; setup port
		ldi		R_TMP, (1<<DDB3)|(1<<DDB2)|(1<<DDB1)|(1<<DDB0)
		out		DDRB, R_TMP

		sbi		PORTB, PORTB4	; enable pullup on PB4

		sei				; global interrupt enable
; Main Loop
MAIN:
		nop
		;sleep
		rjmp	MAIN
		

; Button handler
PC_INTO0:
		reti

		.exit
