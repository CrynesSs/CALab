

#include <hidef.h>                              // Common defines
#include <mc9s12dp256.h>                        // CPU specific defines

#pragma LINK_INFO DERIVATIVE "mc9s12dp256b"

void setPWMRegister(unsigned short PWMPERREG,unsigned short PWMDTYREG,unsigned short PWMPERVAL,unsigned short PWMDTYVAL){
    
}

void setupPWM(void){
    DDRP = 0xFF; //Set Port P as Output
    //Port P Interrupt Enable on Pin 1,3,5
    PIEP = 0x2A;
    //Trigger on pos. Edge of P1
    PPSP = 0x2A;// 
    //PWM Enable for 0,1 and 4,5
    PWME = 0x3F;//
    //PWM Polarity
    PWMPOL =0x00;
    //PWM Clock Select : B/SB,B/SB,A/SA,A/SA,B/SB,B/SB,A/SA,A/SA
    PWMCLK=0xFF; //Select SA for Channels 0,1/4,5 and SB for Channels 2,3/7,8
    //PWM Prescale Clock Select 4bit B , 4bit A
    PWMPRCLK=0x77; //Prescalefactor Clock A 128,Clock B 128
    //PWM Center Align Enable
    PWMCAE=0x00;
    //PWM Control switch from 8bit to 16bit concat 67,45,23,01,StopInWait,StopInFreeze,0,0
    PWMCTL=0xF0; //Concat Register 0/1,2/3,4/5,6/7
    //PWM Scale A for SA SA=A/(2*PWMSCLA)
    PWMSCLA=0x32; //PWM Scale 50, Total Prescale = 128 * 2 * 50 = 12800
    //PWM Scale B for SB SB=B/(2*PWMSCLB)
    PWMSCLB=0x01; //PWM Scale 1, Total Prescale = 128*2*1=256
    //PWM Channel Period Register Period=Clock * RegisterValue, Each Channel has its own Register
    //Magic Number here is 1875 which is 0x0753 //Sidenote:technically devisable by 3 and could use 1 register instead of connected registers, but currently not needed
    setPWMRegister(PWMPER0,PWMDTY0,0xFFFF,0xFFFF);
}

