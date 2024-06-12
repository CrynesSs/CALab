


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

;Confidence Intervals
CONF_STOP: DS.B 1 ; 191+ 0xBF
CONF_I0: DS.B 2 ; [189,171] , [0xBD,0xAB]
CONF_I1: DS.B 2 ; [169,151] , [0xA9,0x97]

.const: SECTION
N2DE: DC.B "MONTUEWEDTHUFRISATSUN"
N2DD: DC.B "MODIMIDOFRSASO"  
  


.init: SECTION

    ;**************************************************************
    ; Test function for correct Signal
    ; Parameter: - 
    ; Return: -  
    ;**************************************************************
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
    
    ;**************************************************************
    ; Inits the Parameter Values
    ; Parameter: - 
    ; Return: -  
    ;**************************************************************
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
    
    ;Init Dummy Values
    MOVB #13,HOURS;
    MOVB #37,MINUTES;
    MOVB #69,SECONDS;
    
    MOVB #13,VALID_DAYS;
    MOVB #37,VALID_MONTH;
    MOVB #69,VALID_YEAR;
    MOVB #1,DAY_OF_WEEK;
    MOVB #$00, setMode;
    RTS;

    
    ;**************************************************************
    ; Entry For the Signal Analyzer Hooked to Modulo Timer 5ms
    ; Parameter: - 
    ; Return: -  
    ;**************************************************************
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
    
    
    ;**************************************************************
    ; Evaluates the Window after 200 Polls.
    ; Parameter: - 
    ; Return: -  
    ;**************************************************************
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
    ;**************************************************************
    ; Puts a One into the Data Stream. Toggles LED 7
    ; Parameter: 
    ;   B - (Byte) - The Bit Value to put in B0 
    ; Return: -  
    ;**************************************************************
    validOne:
    LDAB #$80;
    JSR toggleLED;
    LDAB #$01;
    JSR putBit;
    RTI;
    ;**************************************************************
    ; Puts a Zero into the Data Stream. Toggles LED 6
    ; Parameter: 
    ;   B - (Byte) - The Bit Value to put in B0 
    ; Return: -  
    ;**************************************************************
    validZero:
    LDAB #$40;
    JSR toggleLED;
    LDAB #$00;
    JSR putBit;
    RTI;
    ;**************************************************************
    ; Resets all Parameters to the Default State after invalid Bit
    ; is read from the Signal
    ; Parameter: - 
    ; Return: -  
    ;**************************************************************
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
    ;**************************************************************
    ; Checks if the Stop bit is found.
    ; Parameter: - 
    ; Return: -  
    ;**************************************************************
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
    ;**************************************************************
    ; Checks the Data Buffer if a bit is starting
    ; Parameter: - 
    ; Return: -  
    ;**************************************************************
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
    ;**************************************************************
    ; Polls the Signal and adds Highs if found.
    ; Parameter: - 
    ; Return: -  
    ;**************************************************************
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
    ;**************************************************************
    ; Evaluates the Window after 200 Polls.
    ; Parameter: 
    ;   B - (Byte) - The Bit to set into the Stream at B0 
    ; Return: -  
    ;**************************************************************       
    putBit:
    XGDY;
    LDD #8;
    XGDX;
    ;Check the Stream Position. If it is higher than 58, it is invalid as 59 is the stop bit.
    LDAB STREAM_POSITION;
    CMPB #59;
    BLO isValid;
    ;Here the Stream Count is invalid;
    ;Maybe do sth here idk?idc
    isValid:
    ;Store the Bit to write in Y
    ;We need to swap the Bit to A, as the Y register loads left to right into B
    ;Put Stream Position and IDIV to get the result
    LDAA #0;
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
    CMPA #$00;
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
    STAA Y;
    ;Increase the Stream Position by 1;
    LDAB STREAM_POSITION;
    INCB;
    STAB STREAM_POSITION;
    MOVB #$00,HIGHS;
    MOVB #$00,TOTAL_POLLS;
    RTS;  
