


   XREF PTH,MINUTES,SECONDS,HOURS,MCFLG,Hour12Format,chooseFormat,decToASCII,AMERICAN
   XDEF signalDecoderControl,init_intervals,testFunction,signalDecoderControl,DATE_STRING,DAY_STRING,VALID_DAYS,VALID_MONTH,VALID_YEAR,DAY_OF_WEEK


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
    MOVB #$00,AMERICAN;
    RTS;
    
    validOne:
    LDAB #$01;
    JSR putBit;
    RTI;
    
    validZero:
    LDAB #$00;
    JSR putBit;
    RTI;
    
    signalDecoderControl:
    MOVB #$80,MCFLG;
    ;If the Number of Total Polls is less than 200, we need to continue polling. 
    JSR pollSignal;
    
    LDAB STOP_BIT_FOUND;
    CMPB #$00;
    BEQ checkForStopBit;
    
    LDAB WAIT_FOR_DATA;
    CMPB #$01;
    BEQ jmpDataBuffer;
    
    LDAB TOTAL_POLLS;
    CMPB #200;
    BEQ evalWindow;
    RTI;
    
    testFunction:
    MOVW #$0000,DATA_STREAM;
    MOVW #$0F0E,DATA_STREAM+2;
    MOVW #$0C2C,DATA_STREAM+4;
    MOVW #$3860,DATA_STREAM+6;
    
    
    JSR evalBits;
    RTS;
    
    jmpDataBuffer:
    JSR checkDataBuffer;
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
    JSR evalBits;
    RTI;
    
    resetToDefault:
    MOVB #$00,STOP_BIT_FOUND;
    MOVW #$0000,DATA_STREAM;
    MOVW #$0000,DATA_STREAM+2;
    MOVW #$0000,DATA_STREAM+4;
    MOVW #$0000,DATA_STREAM+6;
    MOVB #$00,STREAM_POSITION;
    
    JSR resetInterval;

    checkForStopBit:
    LDAB TOTAL_POLLS;
    CMPB #200;
    ;Return if the total number of polls is less than 200;
    BNE returnFromStopBit;
    LDAB HIGHS;
    CMPB CONF_STOP;
    ;Throw away the interval if the confidence threshhold is not met
    BLO jmpResetInterval;
    MOVB #$01,STOP_BIT_FOUND;
    MOVB #$01,WAIT_FOR_DATA;
    MOVB #$00,TOTAL_POLLS;
    MOVW #$0000,DATA_BUFFER;
    returnFromStopBit:
    RTI;
    
    jmpResetInterval:
    JSR resetInterval;
    RTI;
    
    ;Responsible for filling the Data Buffer
    returnFromDecoder:
    LDD DATA_BUFFER;
    LSLD;
    XGDX;
    LDAB PTH;
    ANDB #$01;
    ABX;
    XGDX;
    STD DATA_BUFFER;
    RTS;

    checkDataBuffer:
    LDAB TOTAL_POLLS;
    CMPB #16;
    BLO returnFromDecoder;
    ;Count of 1s in Y
    LDD #$0000;
    XGDY;
    ;Copy of original DATA_BUFFER in X
    LDD DATA_BUFFER;
    XGDX;
    ;Loop that counts all the 1's in the Data Buffer
    count_loop:
    LDD DATA_BUFFER;
    ANDB #01
    CMPB #$00;
    BEQ continueDataBufferCheck;
    ;Increase Count by 1
    INY;
    continueDataBufferCheck:
    XGDX;
    LSRD;
    CPD #$0000;
    BEQ finished_counting;
    TFR D,X;
    BRA count_loop;
    ;Number of Highs from Data Buffer.
    finished_counting:
    XGDY;
    ;If we get 12/16 lows, we can assume, that a Data Bit has started.
    CPD #5;
    BLO startIntervals;
    ;Push out one Bit to the left and continue looking;
    LDD DATA_BUFFER;
    LSLD;
    XGDX;
    LDAB PTH;
    ANDB #$01;
    ABX;
    XGDX;
    STD DATA_BUFFER;
    RTS;
    
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
    
    
    startIntervals:
    STAB HIGHS;
    MOVB #$10,TOTAL_POLLS;
    MOVB #$00,WAIT_FOR_DATA;
    RTS;
    
    
    resetInterval:
    MOVB #$00,HIGHS;
    MOVB #$00,TOTAL_POLLS;
    RTS; 
    
    
    
    putBit:
    STAB TEMP; 
    LDD #8;
    XGDX;
    LDAA #0;
    LDAB STREAM_POSITION;
    IDIV;
    LDY #DATA_STREAM
    XGDX;
    ABY;
    XGDX;
    LDAA TEMP;
    shift_loop:
    CMPB #$00;
    BEQ continuePutting;
    LSLA;
    DECB;
    BRA shift_loop;
    
    continuePutting:
    LDAB Y;
    ABA;
    STAA Y;
    LDAB STREAM_POSITION;
    INCB;
    CMPB #60;
    BHI invalidBit;
    STAB STREAM_POSITION;:
    BRA resetInterval;
    
    invalidBit:
    JSR resetToDefault;
    
    
    
    
    ;TODO
    evalBits:
    JSR checkDateParity;
    JSR evalMinutes;
    JSR evalHours;
    JSR evalDays;
    JSR evalDayOfWeek
    JSR evalYear;
    JSR putCorrectDateAndTime;
    RTS;
    
    
    
    evalMinutes:
    LDD DATA_STREAM+2;
    LSRD;
    LSRD;
    LSRD;
    ;Here we start with BIT 20, this needs to be 1;
    ANDB #$01;
    CMPB #$01;
    BNE invalidBit;
    ;Load Data again
    LDD DATA_STREAM+2;
    LSRD;
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
    LSRD;
    ;Minute Parity now in B
    ANDB #$01;
    EORB TEMP;
    CMPB #$00;
    BEQ validBitMinute;
    JSR invalidBit;
    
    validBitMinute:
    LDD DATA_STREAM+2;
    LSRD;
    LSRD;
    LSRD;
    LSRD;
    ANDB #$FE;
    STAB VALID_MINUTES;
    
    
    evalHours:
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
    BEQ validBitHours;
    JSR invalidBit;

    validBitHours:
    LDD DATA_STREAM+3;
    LSLD;
    LSLD;
    LSLD;
    LSLD;
    LSLD;
    ANDA #$FC;
    STAA VALID_HOURS;
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
    validBit:
    RTS;
    
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
    ;After this first 4 Bits in A are now final 4 bits in B;
    LDAA VALID_MINUTES;
    LSRA;
    ANDA #$01;
    CMPA #$01;
    BNE cont1;
    ADDB #40;
    cont1:
    LDAA VALID_MINUTES;
    LSRA;
    ANDA #$02;
    CMPA #$02;
    BNE cont2;
    ADDB #20;
    cont2:
    LDAA VALID_MINUTES;
    LSRA;
    ANDA #$04;
    CMPA #$04;
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
    LDAB PTH;
    ANDB #$04;
    CMPB #$00;
    BEQ displayAmerican;
    ;Display European Time Format
    TAB;
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
    RTS;
    
    
    displayAmerican:
    LDX #N2DE;
    LDY #DAY_STRING;
    TAB;
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
    RTS
    
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
    MOVB #$00,SECONDS;
    RTS
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
   
    
    
    
    
    
    
    
    
    
    
     
    
    
    
    
    
    
    
    
    