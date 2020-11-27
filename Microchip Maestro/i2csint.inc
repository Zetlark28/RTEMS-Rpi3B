;*******************************************************************************;
;*                                                                              ;
;*  This implements a generic library functionality to support I2C              ;
;*  for PIC16 family                                                            ;
;*  It adds additional functionality of Rx/Tx user defined Cicular buffer       ;
;*                                                                              ;
;*******************************************************************************;
;* FileName:            I2CSInt.inc                                     ;        
;* Dependencies:        I2CSInt.Def                                     ;
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
;* Vidyadhar       Feb 11, 2003    Initial Release (V1.0)               ;
;*                                                                      ;
;***********************************************************************;

    #ifndef __I2CSInt_INC                       ;Check if inc file already included
                                                ;
        #define __I2CSInt_INC                   ;
                                                ;
       #include "I2CSInt.Def"                   ;
                                                ;
        #ifndef I2CSInt_Source                  ;
                                                ;
       #include "P18xxx.inc"                    ;
       #include "P16xxx.inc"                    ;
;***********************************************;
        EXTERN  vI2CSIntStatus                  ;
                                                ;
        EXTERN  I2CSIntInit                     ;
        EXTERN  I2CSIntPut                      ;
        EXTERN  I2CSIntGet                      ;
        EXTERN  I2CSIntISR                      ;
        EXTERN  I2CSIntDiscardRxBuf             ;
                                                ;
;***********************************************;
        #else                                   ;
                                                ;
        GLOBAL  vI2CSIntStatus                  ;
                                                ;
;***********************************************;
        #endif                                  ;
                                                ;
;***********************************************;
;I2CSIntStatus register bits                    ;
;***********************************************;
                                                ;
I2CSTx              EQU     0                   ;1-Transmission is going on, 0-Reception is going on
I2CSAddressLow      EQU     1                   ;Lower byte of Address has to be loaded
I2CSTxBufFull       EQU     2                   ;I2CS TxBuffer Full
I2CSTxBufEmpty      EQU     3                   ;I2CS TxBuffer Empty
I2CSRxBufFull       EQU     4                   ;I2CS RxBuffer Full
I2CSRxBufEmpty      EQU     5                   ;I2CS RxBuffer Empty
I2CSTxBufUnderFlow  EQU     6                   ;I2CS Buffer Full
I2CSRxBufOverFlow   EQU     7                   ;I2CS Buffer Empty
                                                ;
;***********************************************;

;***********************************************************************;
; Macro: mI2CSIntDisable                                                ;
;                                                                       ;
; PreCondition: I2CMIntInit should have called.                         ;
;                                                                       ;
; Overview:                                                             ;
;       This disables I2C Slave.                                        ;
;                                                                       ;
; Input: None                                                           ;
;                                                                       ;
; Output: None                                                          ;
;                                                                       ;
; Side Effects: Bank selection bits are changed                         ;
;                                                                       ;
; Stack requirement: None                                               ;
;                                                                       ;
;***********************************************;***********************;
                                                ;
mI2CSIntDisable MACRO                           ;
                                                ;
    #ifdef  _PIC16xxx                           ;
                                                ;
        BANKSEL SSPCON                          ;
        bcf     SSPCON,SSPEN                    ;
        bsf     STATUS,RP0                      ;
        bcf     PIE1,SSPIE                      ;enable serial_sync interrupt 
                                                ;
        #if I2CS_TIMER != 0                     ;
                                                ;
        bcf     _I2CS_TMR_INT                   ;enable the timer interrupt
                                                ;
        #endif                                  ;
                                                ;
    #else                                       ;
                                                ;
        bcf     SSPCON1,SSPEN                   ;
        bcf     PIE1,SSPIE                      ;enable serial_sync interrupt 
                                                ;
        #if I2CS_TIMER != 0                     ;
                                                ;
        bcf     _I2CS_TMR_INT                   ;enable the timer interrupt
                                                ;
        #endif                                  ;
                                                ;
    #endif                                      ;
                                                ;
        ENDM                                    ;
                                                ;
;***********************************************;

        #ifdef  _PIC18xxx                       ;

        #if I2CS_TIMER == 1                     ;
                                                ;
#define _I2CS_TMR_INT_PRITY INTCON2,TMR0IP      ;Timer0 Interrupt priority
                                                ;
        #endif                                  ;
                                                ;
        #if I2CS_TIMER == 2                     ;
                                                ;
#define _I2CS_TMR_INT_PRITY IPR1,TMR1IP         ;Timer1 Interrupt priority
                                                ;
        #endif                                  ;
                                                ;
        #if I2CS_TIMER == 3                     ;
                                                ;
#define _I2CS_TMR_INT_PRITY IPR1,TMR2IP         ;Timer2 Interrupt priority
                                                ;
        #endif                                  ;
                                                ;

;***********************************************************************;
; Macro:        mSetI2CSIntHighPrior                                    ;
;                                                                       ;
; Overview:     Sets high priority for MSSP interrupt.                  ;
;                                                                       ;
; Input:        None                                                    ;
;                                                                       ;
; Output:       None                                                    ;
;                                                                       ;
; Side Effects:  None                                                   ;
;***********************************************************************;
                                                ;
mSetI2CSIntHighPriority MACRO                   ;
                                                ;
        bsf     IPR1,SSPIP                      ;High Priority for MSSP Int.
                                                ;
        #if I2CS_TIMER != 0                     ;
                                                ;
        bsf     _I2CS_TMR_INT_PRITY             ;High Priority for Timer Int.
                                                ;
        #endif                                  ;
                                                ;
        bsf     RCON,IPEN                       ;
        ENDM                                    ;
                                                ;
;***********************************************;

;***********************************************************************;
; Macro:        mSetI2CSIntLowPrior                                     ;
;                                                                       ;
; Overview:     Sets low priority for MSSP interrupt.                   ;
;                                                                       ;
; Input:        None                                                    ;
;                                                                       ;
; Output:       None                                                    ;
;                                                                       ;
; Side Effects: None                                                    ;
;***********************************************************************;
                                                ;
mSetI2CSIntLowPriority  MACRO                   ;
                                                ;
        bcf     IPR1,SSPIP                      ;Low Priority for MSSP Int.
                                                ;
        #if I2CS_TIMER != 0                     ;
                                                ;
        bcf     _I2CS_TMR_INT_PRITY             ;Low Priority for Timer Int.
                                                ;
        #endif                                  ;
                                                ;
        bsf     RCON,IPEN                       ;
                                                ;
        ENDM                                    ;
                                                ;
;***********************************************;

        #endif                                  ;


    #endif


;***********************************************;
;        END                                    ;
;***********************************************;