;*************************************************************************
;Eval Functions
;*************************************************************************
    ;**************************************************************
    ; Returns from the Eval. evalBits is called with a Branch, so we can RTI here.
    ; Parameter: - 
    ; Return: -  
    ;**************************************************************
    returnFromEval:
    MOVW #$0000,DATA_STREAM;
    MOVW #$0000,DATA_STREAM+2;
    MOVW #$0000,DATA_STREAM+4;
    MOVW #$0000,DATA_STREAM+6;
    MOVB #$00,STREAM_POSITION;
    MOVB #$00,HIGHS;
    MOVB #$00,TOTAL_POLLS;
    MOVB #$01,WAIT_FOR_DATA;
    RTI;
    ;**************************************************************
    ; Evaluates the Data Bits in the Stream
    ; Parameter: - 
    ; Return: -  
    ;**************************************************************
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
    ;**************************************************************
    ; Sets the "Flag" bit to 01 and returns
    ; Parameter: - 
    ; Return: -  
    ;**************************************************************
    invalidBit:
    LDAB #$01;
    RTS;
    ;**************************************************************
    ; Checks if bit 20 is set correctly;
    ; Parameter: - 
    ; Return: -  
    ;**************************************************************
    checkBit20:
    ; Read in the correct Data Stream Byte and position it
    LDD DATA_STREAM+2;
    LSRD;
    LSRD;
    LSRD;
    ; Isolate Bit 20 in A0
    ANDA #$01;
    ; If it is not one it is invalid
    CMPA #$00;
    BEQ invalidBit;
    LDAB #$00;
    RTS;
    ;**************************************************************
    ; Checks the Minute Parity
    ; Parameter: - 
    ; Return: -  
    ;**************************************************************
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
    ;**************************************************************
    ; Checks the Hour Parity
    ; Parameter: - 
    ; Return: -  
    ;**************************************************************
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
    ;**************************************************************
    ; Checks the Date Parity
    ; Parameter: - 
    ; Return: -  
    ;**************************************************************
    checkDateParity:
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
    LBRA invalidBit;
    validBit:
    LDAB #$00;
    RTS;
    ;Counts the number of ones in 2 Bytes/1Word
    ;Inputs: D->Word to analyze
    ;**************************************************************
    ; Checks the Date Parity
    ; Parameter: 
    ;   D - (Word) - The Word to Count the number of "1" inside 
    ; Return:
    ;   Y - (Word) - The Number of "1" inside D   
    ;**************************************************************
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
    ;**************************************************************
    ; Sets the VALID_MINUTES to the correct Stream Bits;
    ; Parameter: - 
    ; Return: -  
    ;**************************************************************
    evalMinutes:
    LDD DATA_STREAM+2;
    LSRD;
    LSRD;
    LSRD;
    ANDB #$FE;
    STAB VALID_MINUTES;
    LDAB #$00;
    RTS;
    ;**************************************************************
    ; Sets the VALID_HOURS to the correct Stream Bits;
    ; Parameter: - 
    ; Return: -  
    ;**************************************************************
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
    ;**************************************************************
    ; Sets the VALID_DAYS to the correct Stream Bits;
    ; Parameter: - 
    ; Return: -  
    ;**************************************************************
    evalDays:
    LDD DATA_STREAM+4;
    LSLD;
    LSLD;
    LSLD;
    LSLD;
    ANDA #$FC
    STAA VALID_DAYS;
    RTS;
    ;**************************************************************
    ; Sets the DAY_OF_WEEK_AND_MONTH to the correct Stream Bits;
    ; Parameter: - 
    ; Return: -  
    ;**************************************************************
    evalDayOfWeek:
    LDD DATA_STREAM+5;
    LSLD;
    LSLD;
    STAA DAY_OF_WEEK_AND_MONTH;
    RTS;
    ;**************************************************************
    ; Sets the VALID_YEAR to the correct Stream Bits;
    ; Parameter: - 
    ; Return: -  
    ;**************************************************************
    evalYear:
    LDD DATA_STREAM+6;
    LSLD;
    LSLD;
    STAA VALID_YEAR;
    RTS;
