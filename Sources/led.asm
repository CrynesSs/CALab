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
        XDEF initLED,setLED,getLED,toggleLED
        XREF DDRB,PORTB,DDRJ,PTJ
 
.init: SECTION
;**************************************************************
; Init the LED Component
; Parameter: -
; Return:    -
initLED:
    BSET    DDRJ, #2
    BCLR    PTJ,  #2
    MOVB #$FF,DDRB;
    MOVB #$00,PORTB;
    RTS;
;**************************************************************
; Set the LED to a predefined value.
; Parameter: b - (Byte) - Putting value into PORTB
; Return:    -
setLED:
    STAB PORTB;
    RTS
;**************************************************************
; Get the current LED state
; Parameter: -
; Return:    b - (Byte) - Value of PORTB
getLED:
    LDAB PORTB;
    RTS
;**************************************************************
; Toggle specified LEDs. 1 = Toggle, 0 = NoToggle
; Parameter: b - (Byte) - The LEDs to toggle
; Return:    -
toggleLED:
    EORB PORTB;
    STAB PORTB;
    RTS;
;**************************************************************  