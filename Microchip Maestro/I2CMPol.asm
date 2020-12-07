;*******************************************************************************;
;*                                                                              ;
;*  This implements a generic library functionality to support I2C Master       ;
;*  for PIC16/PIC18 family                                                      ;
;*                                                                              ;
;*                                                                              ;
;*******************************************************************************;
;* FileName:            I2CMPol.asm                                     ;        
;* Dependencies:        P16xxx.inc                                      ;
;*                      P18xxx.inc                                      ;
;*                      I2CMPol.Inc                                     ;
;*                      I2CMPol.Def                                     ;
;* Processor:           PIC16xxxx/PIC18xxxx                             ;
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
;* Vidyadhar       Feb 17, 2003    Initial Release
;* Vidyadhar       Mar 26, 2003    Modified to correct                  ;
;*                                 BaudRate calculation (V1.0)          ;
;*                                                                      ;
;***********************************************;***********************;
                                                ;
#define MSSP_MODULE                             ;Module definitions to generate error message for
#define _GEN_MODULE_ERROR                       ;Processor which do not have these module.
                                                ;
#define _ADD_PROC_INC_FILE                      ;
                                                ;
        #include "P18xxx.inc"                   ;
        #include "P16xxx.inc"                   ;
                                                ;
#define I2CMPol_Source                          ;
                                                ;                                                
        #include "I2CMPol.Inc"                  ;
                                                ;
;***********************************************;
; Baud Rate Genarator Reload value              ;
;***********************************************;    
        #ifdef  I2CM_SPEED_400K                 ;
                                                ;
_QUOTIENT    EQU    CLOCK_FREQ / (4 * .400000)-1;to convert the freq in 400KHz            
_REMAINDER   EQU    CLOCK_FREQ % (4 * .400000)  ;
                                                ;
        #else   ;I2CM_SPEED_100K                ;
                                                ;
_QUOTIENT    EQU    CLOCK_FREQ / (4 * .100000)-1;to convert the freq in 100KHz            
_REMAINDER   EQU    CLOCK_FREQ % (4 * .100000)  ;
                                                ;
        #endif                                  ;
                                                ;
        #if     _REMAINDER != 0                 ;
                                                ;
_I2CM_BAUD_COUNT    EQU     _QUOTIENT + 1       ;_I2CMBAUDCOUNT is nearest to ((fosc/4)/I2CMSPEED)-1,
                                                ; which has to be written in SSPADD.
        #else   ;_REMAINDER = 0                 ;
                                                ;
_I2CM_BAUD_COUNT    EQU    _QUOTIENT            ;_I2CMBAUDCOUNT = ((fosc/4)/I2CMSPEED)-1, which has to be written in SSPADD.
                                                ;which has to be written in SSPADD.
        #endif                                  ;
                                                ;
;-----------------------------------------------;
        #if     _I2CM_BAUD_COUNT > 255          ;
                                                ;
        ERROR "At this System frequency, the given I2C frequency is not attainable."
                                                ;
        #endif                                  ;
                                                ;
        #if     _I2CM_BAUD_COUNT < 2            ;
                                                ;
        ERROR "At this System frequency, the given I2C frequency is not attainable."
                                                ;
        #endif                                  ;
                                                ;
;***********************************************;

;***********************************************;
                                                ;
                                                ;
        #ifdef  _PIC18xxx                       ;
    #include "18I2CMP.asm"                      ;
        #endif                                  ;
                                                ;
        #ifdef  _PIC16xxx                       ;
    #include "16I2CMP.asm"                      ;
        #endif                                  ;
                                                ;
                                                ;
;***********************************************;


        end

;***********************************************;
