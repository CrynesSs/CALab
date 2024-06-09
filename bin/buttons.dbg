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
        XREF PIFH,TFLG1,PPSH,TCNT,PIEH,DDRH,PTH,PTH_PTH0,PERH,displayTimeAndDate,switchOutput,AMERICAN;
        XREF addSecondsSet,addMinutesSet,addHoursSet,toggleLED
        XDEF setMode,initButtonState,evaluateButtons,buttonHandleLab3;
        XREF TC0,TC1,TC2,TC3,TC4,TC5,TC6,TC7

.data: SECTION
  buttonPressedEval: DC.B 1
  buttonReleasedEval: DC.B 1
  setMode: DC.B 1
  setModeTimerStarted: DC.B 1
        
.init: SECTION
  initButtonState:
    ;MOVB #$00,setMode
    ;MOVB #$00, setModeTimerStarted
    ;Enables Interrupts on Port H which is probably the buttons connections
    ;MOVB #$00,DDRH
        ;Port H Polarity Register,set active Edge to Rising
    ;MOVB #$00,PPSH
        ;Port H Interrupt Enable. Enable Interrupts for Port H  
    MOVB #$FF,PIEH 
    MOVB #$FF,PERH;
    RTS;
  
  buttonHandleLab3:
  LDAB PTH;
  ANDB #$04;
  CMPB #$00;
  BEQ handleButton3;
  RTI;
  handleButton3:
  LDAB AMERICAN;
  EORB #$01;
  STAB AMERICAN;
  RTI;
  
  
  
  evaluateButtons:
  ;PIFH_PIFH0 & PPSH_PPSH0 -> Button just pressed
  ;PIFH_PIFH0 & !PPSH_PPSH0 -> Button just released
  ;!PIFH_PIFH0 & (PPSH_PPSH0 | !PPSH_PPSH0) -> NoHandle
  LDAA PIFH;
  ANDA PPSH;
  STAA buttonPressedEval;
  ;Quasi Not Gate
  LDAB PPSH;
  EORB #$FF;
  ANDB PIFH;
  STAB buttonReleasedEval;
  ;Eval
  continueEvalBT:
  BRSET buttonPressedEval,#$01,handleBt1;
  BRSET buttonReleasedEval,#$01,handleBt1;
  ;return if not in set Mode as button 2 in normal mode should not do anything
  LDAB setMode;
  BITB #$01;
  BNE notInSetMode;
  BRSET buttonPressedEval,#$02,handleBt2;
  BRSET buttonPressedEval,#$04,handleBt3;
  BRSET buttonPressedEval,#$08,handleBt4;
  BRSET buttonReleasedEval,#$02,handleBt2;
  BRSET buttonReleasedEval,#$04,handleBt3;
  BRSET buttonReleasedEval,#$08,handleBt4;
  notInSetMode:
  RTI;
  handleBt1:
  JSR logicBT1;
  BRA continueEvalBT;
  handleBt2:
  JSR logicBT2;
  BRA continueEvalBT;
  handleBt3:
  JSR logicBT3;
  BRA continueEvalBT;
  handleBt4:
  JSR logicBT4;
  BRA continueEvalBT; 
  
  logicBT1:
  ;Change Register Polarity to catch opposite edge next time. Dual Edge button Detection
  LDAB PPSH;
  EORB #$01;
  STAB PPSH;
  BRSET buttonReleasedEval,#$01,released1;
  ;Handler here if button was pressed
  ;Clear the bit of buttonPressedEval so the handler knows we dealt with it.
  LDAB buttonPressedEval;
  ANDB #$FE;
  STAB buttonPressedEval;
  ;Minimum 50ms of pressed, so the flag gets set after 50ms, so we can ignore buttons that are pushed very short
  LDD TCNT
  ADDD #$0EA6
  STD TC1;
  ;Maximum time we can measuere. This should give around 350ms of max button push length
  LDD TCNT;
  SUBD #1;
  STD TC0;
  BRA continueEval;
  released1:
  ;Reset bit in buttonReleasedEval
  LDAB buttonReleasedEval;
  ANDB #$FE;
  STAB buttonReleasedEval; 
  ;handle here if button was released
  LDAB TFLG1;
  LSRB;
  ANDB TFLG1;
  BITA #$01;
  BNE continueEval;
  LDAB setMode;
  EORB #$01;
  STAB setMode;
  LDAB #$80;
  JSR toggleLED;
  RTS
  
  logicBT2:
  ;Change Register Polarity to catch opposite edge next time. Dual Edge button Detection
  LDAB PPSH;
  EORB #$02;
  STAB PPSH;
  BRSET buttonReleasedEval,#$02,released2;
  ;Handler here if button was pressed
  ;Clear the bit of buttonPressedEval so the handler knows we dealt with it.
  LDAB buttonPressedEval;
  ANDB #$FD;
  STAB buttonPressedEval;
  ;Minimum 50ms of pressed, so the flag gets set after 50ms, so we can ignore buttons that are pushed very short
  LDD TCNT
  ADDD #$0EA6
  STD TC3;
  ;Maximum time we can measuere. This should give around 350ms of max button push length
  LDD TCNT;
  SUBD #1;
  STD TC2;
  BRA continueEval;
  released2:
  ;Reset bit in buttonReleasedEval
  LDAB buttonReleasedEval;
  ANDB #$FD;
  STAB buttonReleasedEval; 
  ;handle here if button was released
  LDAB TFLG1;
  LSRB;
  ANDB TFLG1;
  BITA #$04;
  BNE continueEval;
  JSR addSecondsSet;
  RTS;
  
  continueEval:
  RTS;
  
  logicBT3:
  ;Change Register Polarity to catch opposite edge next time. Dual Edge button Detection
  LDAB PPSH;
  EORB #$04;
  STAB PPSH;
  BRSET buttonReleasedEval,#$04,released3;
  ;Handler here if button was pressed
  ;Clear the bit of buttonPressedEval so the handler knows we dealt with it.
  LDAB buttonPressedEval;
  ANDB #$FB;
  STAB buttonPressedEval;
  ;Minimum 50ms of pressed, so the flag gets set after 50ms, so we can ignore buttons that are pushed very short
  LDD TCNT
  ADDD #$0EA6
  STD TC5;
  ;Maximum time we can measuere. This should give around 350ms of max button push length
  LDD TCNT;
  SUBD #1;
  STD TC4;
  BRA continueEval;
  released3:
  ;Reset bit in buttonReleasedEval
  LDAB buttonReleasedEval;
  ANDB #$FB;
  STAB buttonReleasedEval; 
  ;handle here if button was released
  LDAB TFLG1;
  LSRB;
  ANDB TFLG1;
  BITA #$10;
  BNE continueEval;
  JSR addMinutesSet;
  RTS
  
  logicBT4:
  ;Change Register Polarity to catch opposite edge next time. Dual Edge button Detection
  LDAB PPSH;
  EORB #$08;
  STAB PPSH;
  BRSET buttonReleasedEval,#$08,released4;
  ;Handler here if button was pressed
  ;Clear the bit of buttonPressedEval so the handler knows we dealt with it.
  LDAB buttonPressedEval;
  ANDB #$F7;
  STAB buttonPressedEval;
  ;Minimum 50ms of pressed, so the flag gets set after 50ms, so we can ignore buttons that are pushed very short
  LDD TCNT
  ADDD #$0EA6
  STD TC7;
  ;Maximum time we can measuere. This should give around 350ms of max button push length
  LDD TCNT;
  SUBD #1;
  STD TC6;
  BRA continueEval;
  released4:
  ;Reset bit in buttonReleasedEval
  LDAB buttonReleasedEval;
  ANDB #$F7;
  STAB buttonReleasedEval; 
  ;handle here if button was released
  LDAB TFLG1;
  LSRB;
  ANDB TFLG1;
  BITA #$40;
  BNE continueEval;
  JSR addHoursSet;
  RTS; 
