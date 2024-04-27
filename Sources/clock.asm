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
    XDEF addSecondsSet,addMinutesSet,addHourSet;
    XDEF OUTPUTSTRING;
    XREF PIFP,toggleLED,setMode;
  
        
.data:  SECTION
SECONDS:  DS.B 1
MINUTES:  DS.B 1
HOURS:    DS.B 1
Hour12Format: DS.B 1
OUTPUTSTRING: DS.B 11
ASCIIBuffer: DS.B 7
 
 
 
.init: SECTION
  setClock:
    MOVB #58,SECONDS;
    MOVB #59,MINUTES;
    MOVB #23,HOURS;
    MOVB #$01,Hour12Format
    RTS
  cancelTick:
    RTS;
  tick:
   ;pshd
   ;pshx
   ;pshy
    
   BRSET setMode,#$01,cancelTick;
   LDAB #$01;
   JSR toggleLED;
   JSR addSecond;
   JSR chooseFormat;
   ;JSR displayText; TODO implement Method for displayign TEXT
   RTS;
  addSecond:
    LDAB SECONDS;
    CMPB #59
    BEQ rollOverSecondsNormal;
    INCB;
    STAB SECONDS;
    BRA chooseFormat;
    RTS
  addMinute:
    LDAB MINUTES;
    CMPB #59
    BEQ rollOverMinutesNormal;
    INCB;
    STAB MINUTES;
    BRA chooseFormat;
    RTS
  addHour:
    LDAB HOURS;
    CMPB #23;
    BEQ rollOverHoursNormal;
    INCB;
    STAB HOURS;
    BRA chooseFormat;
    RTS
  rollOverSecondsNormal:
    MOVB #$00,SECONDS;
    BRA addMinute;
  rollOverMinutesNormal:
    MOVB #$00,MINUTES;
    BRA addHour;
  rollOverHoursNormal:
    MOVB #00,HOURS;
    BRA chooseFormat;
    RTS;  
  setupText:
   LDAA #$00
   ;Setup Hours
   LDX #ASCIIBuffer
   LDAB HOURS;
   JSR decToASCII;
   MOVW ASCIIBuffer+4,OUTPUTSTRING;
   skipToMinutes:    
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
   ;Set Format Symbols     
   MOVB #$3A,OUTPUTSTRING+2; ":"
   MOVB #$3A,OUTPUTSTRING+5;
   
   ;puld
   ;pulx
   ;puly
   
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
    RTS
  setPM:
     MOVW #$506D,OUTPUTSTRING+8; setPM
     LDAB HOURS;
     LDX #ASCIIBuffer
     CMPB #12
     BNE continue12PM;
     JSR decToASCII;
     MOVW ASCIIBuffer+4,OUTPUTSTRING;
     JSR skipToMinutes;
     RTS
     continue12PM:
     SUBB #12;
     JSR decToASCII;
     MOVW ASCIIBuffer+4,OUTPUTSTRING;
     JSR skipToMinutes;
     RTS
  addHourSet:
    LDAB HOURS;
    CMPB #12;
    BEQ rollOverHours;
    INCB;
    STAB HOURS;
    RTS;
    rollOverHours:
    MOVB #$00,HOURS;
    RTS;
  addMinutesSet:
    LDAB MINUTES;
    CMPB #59;
    BEQ rollOverMinutes;
    INCB;
    STAB MINUTES;
    RTS;
    rollOverMinutes:
    MOVB #$00,MINUTES;
    RTS;
  addSecondsSet:
    LDAB SECONDS;
    CMPB #59;
    BEQ rollOverSeconds;
    INCB;
    STAB SECONDS;
    RTS;
    rollOverSeconds:
    MOVB #$00,SECONDS;
    RTS;    

 
 
 
  
  
  
    
    
    
    
    
    
 
 
 
 

     
      