


   XREF PTH,MINUTES,SECONDS,HOURS,MCFLG,Hour12Format,chooseFormat,decToASCII,toggleLED
   XDEF signalDecoderControl,init_intervals,testFunction,signalDecoderControl,DATE_STRING,DAY_STRING,VALID_DAYS,VALID_MONTH,VALID_YEAR,DAY_OF_WEEK
   XREF setMode;

.data: SECTION
HIGHS: DC.B 1
TOTAL_POLLS: DC.B 1
;0 if false 1 if true
STOP_BIT_FOUND: DC.B 1
WAIT_FOR_DATA: DC.B 1
DATA_BUFFER: DC.W 1

DATA_STREAM: DS.B 8;
STREAM_POSITION: DC.B 1;

VALID_MINUTES: DC.B 1;
VALID_HOURS: DC.B 1
VALID_DAYS: DC.B 1
VALID_MONTH: DC.B 1;
VALID_YEAR: DC.B 1

DAY_OF_WEEK: DC.B 1
DAY_OF_WEEK_AND_MONTH: DC.B 1

ASCIIBuffer: DS.B 7

TIME_STRING: DS.B 11
DATE_STRING: DS.B 11
DAY_STRING: DS.B 5;



LOOP: DC.B 1
TEMP: DC.B 1;
TEMP_BIT: DC.B 1;

;Confidence Intervals
CONF_STOP: DS.B 1 ; 191+ 0xBF
CONF_I0: DS.B 2 ; [189,171] , [0xBD,0xAB]
CONF_I1: DS.B 2 ; [169,151] , [0xA9,0x97]

.const: SECTION
N2DE: DC.B "MONTUEWEDTHUFRISATSUN"
N2DD: DC.B "MODIMIDOFRSASO"  
  


