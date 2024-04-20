;   Labor 1 - Problem 2.4
;   Convert a zero-terminated ASCIIZ string to lower characters
;   Subroutine toLower
;
;   Computerarchitektur
;   (C) 2019-2022 J. Friedrich, W. Zimmermann, R. Keller
;   Hochschule Esslingen
;
;   Author:   R. Keller, HS-Esslingen
;            (based on code provided by J. Friedrich, W. Zimmermann)
;   Modified: -
;

; export symbols
  XDEF setupPorts;
  XREF DDRB,DDRJ,PTJ;
; Defines

; RAM: Variable data section
.data: SECTION
  
 
; ROM: Constant data
.const: SECTION

; ROM: Code section
.init: SECTION
  

  setupPorts:
  BSET DDRB, #$FF                 ; Make the Port B an Output Port for LED;
  BSET DDRJ, #2  
  BSET PTJ,#2
  
  RTS
 
  
  
  
  