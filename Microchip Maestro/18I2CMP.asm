;*******************************************************************************;
;*                                                                              ;
;*  This implements a generic library functionality to support I2C Master       ;
;*  for PIC18 family                                                            ;
;*                                                                              ;
;*                                                                              ;
;*******************************************************************************;
;* FileName:            18I2CMP.asm                                     ;        
;* Dependencies:        P18xxx.inc                                      ;
;*                      I2CMPol.Def                                     ;
;*                      I2CMPol.Inc                                     ;
;* Processor:           PIC18xxxx                                       ;
;* Assembler:           MPASMWIN 02.70.02 or higher                     ;
;* Linker:              MPLINK 2.33.00 or higher                        ;
;* Company:             Microchip Technology, Inc.                      ;
;*                                                                      ;
;* Software License Agreement                                           ;
;*                                                                      ;
;* The software supplied herewith by Microchip Technology Incorporated  ;
;* (the "Company") for its PICmicro® Microcontroller is Polended and    ;
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
;* Vidyadhar       Feb 17, 2003    Initial Release (V1.0)               ;
;*                                                                      ;
;***********************************************************************;


;***********************************************************************;
_I2CMPOLCODE    CODE                                                    ;
                                                                        ;
;***********************************************************************;
; Function: I2CMPolInit                                                 ;
;                                                                       ;
; PreCondition: None                                                    ;
;                                                                       ;
; Overview:                                                             ;
;       This routine is used for MSSP Module Initialization.            ;
;       It initializes Module according to compile time selection       ;
;                                                                       ;
; Input: MpAM options                                                   ;
;                                                                       ;
;                                                                       ;
; Output: None                                                          ;
;                                                                       ;
; Side Effects: 'W' register is changed                                 ;
;                                                                       ;
; Stack requirement: 1 level deep                                       ;
;                                                                       ;
;***********************************************;***********************;
                                                ;
I2CMPolInit:                                    ;
                                                ;
        GLOBAL  I2CMPolInit                     ;
                                                ;
        movlw   028h                            ;Enable MSSP module and Master mode
        movwf   SSPCON1                         ;
                                                ;
        movlw   _I2CM_BAUD_COUNT                ;
        movwf   SSPADD                          ;loading SSPADD with baudrate generator
                                                ;reloading value
                                                ;
        return                                  ;
                                                ;
;***********************************************;




;***********************************************************************;
; Function: I2CMPolPut                                                  ;
;                                                                       ;
; PreCondition: I2CMPolStart should be called.                          ;
;                                                                       ;
; Overview:                                                             ;
;       This sends data byte over I2C Bus and checks write collision.   ;
;                                                                       ;
; Input: 'W' Register                                                   ;
;                                                                       ;
; Output: 'W' Register                                                  ;
;                                                                       ;
; Side Effects: 'W' register is changed                                 ;
;                                                                       ;
; Stack requirement: 1 level deep                                       ;
;                                                                       ;
;***********************************************;***********************;
                                                ;
I2CMPolPut:                                     ;
                                                ;
        GLOBAL  I2CMPolPut                      ;
                                                ;
        movwf   SSPBUF                          ;
                                                ;
        btfss   SSPCON1,WCOL                    ;
        retlw   000h                            ;
                                                ;
        bcf     SSPCON1,WCOL                    ;
        retlw   I2CMErrWriteCollision           ;indicates Write Collision Error
                                                ;
;***********************************************;        



;***********************************************************************;
; Function: I2CMPolIsAckReceived                                        ;
;                                                                       ;
; PreCondition: I2CMPolPut should have called.                          ;
;                                                                       ;
; Overview:                                                             ;
;       This checks acknowledge has received.                           ;
;                                                                       ;
; Input: None                                                           ;
;                                                                       ;
; Output: 'W' Register                                                  ;
;                                                                       ;
; Side Effects: 'W' register is changed                                 ;
;                                                                       ;
; Stack requirement: 1 level deep                                       ;
;                                                                       ;
;***********************************************;***********************;
                                                ;
I2CMPolIsAckReceived:                           ;
                                                ;
        GLOBAL  I2CMPolIsAckReceived            ;
                                                ;
        btfsc   SSPCON2,ACKSTAT                 ;
        retlw   I2CMErrNoAck                    ;indicates No Acknowledge received
                                                ;
        retlw   000h                            ;
                                                ;
;***********************************************;        



;***********************************************************************;
; Function: I2CMPolGet                                                  ;
;                                                                       ;
; PreCondition: I2CMPolPut should have called.                          ;
;                                                                       ;
; Overview:                                                             ;
;       This reads a data byte from the buffer.                         ;
;                                                                       ;
; Input: None                                                           ;
;                                                                       ;
; Output: 'W' Register                                                  ;
;                                                                       ;
; Side Effects: 'W' register is changed                                 ;
;                                                                       ;
; Stack requirement: 1 level deep                                       ;
;                                                                       ;
;***********************************************;***********************;
                                                ;
I2CMPolGet:                                     ;
                                                ;
        GLOBAL  I2CMPolGet                      ;
                                                ;
        movf    SSPBUF,w                        ;
                                                ;
        return                                  ;
                                                ;
