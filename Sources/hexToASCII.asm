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
      XDEF hexToASCII;

; Defines

; RAM: Variable data section
.data: SECTION
WORD: DC.W 1 
; ROM: Constant data
.const: SECTION
H2A: DC.B "0123456789ABCDEF"
; ROM: Code section
.init: SECTION
;**************************************************************
; Convert Hexdacimal Number to ASCII Character Representation
; Parameter: 
;     d - (Word) - The hexadmical number to convert
;     x - (Word) - Address of the copy destination
hexToASCII:
   STD WORD;
   ; 0x in the first 2 characters of the Result String
   MOVW #$3078,0,X;
   MOVB #0,6,X;
  ;Ersten 2 Buchstaben
  ;Isolate first Byte of A
  ANDA #$0F;
  ;Isolate first Byte of B
  ANDB #$0F;
  ;Load Table Pointer to Y 
  LDY #H2A
  ;Add B to Y, so it points to the correct element in the table
  ABY;
  ;Move the Byte from Y to the correct Position in X
  MOVB Y,5,X;
  ;Load Table Pointer to Y 
  LDY #H2A
  ;Transfer A to B
  TAB;
  ;Add B to Y, so it points to the correct element in the table
  ABY;
  ;Move the Byte from Y to the correct Position in X
  MOVB Y,3,X;
  ;Zweiten 2 Buchstaben
  LDD WORD;
  ;Bitshift word 4 to the right so now the other 2 bytes that are not yet done are read
  LSRD
  LSRD
  LSRD
  LSRD
  ;Isolate first Byte of A
  ANDA #$0F;
  ;Isolate first Byte of B
  ANDB #$0F;
  ;Load Table Pointer to Y
  LDY #H2A
  ;Add B to Y, so it points to the correct element in the table
  ABY;
  ;Move the Byte from Y to the correct Position in X
  MOVB Y,4,X;
  ;Load Table Pointer to Y
  LDY #H2A
  ;Transfer A to B
  TAB;
  ;Add B to Y, so it points to the correct element in the table
  ABY;
  ;Move the Byte from Y to the correct Position in X
  MOVB Y,2,X;
  RTS

  
  
  
  
  


  
  