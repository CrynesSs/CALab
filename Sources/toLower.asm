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
        XDEF toLower, strCpy

; Defines

; RAM: Variable data section
.data: SECTION
  Address: DC.W 1
  

; ROM: Constant data
.const: SECTION

; ROM: Code section
.init: SECTION
  
  toLower: 
    STD Address;
    LDX Address;
    LDAB #$20;
    DEX;
  
  loop:
    INX;
    LDAA 0,X;
    CMPA #0
    BEQ RETURN;
    CMPA #'A'
    BLO loop;
    CMPA #'Z'
    BHI loop;
    BRA makeLowerCase;
       
  makeLowerCase:
    ABA;
    STAA 0,X;
    BRA loop;
        
  strCpy:
    LDAA X
    STAA Y
    CMPA #0
    BEQ RETURN;
    INX;
    INY;
    BRA strCpy;
    
  RETURN:
    RTS    
  