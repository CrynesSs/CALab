
        XDEF setupNames,changeName,MAGIC_NUMBER_1,MAGIC_NUMBER_2,MAGIC_NUMBER_PWMDTY1,initNamechanger,FRAME_BUFFER
        XREF PIFP,PWMPER2,PWMDTY2,PWME,writeLine



.data:SECTION
  FRAMECOUNT: DC.B 1; Framecount Reset after all Frames displayed.
  ACTIVE_NAME: DC.B 1 ; 0 = NAME1, 1=Name2
  FRAME_BUFFER: DS.B 17
  .const:SECTION
  NAME1: DC.B "Julian Warttmann © IT WS2021/2022" ;33Chars,10s display period. Max 16 chars at once. to display all,[0,15]->[17,32],17*shifts in 10s so 10s/18 = 555ms => 
  ;18frames a 555ms and 10ms at the end waiting for change. One Change every 2,666,666 * 5 clock cycles = 13,333,330Cycles Better Number here is 13,333,248 as devisable by 256,52083*256, In Total 239,998,464/240,000,000 Cycles used for Frames. Last Frame overhang is only 1536Cycles = 0.000064S = 0.064ms = 64us
  NAME2: DC.B "Nikolai Glock © IT WS2021/2022";30chars,10s display period. Max 16 chars at once. to display all,[0,15]->[13,28],14*shifts in 10s, so 10s/15, circa 666ms=>
  ;15Frames a 666ms and 10ms at the end waiting for change. One Change every 2,666,666 * 6 clock cycles = 15,999,996Cycles,exact Number here is 16,000,000 Cycles without rounding errors 16,000,000 we keep as 256 * 62,500 is 16M This is exact. No overhang
  MAGIC_NUMBER_1: DC.W $CB73 ;52083
  MAGIC_NUMBER_2: DC.W $F424 ;62500
  MAGIC_NUMBER_PWMDTY1: DC.W $43D1; 17361 1/3 Duty Period
  MAGIC_NUMBER_PWMDTY2: DC.W $30D4; 12500 Shorter Duty but we just care about round numbers
  


.init: SECTION
    initNamechanger:
      MOVB #$00,FRAMECOUNT;
      MOVB #$01,ACTIVE_NAME;
      RTS;
    setupNames:
        LDAB ACTIVE_NAME;
        CMPB #0;
        BEQ handleName1;
        BRA handleName2;
    handleName1:
        LDAA FRAMECOUNT;
        CMPA #17;
        BEQ skipInc1;
        INCA;
        skipInc1:
        LDAB FRAMECOUNT;
        LDX #NAME1
        ABX;
        LDY #FRAME_BUFFER;
        LDAB #16 ; Needs to get 16 chars out of it
        BRA fameLoop;
    handleName2:
        LDAA FRAMECOUNT;
        CMPA #14;
        BEQ skipInc2;
        INCA;
        skipInc2:
        LDAB FRAMECOUNT;
        LDX #NAME2
        ABX;
        LDY #FRAME_BUFFER;
        LDAB #16 ; Needs to get 16 chars out of it
        BRA fameLoop;
    fameLoop:
        DECB;
        MOVB X,0,Y
        INY;
        INX;
        CMPB #0;
        BNE fameLoop;
        STAA FRAMECOUNT;
        MOVB #$00,FRAME_BUFFER+16
        JSR displayNames;
        RTS;
    changeName:
        LDAB ACTIVE_NAME;
        CMPB #$0;
        BEQ changeToName2
        BRA changeToName1
    changeToName1:
        EORB #$01;
        STAB ACTIVE_NAME;
        MOVB #$00,FRAMECOUNT
        MOVW MAGIC_NUMBER_1,PWMPER2;
        MOVW MAGIC_NUMBER_PWMDTY1,PWMDTY2
        MOVB #$3F,PWME;
        RTS;
    changeToName2:        
        EORB #$01;
        STAB ACTIVE_NAME;
        MOVB #$00,FRAMECOUNT
        MOVW MAGIC_NUMBER_2,PWMPER2;
        MOVW MAGIC_NUMBER_PWMDTY2,PWMDTY2
        MOVB #$3F,PWME;
        RTS;
    displayNames:
      LDX #FRAME_BUFFER;
      LDAB #0;
      JSR writeLine;
      RTS;
        
        