;****************************************************************
;Functions that convert Data from Bits to correct Values
;****************************************************************
    ;**************************************************************
    ; Converts the Data to usuable Values
    ; Parameter: - 
    ; Return: -  
    ;**************************************************************
    putCorrectDateAndTime:
    JSR convertMinutes;
    JSR convertHours;
    JSR convertDays;
    JSR convertDayOfWeek;
    JSR convertMonth;
    JSR convertYear;
    JSR setupOutput;
    RTS;
    ;**************************************************************
    ; Converts Minute Bits to VALID_MINUTES Value
    ; Parameter: - 
    ; Return: -  
    ;**************************************************************
    convertMinutes:
    ; Minute Count
    LDAB #0;
    ; Minute Bit 0
    LDAA VALID_MINUTES;
    ANDA #$80;
    CMPA #$80;
    BNE cont1;
    ADDB #1;
    ; Minute Bit 1
    cont1:
    LDAA VALID_MINUTES;
    ANDA #$40;  
    CMPA #$40;
    BNE cont2;
    ADDB #2;
    ; Minute Bit 2
    cont2:
    LDAA VALID_MINUTES;
    ANDA #$20;
    CMPA #$20;
    BNE cont3;
    ADDB #4;
    ; Minute Bit 3
    cont3:
    LDAA VALID_MINUTES;
    ANDA #$10;
    CMPA #$10;
    BNE cont4;
    ADDB #8;
    ; Minute Bit 4
    cont4: 
    LDAA VALID_MINUTES;    
    ANDA #$08;
    CMPA #$08;
    BNE cont5;
    ADDB #10;
    ; Minute Bit 5
    cont5:
    LDAA VALID_MINUTES;
    ANDA #$04;
    CMPA #$04;
    BNE cont6;
    ADDB #20;
    ; Minute Bit 6
    cont6:
    LDAA VALID_MINUTES;
    ANDA #$02;
    CMPA #$02;
    BNE cont7;
    ADDB #40;
    ; End Minute 
    cont7:
    STAB VALID_MINUTES;
    RTS;
    ;**************************************************************
    ; Converts Hour Bits to VALID_HOURS Value
    ; Parameter: - 
    ; Return: -  
    ;**************************************************************
    convertHours:
    ; Hour Count
    LDAB #0;
    ; Hour Bit 0
    LDAA VALID_HOURS;
    ANDA #$80;
    CMPA #$80;
    BNE cont1H;
    ADDB #1;
    ; Hour Bit 1
    cont1H:
    LDAA VALID_HOURS;
    ANDA #$40;  
    CMPA #$40;
    BNE cont2H;
    ADDB #2;
    ; Hour Bit 2
    cont2H:
    LDAA VALID_HOURS;
    ANDA #$20;
    CMPA #$20;
    BNE cont3H;
    ADDB #4;
    ; Hour Bit 3
    cont3H:
    LDAA VALID_HOURS;
    ANDA #$10;
    CMPA #$10;
    BNE cont4H;
    ADDB #8;
    ; Hour Bit 4
    cont4H:
    LDAA VALID_HOURS;
    ANDA #$08;
    CMPA #$08;
    BNE cont5H;
    ADDB #10;
    ; Hour Bit 5
    cont5H:
    LDAA VALID_HOURS;
    ANDA #$04;
    CMPA #$04;
    BNE cont6H;
    ADDB #20;
    ; End Hour 
    cont6H:
    STAB VALID_HOURS;
    RTS;
    ;**************************************************************
    ; Converts Day Bits to VALID_DAYS Value
    ; Parameter: - 
    ; Return: -  
    ;**************************************************************
    convertDays:
    ;Day Count
    LDAA #0;
    ; Day Bit 0
    LDAB VALID_DAYS;
    ANDB #$80;
    CMPB #$80;
    BNE cont1d;
    ADDA #1;
     ; Day Bit 1
    cont1d:
    LDAB VALID_DAYS;
    ANDB #$40;
    CMPB #$40;
    BNE cont2d;
    ADDA #2;
    ; Day Bit 2
    cont2d:
    LDAB VALID_DAYS;
    ANDB #$20;
    CMPB #$20;
    BNE cont3d;
    ADDA #4;
    ; Day Bit 3
    cont3d:
    LDAB VALID_DAYS;
    ANDB #$10;
    CMPB #$10;
    BNE cont4d;
    ADDA #8
    ; Day Bit 4
    cont4d:
    LDAB VALID_DAYS;
    ANDB #$08;
    CMPB #$08;
    BNE cont5d;
    ADDA #10;
    ; Day Bit 5
    cont5d:
    LDAB VALID_DAYS;
    ANDB #$04;
    CMPB #$04;
    BNE cont6d;
    ADDA #20;
    ; End Day 
    cont6d:
    STAA VALID_DAYS;
    RTS;
    ;**************************************************************
    ; Converts DAY_OF_WEEK_AND_MONTH Bits to DAY_OF_WEEK Value
    ; Parameter: - 
    ; Return: -  
    ;************************************************************** 
    convertDayOfWeek:
    ; Day of Week Count
    LDAA #0;
    ; Day of Week Bit 0
    LDAB DAY_OF_WEEK_AND_MONTH;
    ANDB #$80;
    CMPB #$80;
    BNE cont1dow;
    ADDA #1;
    ; Day of Week Bit 1
    cont1dow:
    LDAB DAY_OF_WEEK_AND_MONTH;
    ANDB #$40;
    CMPB #$40;
    BNE cont2dow;
    ADDA #2;
    cont2dow:
    ; Day of Week Bit 2
    LDAB DAY_OF_WEEK_AND_MONTH;
    ANDB #$20;
    CMPB #$20;
    BNE cont3dow;
    ADDA #4;
    ; End Day of Week
    cont3dow:
    STAA DAY_OF_WEEK;
    RTS;
    ;**************************************************************
    ; Converts DAY_OF_WEEK_AND_MONTH Bits to VALID_MONTH Value
    ; Parameter: - 
    ; Return: -  
    ;**************************************************************
    convertMonth:
    ;Month Count
    LDAA #0;
    ; Month Bit 0
    LDAB DAY_OF_WEEK_AND_MONTH;
    ANDB #$10
    CMPB #$10;
    BNE cont1m;
    ADDA #1;
    ; Month Bit 1
    cont1m:
    LDAB DAY_OF_WEEK_AND_MONTH;
    ANDB #$08
    CMPB #$08;
    BNE cont2m;
    ADDA #2;
    ; Month Bit 2
    cont2m:
    LDAB DAY_OF_WEEK_AND_MONTH;
    ANDB #$04
    CMPB #$04;
    BNE cont3m;
    ADDA #4;
    ; Month Bit 3
    cont3m:
    LDAB DAY_OF_WEEK_AND_MONTH;
    ANDB #$02
    CMPB #$02;
    BNE cont4m;
    ADDA #8;
    ; Month Bit 4
    cont4m:
    LDAB DAY_OF_WEEK_AND_MONTH;
    ANDB #$01;
    CMPB #$01;
    BNE cont5m;
    ADDA #10;
    ; End Month 
    cont5m:
    STAA VALID_MONTH;
    RTS;
    ;**************************************************************
    ; Converts Year Bits to VALID_YEAR Value
    ; Parameter: - 
    ; Return: -  
    ;**************************************************************
    convertYear:
    ;Year Count
    LDAA #0;
    ;Year Bit 0
    LDAB VALID_YEAR;
    ANDB #$80;
    CMPB #$80;
    BNE cont1y;
    ADDA #1;
    ;Year Bit 1
    cont1y:
    LDAB VALID_YEAR;
    ANDB #$40;
    CMPB #$40;
    BNE cont2y;
    ADDA #2;
    ;Year Bit 2
    cont2y:
    LDAB VALID_YEAR;
    ANDB #$20;
    CMPB #$20;
    BNE cont3y;
    ADDA #4;
    ;Year Bit 3
    cont3y:
    LDAB VALID_YEAR;
    ANDB #$10;
    CMPB #$10;
    BNE cont4y;
    ADDA #8;
    ;Year Bit 4
    cont4y:
    LDAB VALID_YEAR;
    ANDB #$08;
    CMPB #$08;
    BNE cont5y;
    ADDA #10;
    ;Year Bit 5
    cont5y:
    LDAB VALID_YEAR;
    ANDB #$04;
    CMPB #$04;
    BNE cont6y;
    ADDA #20;
    ;Year Bit 6
    cont6y:
    LDAB VALID_YEAR;
    ANDB #$02;
    CMPB #$02;
    BNE cont7y;
    ADDA #40;
    ;Year Bit 7
    cont7y:
    LDAB VALID_YEAR;
    ANDB #$01;
    CMPB #$01;
    BNE cont8y;
    ADDA #80;
    ;End Year 
    cont8y:
    STAA VALID_YEAR;
    RTS;
    ;**************************************************************
    ; Sets the Clock
    ; Parameter: - 
    ; Return: -  
    ;**************************************************************
    setupOutput:
    LDAB VALID_MINUTES;
    STAB MINUTES;
    LDAB VALID_HOURS;
    STAB HOURS;
    RTS
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
   
    
    
    
    
    
    
    
    
    
    
     
    
    
    
    
    
    
    
    
    