;***********************************************;        



;***********************************************************************;
; Function: I2CMPolIsDataReady                                          ;
;                                                                       ;
; PreCondition: SPIMPOlPut should have been called.                     ;
;                                                                       ;
; Overview:                                                             ;
;       This tells weather the Data is received                         ;
;        If data over flow has occurred it indicates it.                ; 
;                                                                       ;
; Input: None                                                           ;
;                                                                       ;
; Output: 'W' Register                                                  ;
;                                                                       ;
; Side Effects: Bank selection bits and 'W' register are changed        ;
;                                                                       ;
; Stack requirement: 1 level deep                                       ;
;                                                                       ;
;***********************************************;***********************;
                                                ;        
I2CMPolIsDataReady:                             ;
        GLOBAL  I2CMPolIsDataReady              ;
                                                ;
        btfsc   SSPCON1,SSPOV                   ;Checks is over flow has occured
        goto    I2COverRxErr                    ;
                                                ;
        #ifndef I2CM_BLOCKING_FUNCTION          ;
                                                ;
        btfss   SSPSTAT,BF                      ;Checks transmission/reception in progress
        retlw   I2CMDataNotReady                ;Indicates In progress
                                                ;
        retlw   000h                            ;Indicates Over
                                                ;
        #else                                   ;
                                                ;
I2CMWaitRxOver                                  ;
        btfss   SSPSTAT,BF                      ;
        goto    I2CMWaitRxOver                  ;Wait for a data byte reception
                                                ;
        return                                  ;
                                                ;
        #endif                                  ;
                                                ;
I2COverRxErr                                    ;
        bcf     SSPCON1,SSPOV                   ;
        retlw   I2CMErrRxDataOverFlow           ;Indicates Over flow
                                                ;
;***********************************************;



;***********************************************************************;
; Function: I2CMPolIsIdle                                               ;
;                                                                       ;
; PreCondition: Must be after every I2CMPol functions and macros        ;
;        except I2CMPolGet                                              ;
;                                                                       ;
; Overview:                                                             ;
;       This checks whether the I2C Bus is Idle or not.                 ;
;                                                                       ;
; Input: None                                                           ;
;                                                                       ;
; Output: 'W' Register                                                  ;
;                                                                       ;
; Side Effects: 'W' register is changed                                 ;
;                                                                       ;
; Stack requirement: 1 level deep                                       ;
;                                                                       ;
;***********************************************;***********************;
                                                ;
I2CMPolIsIdle:                                  ;
        GLOBAL  I2CMPolIsIdle                   ;
                                                ;
        #ifndef I2CM_BLOCKING_FUNCTION          ;
                                                ;
        movf    SSPCON2,w                       ;
        andlw   01fh                            ;Checks SEN,PEN,RSEN,RCEN,ACKEN
                                                ;
        btfss   STATUS,Z                        ;
        retlw   I2CMBusNotIdle                  ;Indicates Bus is not Idle
                                                ;
        btfsc   SSPSTAT,R_W                     ;Checks transmission in progress
        retlw   I2CMBusNotIdle                  ;Indicates Bus is not Idle
                                                ;
        retlw   000h                            ;Indicates Bus is Idle
                                                ;
                                                ;
        #else                                   ;
                                                ;
I2CMSPRxANotOver                                ;
        movf    SSPCON2,w                       ;
        andlw   01fh                            ;Checks SEN,PEN,RSEN,RCEN,ACKEN
                                                ;
        btfss   STATUS,Z                        ;
        goto    I2CMSPRxANotOver                ;Indicates Bus is not Idle
                                                ;
I2CMTxNotOver                                   ;
        btfsc   SSPSTAT,R_W                     ;Checks transmission in progress
        goto    I2CMTxNotOver                   ;Indicates Bus is not Idle
                                                ;
        return                                  ;
                                                ;
        #endif                                  ;
                                                ;
;***********************************************;



        #ifdef  I2CM_MULTI_MASTER

;***********************************************************************;
; Function: I2CMPolIsBusCollision                                       ;
;                                                                       ;
; PreCondition: Must be called after every I2CMPol functions and macros ;        
;                in multimater mode. This portion of the code will      ;
;                be assembled only for multi-master mode                ;
; Overview:                                                             ;
;       This checks whether the I2C Bus Collision has occured or not.   ;
;                                                                       ;
; Input: None                                                           ;
;                                                                       ;
; Output: 'W' Register                                                  ;
;                                                                       ;
; Side Effects: 'W' register is changed                                 ;
;                                                                       ;
; Stack requirement: 1 level deep                                       ;
;                                                                       ;
;***********************************************;***********************;
                                                ;
I2CMPolIsBusCollision:                          ;
        GLOBAL  I2CMPolIsBusCollision           ;
                                                ;
        btfss   PIR2,BCLIF                      ;
        retlw   000h                            ;
                                                ;
        bcf     PIR2,BCLIF                      ;
        retlw   I2CMErrBusCollision             ;Indicates Bus Collision has occured
                                                ;
;***********************************************;

        #endif



;***********************************************;
;***********************************************;