.init: SECTION

    testFunction:
    MOVW #$0000,DATA_STREAM;
    MOVW #$0F0E,DATA_STREAM+2;
    MOVW #$082C,DATA_STREAM+4;
    MOVW #$3840,DATA_STREAM+6;
    MOVB #$01,STOP_BIT_FOUND;
    MOVB #$00,WAIT_FOR_DATA;
    MOVB #195,HIGHS;
    MOVB #199,TOTAL_POLLS;
    RTS;
    
    init_intervals:
    ;191
    MOVB #$BF,CONF_STOP;
    ;[189,171]
    MOVW #$BDAB,CONF_I0;
    ;[169,151]
    MOVW #$A997,CONF_I1;
    
    MOVW #$0000,DATA_BUFFER;
    MOVB #$00,HIGHS;
    MOVB #$00,TOTAL_POLLS;
    MOVB #$00,STOP_BIT_FOUND;
    MOVB #$00,WAIT_FOR_DATA;
    MOVB #$00,STREAM_POSITION;
    MOVW #$0000,DATA_STREAM;
    MOVW #$0000,DATA_STREAM+2;
    MOVW #$0000,DATA_STREAM+4;
    MOVW #$0000,DATA_STREAM+6;
    MOVB #00,SECONDS;
    MOVB #$00,setMode
    RTS;

    
    
    signalDecoderControl:
    MOVB #$80,MCFLG;
    ;If the Number of Total Polls is less than 200, we need to continue polling. 
    JSR pollSignal;
    
    LDAB STOP_BIT_FOUND;
    CMPB #$00;
    LBEQ checkForStopBit;
    LDAB WAIT_FOR_DATA;
    CMPB #$01;
    LBEQ checkDataBuffer;
    ;If 200 Polls happened we need to eval the Window
    LDAB TOTAL_POLLS;
    CMPB #200;
    BEQ evalWindow;
    RTI;
    
    
    
    evalWindow:
    LDAB HIGHS;
    ;Check if Highs are outside lowest Count;
    CMPB CONF_I1+1;
    BLO resetToDefault;
    CMPB CONF_I1;
    BLE validOne;
    CMPB CONF_I0+1;
    BLO resetToDefault;
    CMPB CONF_I0;
    BLE validZero;
    CMPB CONF_STOP;
    BLO resetToDefault;
    ;Valid Stop Bit here
    MOVB #$01,WAIT_FOR_DATA;  
    LBRA evalBits;
    
    
    validOne:
    LDAB #$80;
    JSR toggleLED;
    LDAB #$01;
    JSR putBit;
    RTI;
    
    validZero:
    LDAB #$40;
    JSR toggleLED;
    LDAB #$00;
    JSR putBit;
    RTI;
    
    

    resetToDefault:
    ;We got an invalidBit, so we need to also refind our STOP_BIT
    MOVB #$00,STOP_BIT_FOUND;
    MOVB #$00,WAIT_FOR_DATA;
    ;Reset the Data Stream Bytes
    MOVW #$0000,DATA_STREAM;
    MOVW #$0000,DATA_STREAM+2;
    MOVW #$0000,DATA_STREAM+4;
    MOVW #$0000,DATA_STREAM+6;
    ;Reset the Data Stream Position
    MOVB #$00,STREAM_POSITION;
    ;Clear the Data Buffer
    MOVW #$0000,DATA_BUFFER;
    ;Reset the Eval Window
    MOVB #$00,HIGHS;
    MOVB #$00,TOTAL_POLLS;
    RTI;

    checkForStopBit:
    LDAB TOTAL_POLLS;
    CMPB #200;
    ;Return if the total number of polls is less than 200;
    BHS continueStopBitEval;
    RTI;
    continueStopBitEval:
    LDAB HIGHS;
    CMPB CONF_STOP;
    ;Throw away the interval if the confidence threshhold is not met
    BLO thresholdNotMet;
    MOVB #$01,STOP_BIT_FOUND;
    MOVB #$01,WAIT_FOR_DATA;
    MOVB #$00,TOTAL_POLLS;
    MOVW #$0000,DATA_BUFFER;
    thresholdNotMet:
    MOVB #$00,HIGHS;
    MOVB #$00,TOTAL_POLLS;
    RTI;
 

    checkDataBuffer:
    LDAB TOTAL_POLLS;
    CMPB #16;
    BLO fillDataBuffer;
    ;Load Data buffer and count Ones of it
    LDD DATA_BUFFER;
    JSR countOnes;
    ;Count of Highs is now in B
    XGDY;
    ;If we get 12/16 lows, we can assume, that a Data Bit has started.
    CMPB #5;
    BLO startIntervals;
    ;Responsible for filling the Data Buffer
    fillDataBuffer:
    LDD DATA_BUFFER;
    LSLD;
    XGDX;
    LDAB PTH;
    ANDB #$01;
    ABX;
    XGDX;
    STD DATA_BUFFER;
    RTI;
    ;Start getting Bits from Signal
    startIntervals:
    STAB HIGHS;
    MOVB #$10,TOTAL_POLLS;
    MOVB #$00,WAIT_FOR_DATA;
    RTI;
    
    pollSignal:
    ;Load the PTH Register to get the bit we are interested in
    LDAA PTH;
    ;Isolate the Bit we want to check;
    ANDA #$01;
    ;Check if bit is set
    CMPA #$01;
    BNE continue;
    addHigh:
    LDAB HIGHS;
    INCB;
    STAB HIGHS;
    continue:
    LDAB TOTAL_POLLS;
    INCB;
    STAB TOTAL_POLLS;
    RTS;

    ;Puts a Bit into the right Position in a Data Stream. 
    ;Inputs:  B0 -> The bit to put
    ;         
    putBit:
    ;Check the Stream Position. If it is higher than 58, it is invalid as 59 is the stop bit.
    LDAB STREAM_POSITION;
    INCB;
    CMPB #59;
    BLO isValid;
    ;Here the Stream Count is invalid;
    ;Maybe do sth here idk?idc
    isValid:
    ;Put #8 into the X Register, so we can find the correct Byte and Byte Position
    MOVW #$0008,X; 
    ;Store the Bit to write in Y
    ;We need to swap the Bit to A, as the Y register loads left to right into B
    EXG A,B;
    XGDY;
    ;Put Stream Position and IDIV to get the result
    LDAA #0
    LDAB STREAM_POSITION;
    IDIV;
    ;Remainder is now in D. This is the Byte Position. Result in X. That is the Position in the Byte we need to write.
    ; So in Short we now have A=irrelevant,B=Position inside the Byte,X=The Byte Index in the Array,Y=The Value to write.
    ;Put the Bit at the correct Position.
    LDAA #7;
    SBA;
    ;Write Value in B
    TFR Y,B;
    ;Shift the one over n times where n is stored in A.
    shift_loop:
    CMPB #$00;
    BEQ continuePutting;
    LSLB;
    DECA;
    BRA shift_loop;
    ;When we arrive at this Point:
    ;Register A=0,B=Bit to put at the correct position,Y=irrelevant,X=Byte Position in Stream
    continuePutting:
    ;Load the Data Stream Address
    LDY #DATA_STREAM
    ;Get the Position in Stream from X;
    XGDX;
    ;Add the offset to Y so we get the correct Byte Out.
    ABY;
    ;Get the correct Bit Back into B
    XGDX;
    ;Load the Byte we want to write to into A
    LDAA Y;
    ;Add B to A. This is fine, as the Stream defaults to only contain 0's
    ABA;
    ;Save the Byte
    STAB Y;
    ;Increase the Stream Position by 1;
    LDAB STREAM_POSITION;
    INCB;
    STAB STREAM_POSITION;
    RTS;
    
    
    ;*************************************************************************
    ;Eval Functions
    ;*************************************************************************
    ;Returns from the Eval. evalBits is called with a Branch, so we can RTI here.
    returnFromEval:
    MOVW #$0000,DATA_STREAM;
    MOVW #$0000,DATA_STREAM+2;
    MOVW #$0000,DATA_STREAM+4;
    MOVW #$0000,DATA_STREAM+6;
    MOVB #$00,STREAM_POSITION;
    MOVB #$00,HIGHS;
    MOVB #$00,TOTAL_POLLS;
    RTI;
    
    evalBits:
    ;Check the Date Parity;
    JSR checkDateParity;
    CMPB #$01;
    BEQ returnFromEval;
    ;Checks the Minute Parity
    JSR checkMinuteParity;
    CMPB #$01;
    BEQ returnFromEval;
    ;Put Correct Hours;
    JSR checkHourParity;
    CMPB #$01;
    BEQ returnFromEval;
    ;All Parities completed successfully. Now set the Values
    JSR evalMinutes;
    JSR evalHours;
    JSR evalDays;
    JSR evalDayOfWeek
    JSR evalYear;
    JSR putCorrectDateAndTime;
    BRA returnFromEval;
    
    
    ;Sets the "Flag" bit to 01 and returns
    invalidBit:
    LDAB #$01;
    RTS;
    
    ;Checks if bit 20 is set correctly;
    checkBit20:
    LDD DATA_STREAM+2;
    LSRD;
    LSRD;
    LSRD;
    ;Here we start with BIT 20, this needs to be 1;
    ANDA #$01;
    CMPA #$00;
    BEQ invalidBit;
    LDAB #$00;
    RTS;
    
    ;Checks the Minute Parity
    checkMinuteParity:
    ;Load Data again
    LDD DATA_STREAM+2;
    LSRD;
    LSRD;
    LSRD;
    ANDA #$00;
    ANDB #$FE;
    JSR countOnes;
    XGDY;
    ;B now contains the number of ones;
    ANDB #$01;
    STAB TEMP;
    LDD DATA_STREAM+2;
    LSRD;
    LSRD;
    LSRD;
    ;Minute Parity now in B
    ANDB #$01;
    EORB TEMP;
    CMPB #$00;
    BNE invalidBit;
    LDAB #$00;
    RTS;
    
    checkHourParity:
    ;Load Byte 24-39
    LDD DATA_STREAM+3
    LSLD;
    LSLD;
    LSLD;
    LSLD;
    LSLD;
    ;Isolate the first 7 bits in A to get the Hours+Parity
    ANDA #$FC;
    TAB;
    ANDA #$00;
    JSR countOnes;
    XGDY;
    ANDB #$01;
    STAB TEMP;
    LDD DATA_STREAM+3;
    LSRD;
    LSRD;
    LSRD;
    LSRD;
    ANDB #$01;
    EORB TEMP;
    CMPB #0;
    BNE invalidBit;
    LDAB #$00;
    RTS;

    ;Works as Expected
    checkDateParity:
    ;L is the 1's counting register/
    ;Temp is loop Variable
    ;Load Bit 32-47
    LDD DATA_STREAM+4
    ;Isolate Bit 36-47
    ANDA #$0F;
    JSR countOnes;
    XGDY;
    STAB TEMP;
    ;Bits 48-63
    LDD DATA_STREAM+6;
    ;Isolate Bit 48-57
    ANDB #$C0;
    JSR countOnes;
    XGDY;
    LDAA TEMP;
    ABA;
    TAB;
    ; first bit of B indicates if we have a even or odd number of ones;
    ANDB #01;
    LDAA DATA_STREAM+7;
    LSLA;
    LSLA;
    ANDA #$80;
    ROLA;
    ROLA;
    ANDA #$01;
    ;Now the Parity Bit 58 is in A0 and B0 indicates if we have even or odd. A0 and B0 should be the same Means we XOR;
    STAA TEMP;
    EORB TEMP;
    CMPB #0;
    BEQ validBit;
    JSR invalidBit;
    LDAB #$01;
    RTS;
    validBit:
    LDAB #$00;
    RTS;
    
    ;Counts the number of ones in 2 Bytes/1Word
    ;Inputs: D->Word to analyze
    countOnes:
    MOVB #$0F,LOOP;
    LDY #0;
    count1sLoop:
    TFR D,X;
    ;1
    ;D and X now have the same bits in them;
    ANDB #$01;
    ;If B is a one, it is added to Y. Otherwise ignored
    ABY;
    ;Transfer the original Bits into D;
    TFR X,D;
    ;Shift D Right by one
    LSRD;
    ;Transfer shifted Bits to X;
    TFR D,X;
    ;After this D and X contain the shifted Bits;
    LDAB LOOP;
    CMPB #0;
    BEQ return;
    DECB;
    STAB LOOP;
    TFR X,D;
    BRA count1sLoop;
    return:
    RTS;
    
    
    ;****************************************************************
    ;Functions that store Data in correct Variables from Stream;
    ;****************************************************************
    evalMinutes:
    LDD DATA_STREAM+2;
    LSRD;
    LSRD;
    LSRD;
    ANDB #$FE;
    STAB VALID_MINUTES;
    LDAB #$00;
    RTS;
    
    evalHours:
    LDD DATA_STREAM+3;
    LSLD;
    LSLD;
    LSLD;
    LSLD;
    LSLD;
    ANDA #$FC;
    STAA VALID_HOURS;
    RTS;
    
    
    evalDays:
    LDD DATA_STREAM+4;
    LSLD;
    LSLD;
    LSLD;
    LSLD;
    ANDA #$FC
    STAA VALID_DAYS;
    RTS;
    
    evalDayOfWeek:
    LDD DATA_STREAM+5;
    LSLD;
    LSLD;
    STAA DAY_OF_WEEK_AND_MONTH;
    RTS;
    
    evalYear:
    LDD DATA_STREAM+6;
    LSLD;
    LSLD;
    STAA VALID_YEAR;
    RTS;
    
    ;****************************************************************
    ;Functions that convert Data from Bits to correct Values
    ;****************************************************************
    
    putCorrectDateAndTime:
    JSR convertMinutes;
    JSR convertHours;
    JSR convertDays;
    JSR convertDayOfWeek;
    JSR convertMonth;
    JSR convertYear;
    JSR setupOutput;
    RTS;
    
    
    convertMinutes:
    LDAB #0;
    LDAA VALID_MINUTES;
    ANDA #$80;
    CMPA #$80;
    BNE cont4;
    ADDB #1;
    cont4:
    LDAA VALID_MINUTES;
    ANDA #$40;  
    CMPA #$40;
    BNE cont5;
    ADDB #2
    cont5:
    LDAA VALID_MINUTES;
    ANDA #$20;
    CMPA #$20;
    BNE cont6;
    ADDB #4;
    cont6:
    LDAA VALID_MINUTES;
    ANDA #$10;
    CMPA #$10;
    BNE cont7;
    ADDB #8;
    cont7: 
    LDAA VALID_MINUTES;    
    ANDA #$02;
    CMPA #$02;
    BNE cont1;
    ADDB #40;
    cont1:
    LDAA VALID_MINUTES;
    ANDA #$04;
    CMPA #$04;
    BNE cont2;
    ADDB #20;
    cont2:
    LDAA VALID_MINUTES;
    ANDA #$08;
    CMPA #$08;
    BNE cont3;
    ADDB #10;
    cont3:
    STAB VALID_MINUTES;
    RTS;
    
    convertHours:
    LDAB #0;
    LDAA VALID_HOURS;
    ANDA #$80;
    CMPA #$80;
    BNE cont4H;
    ADDB #1;
    cont4H:
    LDAA VALID_HOURS;
    ANDA #$40;  
    CMPA #$40;
    BNE cont5H;
    ADDB #2
    cont5H:
    LDAA VALID_HOURS;
    ANDA #$20;
    CMPA #$20;
    BNE cont6H;
    ADDB #4;
    cont6H:
    LDAA VALID_HOURS;
    ANDA #$10;
    CMPA #$10;
    BNE cont7H;
    ADDB #8;
    cont7H:
    LDAA VALID_HOURS;
    ANDA #$08;
    CMPA #$08;
    BNE cont8H;
    ADDB #10;
    cont8H:
    LDAA VALID_HOURS;
    ANDA #$04;
    CMPA #$04;
    BNE cont9H;
    ADDB #20;
    cont9H:
    STAB VALID_HOURS;
    RTS;
    
    convertDays:
    LDAA #0;
    
    LDAB VALID_DAYS;
    ANDB #$80;
    CMPB #$80;
    BNE cont1d;
    ADDA #1;
    cont1d:
    LDAB VALID_DAYS;
    ANDB #$40;
    CMPB #$40;
    BNE cont2d;
    ADDA #2;
    cont2d:
    LDAB VALID_DAYS;
    ANDB #$20;
    CMPB #$20;
    BNE cont3d;
    ADDA #4;
    cont3d:
    LDAB VALID_DAYS;
    ANDB #$10;
    CMPB #$10;
    BNE cont4d;
    ADDA #8
    cont4d:
    LDAB VALID_DAYS;
    ANDB #$08;
    CMPB #$08;
    BNE cont5d;
    ADDA #10;
    cont5d:
    LDAB VALID_DAYS;
    ANDB #$04;
    CMPB #$04;
    BNE cont6d;
    ADDA #20;
    cont6d:
    STAA VALID_DAYS;
    RTS;
    
    convertDayOfWeek:
    LDAA #0;
    LDAB DAY_OF_WEEK_AND_MONTH;
    ANDB #$80;
    CMPB #$80;
    BNE cont1dow;
    ADDA #1;
    cont1dow:
    LDAB DAY_OF_WEEK_AND_MONTH;
    ANDB #$40;
    CMPB #$40;
    BNE cont2dow;
    ADDA #2;
    cont2dow:
    LDAB DAY_OF_WEEK_AND_MONTH;
    ANDB #$20;
    CMPB #$20;
    BNE cont3dow;
    ADDA #4;
    cont3dow:
    STAA DAY_OF_WEEK;
    RTS;

    convertMonth:
    LDAA #0;
    
    LDAB DAY_OF_WEEK_AND_MONTH;
    ANDB #$10
    CMPB #$10;
    BNE cont1m;
    ADDA #1;
    cont1m:
    LDAB DAY_OF_WEEK_AND_MONTH;
    ANDB #$08
    CMPB #$08;
    BNE cont2m;
    ADDA #2;
    cont2m:
    LDAB DAY_OF_WEEK_AND_MONTH;
    ANDB #$04
    CMPB #$04;
    BNE cont3m;
    ADDA #4;
    cont3m:
    LDAB DAY_OF_WEEK_AND_MONTH;
    ANDB #$02
    CMPB #$02;
    BNE cont4m;
    ADDA #8;
    cont4m:
    LDAB DAY_OF_WEEK_AND_MONTH;
    ANDB #$01;
    CMPB #$01;
    BNE cont5m;
    ADDA #10;
    cont5m:
    STAA VALID_MONTH;
    RTS;
    
    convertYear:
    LDAA #0;
    
    LDAB VALID_YEAR;
    ANDB #$80;
    CMPB #$80;
    BNE cont1y;
    ADDA #1;
    cont1y:
    
    LDAB VALID_YEAR;
    ANDB #$40;
    CMPB #$40;
    BNE cont2y;
    ADDA #2;
    cont2y:
    
    LDAB VALID_YEAR;
    ANDB #$20;
    CMPB #$20;
    BNE cont3y;
    ADDA #4;
    cont3y:
    
    LDAB VALID_YEAR;
    ANDB #$10;
    CMPB #$10;
    BNE cont4y;
    ADDA #8;
    cont4y:
    
    LDAB VALID_YEAR;
    ANDB #$08;
    CMPB #$08;
    BNE cont5y;
    ADDA #10;
    cont5y:
    
    LDAB VALID_YEAR;
    ANDB #$04;
    CMPB #$04;
    BNE cont6y;
    ADDA #20;
    cont6y:
    
    LDAB VALID_YEAR;
    ANDB #$02;
    CMPB #$02;
    BNE cont7y;
    ADDA #40;
    cont7y:
    
    LDAB VALID_YEAR;
    ANDB #$01;
    CMPB #$01;
    BNE cont8y;
    ADDA #80;
    cont8y:
    STAA VALID_YEAR;
    RTS;
    
    setupOutput:
    LDAB VALID_MINUTES;
    STAB MINUTES;
    LDAB VALID_HOURS;
    STAB HOURS;
    RTS
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
   
    
    
    
    
    
    
    
    
    
    
     
    
    
    
    
    
    
    
    
    