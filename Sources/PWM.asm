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
    XDEF setupPWM
    XREF PWME,PWMPOL,PWMCTL,PWMCLK,PWMPRCLK,PWMCAE,PWMSCLA,PWMSCLB,PWMPER0,PWMPER1,PWMPER4,PWMPER5,PWMDTY0,PWMDTY1,PWMDTY4,PWMDTY5,PIEP,PPSP,PWMPER2,PWMDTY2   
    XREF DDRP 
    XREF MAGIC_NUMBER_1,MAGIC_NUMBER_2,MAGIC_NUMBER_PWMDTY1    

; Defines

; RAM: Variable data section
.data: SECTION
  
  

; ROM: Constant data
.const: SECTION

; ROM: Code section
.init: SECTION
  
  setupPWM:
  MOVB #$FF,DDRP;Set Port P as Output
  ;Port P Interrupt Enable on Pin 1,3,5
  MOVB #$2A,PIEP
  ;Trigger on pos. Edge of P1
  MOVB #$2A,PPSP; 
  ;PWM Enable for 0,1 and 4,5
  MOVB #$3F,PWME;
  ;PWM Polarity
  MOVB #$00,PWMPOL
  ;PWM Clock Select : B/SB,B/SB,A/SA,A/SA,B/SB,B/SB,A/SA,A/SA
  MOVB #$FF,PWMCLK ;Select SA for Channels 0,1/4,5 and SB for Channels 2,3/7,8
  ;PWM Prescale Clock Select 4bit B , 4bit A
  MOVB #$77,PWMPRCLK ;Prescalefactor Clock A 128,Clock B 128
  ;PWM Center Align Enable
  MOVB #$00,PWMCAE
  ;PWM Control switch from 8bit to 16bit concat 67,45,23,01,StopInWait,StopInFreeze,0,0
  MOVB #$F0,PWMCTL ;Concat Register 0/1,2/3,4/5,6/7
  ;PWM Scale A for SA SA=A/(2*PWMSCLA)
  MOVB #$32,PWMSCLA ;PWM Scale 50, Total Prescale = 128 * 2 * 50 = 12800
  ;PWM Scale B for SB SB=B/(2*PWMSCLB)
  MOVB #$01,PWMSCLB ;PWM Scale 1, Total Prescale = 128*2*1=256
  ;PWM Channel Period Register Period=Clock * RegisterValue, Each Channel has its own Register
  ;Magic Number here is 1875 which is 0x0753 ;;Sidenote:technically devisable by 3 and could use 1 register instead of connected registers, but currently not needed
  MOVB #$07,PWMPER0 ;High Byte of 16 bit count
  MOVB #$53,PWMPER1 ;Low Byte of 16 bit count
  ;PWM Duty Register Uptime is Uptime=([PWMPER-PWMDTY]/PWMPER)*100%
  ;20% Duty Cycle magic Number is 375
  MOVB #$01,PWMDTY0 ;High Byte of Duty Count
  MOVB #$77,PWMDTY1 ;Low Byte of Duty Count
  ;In Total 20% Duty Time of left aligned PWM Signal with 1875 Countdown with 12800 prescaler = One Edge every 24.000.000 Cycles = 1s
  ;Output Channel is PWM1
  ;Magic Number here is 18750 which is 0x493E
  MOVB #$49,PWMPER4
  MOVB #$3E,PWMPER5
  ;20% Duty Cycle magic Number is 3750 which is 0x0EA6 
  MOVB #$0E,PWMDTY4 ;High Byte of Duty Count
  MOVB #$A6,PWMDTY5 ;Low Byte of Duty Count
  ;In Total 20% Duty Time of left aligned PWM Signal with 1875 Countdown with 12800 prescaler = One Edge every 24.000.000 Cycles = 1s
  ;Output Channel is PWM5
  ;Move Number from nameChanger into PWMER2 to start switching frames.
  MOVW #MAGIC_NUMBER_1,PWMPER2;
  MOVW #MAGIC_NUMBER_PWMDTY1,PWMDTY2




  RTS
  
 
  
  
  
  