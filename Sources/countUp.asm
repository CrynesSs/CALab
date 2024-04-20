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
        XDEF COUNT_UP_BY_2
        XREF PORTB,PIFP,COUNT 
        
; RAM: Variable data section
.data: SECTION
 
 
.init: SECTION
  RESET:  
        MOVB #$00,COUNT
        LDAA COUNT                       ; Reset counter to 0
        STAA PORTB                      ;
        BRA outputLED;         ; Wait for half a Second         
        

  COUNT_UP_BY_2:
        MOVB #$02,PIFP;Reset Interrupt Flag
        LDAA COUNT;                     ;
        ADDA #$02                       ; Increment by 2
        CMPA #$3F                       ; Compare with 63 
        BHS RESET                       ; If greater or equal 63 -> Roll Over (we can never hit 63 so it does not matter if greater | greater/equal)  
    outputLED:                          ;
        STAA COUNT                      ; Store incremented low byte back to counter 
        STAA PORTB                      ; 
        RTI        