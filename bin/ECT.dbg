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
    XREF TIOS,TCTL4,TIE,ICPAR,DDRT,TFLG1,TCTL1,TCTL2,TSCR1,TSCR2,TCTL3
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
    
    MOVB #$07,TSCR2;
    
    
    
    
