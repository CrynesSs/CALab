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
    XREF decToASCII;
    XDEF tick,setClock,addSecond,addMinute,addHour;
    XREF PIFP,toggleLED,displayText;
  
        
.data:  SECTION
SECONDS:  DS.B 1
MINUTES:  DS.B 1
HOURS:    DS.B 1
Hour12Format: DS.B 1
OUTPUTSTRING: DS.B 11
ASCIIBuffer: DS.B 7 
 
 
.init: SECTION
  setClock:
    MOVB #30,SECONDS;
    MOVB #59,MINUTES;
    MOVB #23,HOURS;
    RTS

  tick:
   MOVB #$02,PIFP;Reset Interrupt Flag
   LDAB #$01;
   JSR toggleLED;
   
   JSR addSecond;
   JSR chooseFormat;
   ;JSR displayText; TODO implement Method for displayign TEXT
   RTI;
  addSecond:
    LDAB SECONDS;
    CMPB #59
    BEQ rollOverSecondsSet;
    INCB;
    STAB SECONDS;
    BRA chooseFormat;
    RTS
  addMinute:
    LDAB MINUTES;
    CMPB #59
    BEQ rollOverMinutesSet;
    INCB;
    STAB MINUTES;
    BRA chooseFormat;
    RTS
  addHour:
    LDAB HOURS;
    CMPB #23;
    BEQ rollOverHoursSet;
    INCB;
    STAB HOURS;
    BRA chooseFormat;
    RTS
  rollOverSecondsSet:
    MOVB #$00,SECONDS;
    BRA addMinute;
  rollOverMinutesSet:
    MOVB #$00,MINUTES;
    BRA addHour;
  rollOverHoursSet:
    MOVB #00,HOURS;
    BRA chooseFormat;
    RTS;  
  setupText:
    ;Set Format Symbols     
   MOVB #$3A,OUTPUTSTRING+2; ":"
   MOVB #$3A,OUTPUTSTRING+5;
   LDAA #$00
   ;Setup Hours
   LDX #ASCIIBuffer
   LDAB HOURS;
   JSR decToASCII;
   MOVW ASCIIBuffer+4,OUTPUTSTRING;    
   ;Setup Minutes
   LDX #ASCIIBuffer
   LDAB MINUTES;
   JSR decToASCII;
   MOVW ASCIIBuffer+4,OUTPUTSTRING+3; 
   ;Setup Seconds
   LDX #ASCIIBuffer
   LDAB SECONDS;
   JSR decToASCII;
   MOVW ASCIIBuffer+4,OUTPUTSTRING+6
   ;Move Outputstring Pointer to X   
   LDX #OUTPUTSTRING
   RTS;    
  chooseFormat:
    LDAB Hour12Format;
    MOVW #$2020,OUTPUTSTRING+8
    MOVB #$00,OUTPUTSTRING+10
    CMPB #$01
    BEQ handle12HourFormat;
    BRA setupText;
  handle12HourFormat:
    lDAA #$00;
    LDAB HOURS;
    CMPB #12;
    BLT setAM;
    BRA setPM;
  setAM:
    MOVW #$616D,OUTPUTSTRING+8; setAM
    LDAB HOURS;
    CMPB #$0;
    BNE continue12AM;
    LDAB #12;
    continue12AM:
    BRA setupText;
  setPM:
     MOVW #$506D,OUTPUTSTRING+8; setPM
     LDAB HOURS;
     CMPB #12
     BNE continue12PM;
     BRA setupText;
     continue12PM:
     SUBB #12;
     BRA setupText;

 
 
 
  
  
  
    
    
    
    
    
    
 
 
 
 

     
      