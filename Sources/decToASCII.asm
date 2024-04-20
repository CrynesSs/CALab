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
      XDEF decToASCII;

; Defines

; RAM: Variable data section
.data: SECTION
; ROM: Constant data
.const: SECTION
; ROM: Code section
.init: SECTION
 
  decToASCII:
    ;Remainder can stay in D for the whole operation, as the remainder is what needs to be devided next anyway.
    ;So for example 23789 in D:
    ;IDIV with 10000 in X leads to :
    ;X = 2
    ;D = 3789
    ;So we can STX and continue with D
    MOVB #$2B,X; 
    CMPA #$0;
    BLT flipSign;
 startConversion:
    ;Swap X to Y so IDIV can work as expected
    TFR X,Y;
    
    ;Increase Y to point to correct location
    INY;
    LDX #10000; 
    IDIV;
    ;Swap Register X and D
    XGDX;
    ;Convert to the numerical Ascii character
    ADDB #$30;
    ;Save the Ascii Char to
    STAB Y;
    ;Swap Back
    XGDX;
    
    
    ;Increase Y to point to correct location
    INY;
    LDX #1000; 
    IDIV;
    ;Swap Register X and D
    XGDX;
    ;Convert to the numerical Ascii character
    ADDB #$30;
    ;Save the Ascii Char to
    STAB Y;
    ;Swap Back
    XGDX;
    
    
    
    ;Increase Y to point to correct location
    INY;
    LDX #100; 
    IDIV;
    ;Swap Register X and D
    XGDX;
    ;Convert to the numerical Ascii character
    ADDB #$30;
    ;Save the Ascii Char to
    STAB Y;
    ;Swap Back
    XGDX;
    
    ;Increase Y to point to correct location
    INY;
    LDX #10; 
    IDIV;
    ;Swap Register X and D
    XGDX;
    ;Convert to the numerical Ascii character
    ADDB #$30;
    ;Save the Ascii Char to
    STAB Y;
    ;Swap Back
    XGDX;
    
    INY;
    ADDB #$30;
    STAB Y;
    
    INY;
    MOVB #$0,Y;
    
    RTS
  
  
    
  
  
  flipSign:
    EORA #$FF
    EORB #$FF
    ADDD #1;
    ;Move Minus Sign to start of String
    MOVB #$2D,X;
    BRA startConversion;
    


  
  