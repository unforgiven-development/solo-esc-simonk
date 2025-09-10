;***********************************************************
;* JMT 30A ESC (2S-4S with 5V3A BEC)                       *
;* 2025-09-07                                              *
;***********************************************************

.equ	F_CPU		= 16000000
.equ	USE_INT0	= 1
.equ	USE_I2C		= 0
.equ	USE_UART	= 0
.equ	USE_ICP		= 0


;*********************
; PORT D definitions *
;*********************

;.equ	red_led		= 7
;.equ	blue_led	= 5
.equ	BnFET		= 4
.equ	AnFET		= 3
.equ	rcp_in		= 2	;32 i r/c pulse input
.equ	txd			= 1
.equ	rxd			= 0

.equ	INIT_PD		= (1 << ApFET)
.equ	DIR_PD		= ((1 << ApFET) | (1 << io1) | (1 << io2) | (1 << red_led))

.equ	AnFET_port	= PORTD
.equ	BnFET_port	= PORTD

;*********************
; PORT C definitions *
;*********************
.equ	mux_b		= 7	; ADC7
.equ	mux_a		= 6	; ADC6
.equ	BpFET		= 5	; ADC5/SCL
.equ	AnFET		= 4	; ADC4/SDA
;.equ			= 3	; ADC3
;.equ			= 2	; ADC2
;.equ			= 1	; ADC1 phase input
;.equ	mux_c		= 0	; ADC0 phase input
.equ	mux_voltage	= 0	; ADC0 voltage input (47k from Vbat, 4.3k to gnd, 10.10V -> 0.847V at ADC0)

.equ	O_POWER		= 470
.equ	O_GROUND	= 43

.equ	INIT_PC		= (1<<BpFET)
.equ	DIR_PC		= (1<<AnFET)+(1<<BpFET)

.equ	BpFET_port	= PORTC
.equ	AnFET_port	= PORTC


;*********************
; PORT B definitions *
;*********************

;	.equ				= 5	(sck)
;	.equ				= 4	(miso)
	.equ	AnFET		= 3					; o (mosi)
	.equ	BnFET		= 2					; o
	.equ	CnFET		= 1					; o
;	.equ	rcp_in		= 0					; i r/c pulse input

	.equ	INIT_PB		= 0
	.equ	DIR_PB		= (1 << AnFET) | (1 << BnFET) | (1 << CnFET)

	.equ	AnFET_port	= PORTB
	.equ	BnFET_port	= PORTB
	.equ	CnFET_port	= PORTB

