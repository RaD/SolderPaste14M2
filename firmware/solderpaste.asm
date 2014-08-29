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
.def    STATE   = R18   ; status
.def	DELAY 	= R19	; delay counter
.def    CHANGE  = R20   ; used for EOR

.equ    MOTOR_BIT = 0 ; if set, motor is running
.equ    DIR_BIT   = 1 ; if set, rotating left


;;; Write to port macro.
.macro outm
        ldi     TMP, @1
        out     @0, TMP
.endm

;;; Rotate left macro
.macro rolm
        bst     @0, 7
        rol     @0
        bld     @0, 0
.endm

;;; Rotate right macro
.macro rorm
        bst     @0, 0
        ror     @0
        bld     @0, 7
.endm


.cseg
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

;;; Pin Change Interrupt Handler
;;; It just changes the MOTOR_BIT in status register.
PC_INTO0:
		push	TMP

        sbr     STATE, (1<<MOTOR_BIT)   ; guess button is pressed
        sbic    PINB, 4                 ; check button state, if pressed
                                        ; skip the next command
        cbr     STATE, (1<<MOTOR_BIT)   ; button isn't pressed

        ; finish interrupt
        outm    GIFR, (1<<PCIF)


		pop		TMP

        ; dirty hack :)
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
        outm    SPL, low(RAMEND)


		; check the reset type
		in		TMP, MCUSR
		cpi		TMP, (1<<EXTRF)
		breq	MODE_SWITCH

		; set initial values
		ldi		SHIFT, 0b00110011   ; shift value
		ldi		MASK, 0b00001111    ; shift mask
        ldi     DELAY, 0xFF
        ldi     STATE, (1<<DIR_BIT) ; initial
        mov     CHANGE, STATE       ; register is needed for EOR


MODE_SWITCH:
		; switch current mode
        ; 0 x 1 => 1, 1 x 1 => 0
		eor		STATE, CHANGE

		; clear MCUSR register after Reset
		outm	MCUSR, 0

		; setup interrupt
		outm	GIMSK, (1<<PCIE)	; enable Pin Change interrupt
		outm	PCMSK, (1<<PCINT4)	; on PB4


		; setup port
		outm    DDRB, (1<<DDB3)|(1<<DDB2)|(1<<DDB1)|(1<<DDB0)


		sbi		PORTB, PORTB4		; enable pullup on PB4

		; enable interrupt on any change and activate pullups
		outm    MCUCR, (1<<ISC00) | (1<<PUD)

		sei							; global interrupt enable

;;; Main Loop
;;;
MAIN:
        sbrc    STATE, MOTOR_BIT    ; skip if bit cleared
        rcall   ROTATION
		;sleep
        rcall   DELAYING
		rjmp	MAIN


;;; Delays execution
;;;
DELAYING:
        push    TMP
        mov     TMP, DELAY
DELAY_LOOP:
        dec     TMP
        nop
        brne    DELAY_LOOP
        pop     TMP
        ret


;;; Function checks the direction and rotate motor by one
;;; step in particular direction.
ROTATION:
        sbrc    STATE, DIR_BIT  ; skip if bit cleared
        rjmp    MOVE_RIGHT

        rolm    SHIFT
		rjmp	ROTATE

MOVE_RIGHT:
        rorm    SHIFT

ROTATE:
		mov		TMP, SHIFT
		and		TMP, MASK
		out     PORTB, TMP
        ret

.exit
