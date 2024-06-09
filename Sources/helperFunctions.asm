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
   XREF OUTPUTSTRING,writeLine,temp,DATE_STRING,PTH,DAY_STRING,MINUTES,HOURS,VALID_DAYS,VALID_YEAR,VALID_MONTH,SECONDS,DAY_OF_WEEK;
   XREF decToASCII,chooseFormat,Hour12Format
   XDEF displayTemperatureAndTime,LINE_BUFFER,displayTimeAndDate,AMERICAN;
; export symbols
.data: SECTION
 LINE_BUFFER: DS.B 17
 SECOND_STRING_ADR: DC.W 1
 TIME_ZONE: DS.B 4
 DUMMY_TEMP: DS.B 5
 ASCIIBuffer: DS.B 8
 AMERICAN: DC.B 1
 AMERICAN_H: DC.B 1
 AMERICAN_D: DC.B 1
 AMERICAN_M: DC.B 1
 AMERICAN_Y: DC.B 1
 AMERICAN_DAY_OF_WEEK: DC.B 1
  
.const: SECTION
N2DE: DC.B "MONTUEWEDTHUFRISATSUN"
N2DD: DC.B "MODIMIDOFRSASO"     
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
    
  displayTimeAndDate:
  LDAB PTH;
  ANDB #$04;
  CMPB #$00;
  BEQ displayAmericanJ;
  ;DE
  MOVW #$4445,TIME_ZONE;
  MOVW #$3A00,TIME_ZONE+2;
  LDAB #$00;
  STAB Hour12Format;
  JSR chooseFormat;
  LDX #ASCIIBuffer;
  LDAB VALID_DAYS;
  JSR decToASCII;
  MOVW ASCIIBuffer+4,DATE_STRING;
    
  MOVB #$3A,DATE_STRING+2;
    
  LDX #ASCIIBuffer;
  LDAB VALID_MONTH;
  JSR decToASCII;
  MOVW ASCIIBuffer+4,DATE_STRING+3;
    
    MOVB #$3A,DATE_STRING+5;
    
    MOVW #$3230,DATE_STRING+6;
    
    LDX #ASCIIBuffer;
    LDAB VALID_YEAR;  
    JSR decToASCII;
    MOVW ASCIIBuffer+4,DATE_STRING+8;
    MOVB #$00,DATE_STRING+10
  LDAA #$00;
  LDAB DAY_OF_WEEK;
  LDY #DAY_STRING;
    LDX #N2DD;
    DECB;
    LSLB;
    ABX;
    MOVW X,Y;
    INY;
    INY;
    MOVB #$3A,Y;
    INY;
    MOVB #$00,Y;
  BRA displayString
  displayAmericanJ:
  BRA displayAmerican;
    
  displayString:
  LDX #DAY_STRING;
  LDY #DATE_STRING;
  JSR concat2StringsString1LeftBoundedString2RightBoundedForNiceDisplayIGuess;
  LDAB #0;
  LDX #LINE_BUFFER;
  JSR writeLine;
  
  
  LDX #TIME_ZONE;
  LDY #OUTPUTSTRING;
  JSR concat2StringsString1LeftBoundedString2RightBoundedForNiceDisplayIGuess;
  LDAB #1;
  LDX #LINE_BUFFER
  JSR writeLine;
  
  RTS
  
  
  
  displayAmerican:
  ;US
  MOVW #$5553,TIME_ZONE;
  MOVW #$3A00,TIME_ZONE+2;
  MOVB HOURS,AMERICAN_H;
  MOVB VALID_DAYS,AMERICAN_D;
  MOVB VALID_MONTH,AMERICAN_M;
  MOVB VALID_YEAR,AMERICAN_Y;
  MOVB DAY_OF_WEEK,AMERICAN_DAY_OF_WEEK
  LDAB HOURS;
  CMPB #6;
  BHI continueAmericanJ;
  ;Day Rollover
  LDAB DAY_OF_WEEK;
  DECB;
  STAB AMERICAN_DAY_OF_WEEK;
  CMPB #0;
  BNE continue123;
  LDAB #7
  STAB AMERICAN_DAY_OF_WEEK
  
  continue123:
  LDAA #24;
    SUBA HOURS;
    TAB;
    ANDA #$00;
    STAB AMERICAN_H;
    LDAB VALID_DAYS;
    CMPB #1;
    BHI continueAmericanJ;
    ;Decrement Month
    LDAB VALID_MONTH;
    CMPB #1;
    BHI noYearRollover;
    ;Here we need to rollOver the Year
    LDAB VALID_YEAR;
    DECB;
    STAB AMERICAN_Y;
    LDAB #12;
    STAB AMERICAN_M;
    LDAB #31;
    STAB AMERICAN_D;
    BRA continueAmerican;
     noYearRollover:
    LDAB VALID_MONTH;
    DECB;
    CMPB #11;
    BEQ day31Month;
    CMPB #9;
    BEQ day31Month;
    CMPB #7;
    BEQ day31Month;
    CMPB #5;
    BEQ day31Month;
    CMPB #3;
    BEQ day31Month;
    CMPB #1;
    BEQ day31Month;
    CMPB #10;
    BEQ day30Month;
    CMPB #8;
    BEQ day30Month;
    CMPB #6;
    BEQ day30Month;
    CMPB #4;
    BEQ day30Month;
    CMPB #2;
    BEQ february;
    
    continueAmericanJ:
    BRA continueAmerican;
    
    
    day31Month:
    LDAB #31;
    STAB AMERICAN_D;
    JSR continueAmerican;
    RTS;
    day30Month:
    LDAB #30;
    STAB AMERICAN_D;
    JSR continueAmerican;
    RTS
    ;Feburary is special
    february:
    LDD #2000;
    ADDD AMERICAN_Y;
    LDX #4;
    IDIV;
    CPD #0;
    ;No remainder means we have a Schaltjahr
    BEQ schaltjahr;
    LDAB #28;
    STAB AMERICAN_D;
    JSR continueAmerican;
    RTS;
    
    schaltjahr:
    LDAB #29;
    STAB AMERICAN_D;
    JSR continueAmerican;
    RTS; 
    continueAmerican:
    LDAA #$00
    LDAB AMERICAN_H;
    CMPB #12;
    BLT setAM;
    BRA setPM;
    
   setAM:
    MOVW #$616D,OUTPUTSTRING+8; setAM
    LDAB AMERICAN_H;
    LDX #ASCIIBuffer
    CMPB #$0;
    BNE continue12AM;
    LDAB #12;
    JSR decToASCII;
    MOVW ASCIIBuffer+4,OUTPUTSTRING;
    JSR skipToMinutes;
    RTS;
    continue12AM:
    JSR decToASCII;
    MOVW ASCIIBuffer+4,OUTPUTSTRING;
    JSR skipToMinutes;
    RTS;
  setPM:
     MOVW #$506D,OUTPUTSTRING+8; setPM
     LDAB AMERICAN_H;
     LDX #ASCIIBuffer
     CMPB #12
     BNE continue12PM;
     JSR decToASCII;
     MOVW ASCIIBuffer+4,OUTPUTSTRING;
     JSR skipToMinutes;
     RTS;
     continue12PM:
     SUBB #12;
     JSR decToASCII;
     MOVW ASCIIBuffer+4,OUTPUTSTRING;
     JSR skipToMinutes;
     RTS;      
   ;Setup Minutes
   skipToMinutes:
   LDX #ASCIIBuffer
   LDAB MINUTES;
   JSR decToASCII;
   MOVW ASCIIBuffer+4,OUTPUTSTRING+3; 
   ;Setup Seconds
   LDX #ASCIIBuffer
   LDAB SECONDS;
   JSR decToASCII;
   MOVW ASCIIBuffer+4,OUTPUTSTRING+6
   LDX #ASCIIBuffer;
   MOVB #$00,OUTPUTSTRING+10;
   ;Setup Month
   LDAB AMERICAN_M;
   JSR decToASCII;
   MOVW ASCIIBuffer+4,DATE_STRING;
   ;/
   MOVB #$2F,DATE_STRING+2;
   ;Setup American Days 
   LDX #ASCIIBuffer;
   LDAB AMERICAN_D;
   JSR decToASCII;
   MOVW ASCIIBuffer+4,DATE_STRING+3;
   ;/
   MOVB #$2F,DATE_STRING+5;
   ;20  
   MOVW #$3230,DATE_STRING+6;
   ;Setup Year
    LDX #ASCIIBuffer;
    LDAB AMERICAN_Y;  
    JSR decToASCII;
    MOVW ASCIIBuffer+4,DATE_STRING+8;
    MOVB #$00,DATE_STRING+10
    
    LDAB AMERICAN_DAY_OF_WEEK;
    LDX #N2DE;
    LDY #DAY_STRING;
    LDAA #3;
    MUL;
    ABX;
    MOVW X,Y;
    INX;
    INX;
    INY;
    INY;
    MOVB X,Y;
    INY;
    MOVB #$3A,Y;
    INY;
    MOVB #$00,Y;
    JSR displayString;
    RTS
    
    
    
   
 
    
   

  
  
  
  
    
    
    
     
    
    
    
    
    
    
    
    
      
    
    
    