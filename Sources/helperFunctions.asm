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
   XREF OUTPUTSTRING,writeLine,temp;
   XDEF displayTemperatureAndTime,LINE_BUFFER;
; export symbols
.data: SECTION
 LINE_BUFFER: DS.B 17
 SECOND_STRING_ADR: DC.W 1
 DUMMY_TEMP: DS.B 5 
.init: SECTION
  ;Left Bounded String in X, Right Bounded String in Y. Total Length of String 17;
  ;If Overlap of String, Right Bounded takes precedence
  ;Both strings need to be #$00 Terminated and not longer than 16Chars + End Char.
  concat2StringsString1LeftBoundedString2RightBoundedForNiceDisplayIGuess:
    STY SECOND_STRING_ADR;
    LDAB #15;
    copySpaces:
     CMPB #0;
     BLT start;
     LDY #LINE_BUFFER;
     ABY
     MOVB #$20,Y;
     DECB;
     BRA copySpaces;
    start:
    LDY #LINE_BUFFER
    ;X = Address of First String;
    ;Y = Address of LINE_BUFFER;
    moveFirstString:
    LDAB X;
    CMPB #0;
    BEQ startSecondString;
    MOVB X,Y;
    INX;
    INY;
    BRA moveFirstString;
    startSecondString:
    LDX SECOND_STRING_ADR;
    findEnd:
    LDAB X;
    CMPB #0;
    BEQ copySecondString;
    INX;
    BRA findEnd;
    copySecondString:
    LDY #LINE_BUFFER;
    LDAB #16
    ABY;
    cpyLoop:
    MOVB X,Y; 
    CPX SECOND_STRING_ADR;
    BEQ finish;
    DEX;
    DEY;
    BRA cpyLoop;
    finish:
    RTS;
  displayTemperatureAndTime:
    LDX #OUTPUTSTRING;
    ;LDY #TEMPERATUREOUTPUT; TODO
    ;MOVB #$32,DUMMY_TEMP;
    ;MOVB #$35,DUMMY_TEMP+1;
    ;MOVB #$6F,DUMMY_TEMP+2
    ;MOVB #$43,DUMMY_TEMP+3;
    ;MOVB #$00,DUMMY_TEMP+4;
    ;LDY #DUMMY_TEMP
    LDY #temp
    JSR concat2StringsString1LeftBoundedString2RightBoundedForNiceDisplayIGuess;
    LDAB #1;
    LDX #LINE_BUFFER;
    JSR writeLine;
    RTS;
    
    
    
     
    
    
    
    
    
    
    
    
      
    
    
    