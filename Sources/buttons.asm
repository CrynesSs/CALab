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
        XDEF buttonHandle
        XREF PIFH,TC0,TFLG1,PPSH,TCNT;
        XREF addSecond,addMinute,addHour
        XDEF setMode;

.data: SECTION
  setMode: DS.B 1
  setModeTimerStarted: DS.B 1
        
.init: SECTION
  buttonHandle:
    LDAB setMode;
    CMPA #$0;
    BEQ normalModeInterrupt;
    BRA setModeInterrupt;
  
  normalModeInterrupt:
    ;Ignore all Interrupts except button 0
    BRCLR PIFH,#$00,cleanFlags;
    ;Clear Button 1 Interrupt Flag
    MOVB #$01,PIFH;
    BRSET PPSH,#$01,buttonJustPressedInterrupt;
    BRSET PPSH,#$00,buttonJustReleasedInterrupt;
    
  buttonJustPressedInterrupt:
    ;toggle Input Edge on button
    LDAB PPSH;
    EORB #$01;
    STAB PPSH;
    ;Setup Timer so we can track how long the button was pressed for
    LDD TCNT;
    SUBD #1;
    ;Clear the Timer Flag if it is already set
    MOVB #$00,TFLG1;
    STD TC0;
    RTI
        
  buttonJustReleasedInterrupt:
    BRSET TFLG1,#$00,buttonWasTooLateReleased;
    ;Toggle Mode
    LDAB setMode;
    EORB #$01;
    STAB setMode;
    
    
  buttonWasTooLateReleased:
     ;Clear the Flag
     MOVB #$00,TFLG1;
     ;toggle Input Edge on button 
     LDAB PPSH;
     EORB #$01;
     STAB PPSH;
     RTI
  
       
  setModeInterrupt:
     ;Check Button 1
     BRSET PPSH,#$01,buttonJustPressedInterrupt;
     BRSET PPSH,#$00,buttonJustReleasedInterrupt;
     ;Check Button 2
     BRSET PPSH, #$02,jmpToSecond;
     rtsFromSecond:
     ;check Button 3
     BRSET PPSH,#$04,jmpToMinute;
     rtsFromMinute:
     ;check Button 4
     BRSET PPSH,#$08,jmpToHour;
     
     RTI;
     ;TODO Add Hours/Min/Sec independent from Rollover
  jmpToSecond:
    JSR addSecond;
    MOVB #$01,PIFH;
    BRA rtsFromSecond;
  jmpToMinute:
    JSR addMinute;
    MOVB #$02,PIFH;
    BRA rtsFromMinute;
  jmpToHour:
    JSR addHour;
    MOVB #$04,PIFH;
    BRA 
  cleanFlags:
    MOVB #$0F,PIFH;
    RTI;  