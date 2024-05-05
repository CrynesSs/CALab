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
        XREF PIFH,TC0,TFLG1,PPSH,TCNT,PIEH,DDRH,PTH,PTH_PTH0,PERH;
        XREF addSecondsSet,addMinutesSet,addHourSet,toggleLED
        XDEF setMode,initButtonState;

.data: SECTION
  setMode: DC.B 1
  setModeTimerStarted: DC.B 1
        
.init: SECTION
  initButtonState:
    MOVB #$00,setMode
    MOVB #$00, setModeTimerStarted
    ;Enables Interrupts on Port H which is probably the buttons connections
    MOVB #$00,DDRH
        ;Port H Polarity Register,set active Edge to Rising
    MOVB #$00,PPSH
        ;Port H Interrupt Enable. Enable Interrupts for Port H  
    MOVB #$FF,PIEH 
    MOVB #$FF,PERH;
    RTS;


  buttonHandle:
    LDAB setMode;
    CMPB #$00;
    BEQ normalModeInterrupt;
    BRA setModeInterrupt;
  
  normalModeInterrupt:
    ;Ignore all Interrupts except button 0,Default State PortH is FF. If pressed FE. So 11111110. 
    BRSET PTH,#$01,cleanFlags;
    ;Clear Button 1 Interrupt Flag
    ;MOVB #$01,PIFH;
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
    MOVB #$01,TFLG1;
    STD TC0;
    RTI
        
  buttonJustReleasedInterrupt:
    BRSET TFLG1,#$01,buttonWasTooLateReleased;
    ;Toggle Mode
    LDAB setMode;
    EORB #$01;
    STAB setMode;
    LDAB #$80;
    JSR toggleLED;
    RTI;  
  buttonWasTooLateReleased:
     ;Clear the Flag
     MOVB #$00,TFLG1;
     ;toggle Input Edge on button 
     LDAB PPSH;
     EORB #$01;
     STAB PPSH;
     RTI
  
       
  setModeInterrupt:
     
     ;Check Button 2
     BRCLR PTH, #$02,jmpToSecond;
     rtsFromSecond:
     ;check Button 3
     BRCLR PTH,#$04,jmpToMinute;
     rtsFromMinute:
     ;check Button 4
     BRCLR PTH,#$08,jmpToHour;
     rtsFromHour:
     ;Check Button 1
     BRSET PTH,#$01,cleanFlags;
     BRSET PPSH,#$01,buttonJustPressedInterrupt;
     BRSET PPSH,#$00,buttonJustReleasedInterrupt;
     RTI;
     ;TODO Add Hours/Min/Sec independent from Rollover
  jmpToSecond:
    JSR addSecondsSet;
    MOVB #$02,PIFH;
    BRA rtsFromSecond;
  jmpToMinute:
    JSR addMinutesSet;
    MOVB #$04,PIFH;
    BRA rtsFromMinute;
  jmpToHour:
    JSR addHourSet;
    MOVB #$08,PIFH;
    BRA rtsFromHour; 
  cleanFlags:
    MOVB #$0F,PIFH;
    RTI;  