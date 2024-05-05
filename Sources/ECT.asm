;   Labor 1 - Vorbereitungsaufgabe 2.4
;   Convert a zero-terminated ASCIIZ string to lower characters
;   Main program
;
;   Computerarchitektur
;   (C) 2019-2022 J. Friedrich, W. Zimmermann, R. Keller
;   Hochschule Esslingen
;
;   Author:   R. Keller, Jul 4, 2019
;            (based on code provided by J. Friedrich, W. Zimmermann)
;   Modified: -
;

; export symbols
    XDEF setupTimer
    XREF TIOS,TCTL4,TIE,ICPAR,DDRT,TFLG1,TCTL1,TCTL2,TSCR1,TSCR2,TCTL3,MCCTL,MCCNT
; RAM: Variable data section
.data: SECTION
; ROM: Constant data
.const: SECTION
 
.init: SECTION
  setupTimer:
    ;Dont let Timer cause Interrupt
    MOVB #$00,TIE
    MOVB #$01,TIOS
    MOVB #$80,TSCR1
    ;Disconnect Timer from Output Pin
    MOVB #$00,TCTL1
    MOVB #$00,TCTL2
    ;Disable Input Capture
    MOVB #$00,TCTL3
    MOVB #$00,TCTL4
    ;128 Prescaler of Timer
    MOVB #$07,TSCR2;
    ;Init the Modulo down counter with 16 bit prescaler enabled for the 5ms polling.
    ;MOVB #$A7,MCCTL;
    ;Set the Modulo count down timer to 7500 with 16 bit prescale this gives 120.000cycles or 5ms
    ;MOVW #$1D4C,MCCNT
    RTS;
    
    
    
    
