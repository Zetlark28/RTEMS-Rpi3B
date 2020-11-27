;*******************************************************************************;
;*                                                                              ;
;*  This implements a generic library functionality to support I2C              ;
;*  for PIC16 family                                                            ;
;*  It adds additional functionality of Rx/Tx user defined Cicular buffer       ;
;*                                                                              ;
;*******************************************************************************;
;* FileName:            I2CSInt.asm                                     ;        
;* Dependencies:        P16xxx.inc                                      ;
;*                      P18xxx.inc                                      ;
;*                      I2CSInt.Inc                                     ;
;*                      I2CSInt.Def                                     ;
;* Processor:           PIC16xxxx/PIC18xxxx                             ;
;* Assembler:           MPASMWIN 02.70.02 or higher                     ;
;* Linker:              MPLINK 2.33.00 or higher                        ;
;* Company:             Microchip Technology, Inc.                      ;
;*                                                                      ;
;* Software License Agreement                                           ;
;*                                                                      ;
;* The software supplied herewith by Microchip Technology Incorporated  ;
;* (the "Company") for its PICmicro® Microcontroller is intended and    ;
;* supplied to you, the Company's customer, for use solely and          ;
;* exclusively on Microchip PICmicro Microcontroller products. The      ;
;* software is owned by the Company and/or its supplier, and is         ;
;* protected under applicable copyright laws. All rights are reserved.  ;
;* Any use in violation of the foregoing restrictions may subject the   ;
;* user to criminal sanctions under applicable laws, as well as to      ;
;* civil liability for the breach of the terms and conditions of this   ;
;* license.                                                             ;
;*                                                                      ;
;* THIS SOFTWARE IS PROVIDED IN AN "AS IS" CONDITION. NO WARRANTIES,    ;
;* WHETHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING, BUT NOT LIMITED    ;
;* TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A          ;
;* PARTICULAR PURPOSE APPLY TO THIS SOFTWARE. THE COMPANY SHALL NOT,    ;
;* IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL OR           ;
;* CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.                    ;
;*                                                                      ;
;*                                                                      ;
;*                                                                      ;
;* Author               Date            Comment                         ;
;*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
;* Vidyadhar       Mar 14, 2003    Initial Release (V1.0)               ;
;*                                                                      ;
;***********************************************;***********************;
                                                ;
#define MSSP_MODULE                             ;Module definition to generate error message for
#define SSP_MODULE                              ;Processor which do not have this module.
#define BSSP_MODULE                             ;
                                                ;
#define _ADD_PROC_INC_FILE                      ;
                                                ;
       #include "P18xxx.inc"                    ;
       #include "P16xxx.inc"                    ;
                                                ;
#define I2CSInt_Source                          ;
                                                ;
       #include "I2CSInt.inc"                   ;
                                                ;
                                                ;
;***********************************************;
                                                ;
        #ifdef  _PIC18xxx                       ;
                                                ;
I2CSSV      UDATA_ACS                           ;
                                                ;
        #else                                   ;
                                                ;
I2CSSV      UDATA_SHR                           ;
                                                ;
        #endif                                  ;
                                                ;
vI2CSIntStatus      RES     1                   ;I2C Slave Communication Status/Error Register
                                                ;
I2CSSV1     UDATA                               ;
                                                ;
_vI2CSIntTxBufRdPtr RES     1                   ;I2CS Buffer Read Pointer
_vI2CSIntTxBufWrPtr RES     1                   ;I2CS Buffer Write Pointer
_vI2CSIntRxBufRdPtr RES     1                   ;I2CS Buffer Read Pointer
_vI2CSIntRxBufWrPtr RES     1                   ;I2CS Buffer Write Pointer
                                                ;
_vI2CSIntTempReg    RES     1                   ;For temporary use
_vI2CSTemp          RES     1                   ;For temporary use
_vI2CSTemp1         RES     1                   ;For temporary use
                                                ;
_vI2CSIntDupFSR     RES     1                   ;Storage for FSR/FSR0L
                                                ;
        #ifdef  _PIC18xxx                       ;
                                                ;
_vI2CSIntDupFSRH    RES     1                   ;Storage for FSR0H
                                                ;
        #endif                                  ;
                                                ;
I2CSV        UDATA                              ;
                                                ;
vI2CSIntTxBuffer    RES     I2CS_TX_BUFFER_LENGTH  ;I2CS TxBuffer
vI2CSIntRxBuffer    RES     I2CS_RX_BUFFER_LENGTH  ;I2CS RxBuffer
                                                ;
;***********************************************;
    #if I2CS_TIMER == 1                         ;
                                                ;
        #ifndef TMR0L                           ;
                                                ;
TMR0L   equ     TMR0                            ;
                                                ;
        #endif                                  ;
                                                ;
        #ifndef TMR0H                           ;
                                                ;
TMR0H   equ     TMR0                            ;
                                                ;
        #endif                                  ;
                                                ;
        #ifndef TMR0IF                          ;
                                                ;
TMR0IF  equ     T0IF                            ;
                                                ;
        #endif                                  ;
                                                ;
        #ifndef TMR0IE                          ;
                                                ;
TMR0IE  equ     T0IE                            ;
                                                ;
        #endif                                  ;
                                                ;
#define _I2CS_TMR_LOW       TMR0L               ;Timer0 Reg_Low
#define _I2CS_TMR_HIGH      TMR0H               ;Timer0 Reg_High
#define _I2CS_TMR_INT_FLAG  INTCON,TMR0IF       ;Timer0 Interrupt flag
#define _I2CS_TMR_INT       INTCON,TMR0IE       ;Timer0 Interrupt
                                                ;
    #endif                                      ;
                                                ;
        #if I2CS_TIMER == 2                     ;
                                                ;
#define _I2CS_TMR_LOW       TMR1L               ;Timer1 Reg_Low
#define _I2CS_TMR_HIGH      TMR1H               ;Timer1 Reg_High
#define _I2CS_TMR_INT_FLAG  PIR1,TMR1IF         ;Timer1 Interrupt flag
#define _I2CS_TMR_INT       PIE1,TMR1IE         ;Timer1 Interrupt
                                                ;
        #endif                                  ;
                                                ;
        #if I2CS_TIMER == 3                     ;
                                                ;
#define _I2CS_TMR_LOW       TMR2L               ;Timer2 Reg_Low
#define _I2CS_TMR_HIGH      TMR2H               ;Timer2 Reg_High
#define _I2CS_TMR_INT_FLAG  PIR1,TMR2IF         ;Timer2 Interrupt flag
#define _I2CS_TMR_INT       PIE1,TMR2IE         ;Timer2 Interrupt
                                                ;
        #endif                                  ;
                                                ;
;***********************************************;
                                                ;
                                                ;
        #ifdef  _PIC18xxx                       ;
    #include "18I2CSI.asm"                      ;
        #endif                                  ;
                                                ;
        #ifdef  _PIC16xxx                       ;
    #include "16I2CSI.asm"                      ;
        #endif                                  ;
                                                ;
                                                ;
;***********************************************;

;***********************************************;
        END
;***********************************************;
