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
initLED:
  BSET    DDRJ, #2
  BCLR    PTJ,  #2
  MOVB #$FF,DDRB;
  MOVB #$00,PORTB;
  RTS;
setLED:
  STAB PORTB;
  RTS
getLED:
  LDAB PORTB;
  RTS
toggleLED:
  EORB PORTB;
  STAB PORTB;
  RTS;