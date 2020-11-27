;*******************************************************************************;
;*                                                                              ;
;*  This implements a generic library functionality to support I2C Slave        ;
;*  for PIC16 family                                                            ;
;*  It adds additional functionality of Rx/Tx user defined Cicular buffer       ;
;*                                                                              ;
;*******************************************************************************;
;* FileName:            16I2CSI.asm                                     ;        
;* Dependencies:        P16xxx.inc                                      ;
;*                      I2CSInt.Def                                     ;
;*                      I2CSInt.Inc                                     ;
;* Processor:           PIC16xxxx                                       ;
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
;***********************************************************************;


;***********************************************************************;
;_I2CSINTCODE                                                           ;
;***********************************************************************;

                                                                        ;
_I2CSINTINIT   CODE                                                     ;
;***********************************************************************;
; Function: I2CSIntInit                                                 ;
;                                                                       ;
; PreCondition: TRIS bits of the SCL,SDA are to be made i/p and         ;
;               If Timer is used for error recovery, it has to be       ;
;               initialized.                                            ;
;                                                                       ;
; Overview:                                                             ;
;       This routine is used for MSSP/SSP/BSSP Module Initialization    ;
;       It initializes Module according to compile time selection and   ;
;       flushes the Rx and Tx buffer. It clears all I2C errors          ;
;                                                                       ;
; Input: MpAM options                                                   ;
;                                                                       ;
;                                                                       ;
; Output: None                                                          ;
;                                                                       ;
; Side Effects: Bank selection bits and 'W' register are changed        ;
;                                                                       ;
; Stack requirement: 1 level deep                                       ;
;                                                                       ;
;***********************************************;***********************;
                                                ;
I2CSIntInit:                                    ;
                                                ;
        GLOBAL  I2CSIntInit                     ;
                                                ;
    #if HIGH(I2CS_SELF_ADDRESS) == 0            ;If the address is 7Bit
                                                ;
        #if I2CS_SELF_ADDRESS > 0xef            ;
                                                ;
        ERROR   "The Slave Address entered is invalid"
                                                ;
        #endif                                  ;
                                                ;
        movlw   036h                            ;select 7bit slave mode
                                                ;enable the clock line
    #else                                       ;If the address is 10Bit
                                                ;
        #if (HIGH(I2CS_SELF_ADDRESS) & 0xf8 != 0xf0   ;
                                                ;
        ERROR   "The Higher byte of Slave Address entered is invalid"
                                                ;
        #endif                                  ;
                                                ;
        movlw   037h                            ;select 10bit slave mode
                                                ;enable the clock line
    #endif                                      ;
                                                ;
        BANKSEL SSPCON                          ;
        movwf   SSPCON                          ;
                                                ;
;...............................................;
        #ifdef  _MSSP_MODULE_CLOCK_STRETCH      ;if Module is MSSP with Clock stretch feature
                                                ;
        bsf     STATUS,RP0                      ;
        bsf     SSPCON2,SEN                     ;enable clock stretch
                                                ;
        #endif                                  ;
                                                ;
;...............................................;
    #ifdef I2CS_GEN_CALL_EN                     ;If General call is selected
                                                ;        
        #ifdef  _MSSP_MODULE_CLOCK_STRETCH      ;if Module is MSSP with Clock stretch feature
                                                ;
        bsf     SSPCON2,GCEN                    ;enable general call
                                                ;
        #else                                   ;
                                                ;
            #ifdef  _MSSP_MODULE                ;if Module is MSSP
                                                ;
        bsf     SSPCON2,GCEN                    ;enable general call
                                                ;
            #else                               ;if module is not MSSP
                                                ;display
        MESSG   "This Processor cannot respond to General Call"
                                                ;
            #endif                              ;
        #endif                                  ;
    #endif                                      ;
                                                ;
;...............................................;
        #if HIGH(I2CS_SELF_ADDRESS) == 0        ;If the address is 7Bit
                                                ;
        movlw   I2CS_SELF_ADDRESS               ;
                                                ;
        #else                                   ;If the address is 10Bit
                                                ;
        bcf     vI2CSIntStatus,I2CSAddressLow   ;indicates next address update to be lower byte
        movlw   HIGH(I2CS_SELF_ADDRESS)         ;
                                                ;
        #endif                                  ;
                                                ;
        BANKSEL SSPADD                          ;
        movwf   SSPADD                          ;
                                                ;
;...............................................;
        bcf     STATUS,RP0                      ;
        bsf     INTCON,PEIE                     ;
        bsf     INTCON,GIE                      ;
                                                ;
        bsf     STATUS,RP0                      ;
        bsf     PIE1,SSPIE                      ;enable serial_sync interrupt 
                                                ;
;...............................................;
        BANKSEL _vI2CSIntTxBufWrPtr             ;
        clrf    _vI2CSIntTxBufWrPtr             ;
        clrf    _vI2CSIntTxBufRdPtr             ;
        clrf    _vI2CSIntRxBufWrPtr             ;
        clrf    _vI2CSIntRxBufRdPtr             ;
        clrf    vI2CSIntStatus                  ;
        bsf     vI2CSIntStatus,I2CSTxBufEmpty   ;
        bsf     vI2CSIntStatus,I2CSRxBufEmpty   ;
                                                ;
        #if I2CS_TIMER != 0                     ;
                                                ;
        clrf    _I2CS_TMR_HIGH                  ;
        clrf    _I2CS_TMR_LOW                   ;
                                                ;
        #endif                                  ;
;...............................................;
                                                ;
        return                                  ;
                                                ;
;***********************************************;




_I2CSINTPUT   CODE                                                      ;
;***********************************************************************;
; Function: I2CSIntPut                                                  ;
;                                                                       ;
; PreCondition: I2CSIntInit should have been called.                    ;        
;                                                                       ;
; Overview:                                                             ;
;       This writes data into buffer .                                  ;
;                                                                       ;
; Input: 'W' Register                                                   ;
;                                                                       ;
; Output: None                                                          ;
;                                                                       ;
; Side Effects: Bank selection bits and 'W' register are changed        ;
;                                                                       ;
; Stack requirement: 1 level deep                                       ;
;                                                                       ;
;***********************************************;***********************;
                                                ;
I2CSIntPut:                                     ;
                                                ;
        GLOBAL  I2CSIntPut                      ;
                                                ;
        btfss   vI2CSIntStatus,I2CSTxBufUnderFlow ;check whether under flow has occured
        goto    _I2CSIntWrTxBuf                 ;if not write in buffer
                                                ;
        BANKSEL SSPSTAT                         ;
        btfss   SSPSTAT,R_W                     ;check weather Tx or Rx
        goto    _I2CSIntWrTxBuf                 ;if not Tx write in buffer
                                                ;
        bcf     vI2CSIntStatus,I2CSTxBufUnderFlow ;clear under flow flag
        bcf     STATUS,RP0                      ;
        movwf   SSPBUF                          ;initiate transmission
                                                ;
        #if I2CS_TIMER != 0                     ;
                                                ;
        clrf    _I2CS_TMR_HIGH                  ;
        clrf    _I2CS_TMR_LOW                   ;
                                                ;
        #endif                                  ;
                                                ;
        bsf     SSPCON,CKP                      ;release the clock line
        return                                  ;
                                                ;
;***********************************************;        
_I2CSIntWrTxBuf:                                ;
        btfsc   vI2CSIntStatus,I2CSTxBufFull    ;
        return                                  ;
                                                ;        
        BANKSEL _vI2CSIntTempReg                ;
        movwf   _vI2CSIntTempReg                ;save the wreg content (data) in temflg
                                                ;
        movf    FSR,w                           ;save FSR
        movwf   _vI2CSIntDupFSR                 ;
                                                ;
        movlw   vI2CSIntTxBuffer                ;load wreg with write pointer address
        addwf   _vI2CSIntTxBufWrPtr,w           ;
                                                ;
        movwf   FSR                             ;increment write pointer
        movf    _vI2CSIntTempReg,w              ;read data from SSPBUF
        movwf   INDF                            ;move wreg content to write pointer pointing location
                                                ;
        movf    _vI2CSIntDupFSR,w               ;retrive FSR
        movwf   FSR                             ;
                                                ;
        incf    _vI2CSIntTxBufWrPtr,f           ;increment write pointer
        movlw   I2CS_TX_BUFFER_LENGTH           ;
        xorwf   _vI2CSIntTxBufWrPtr,w           ;
        btfsc   STATUS,Z                        ;
        clrf    _vI2CSIntTxBufWrPtr             ;
                                                ;
        movf    _vI2CSIntTxBufWrPtr,w           ;check weather buffer is full
        xorwf   _vI2CSIntTxBufRdPtr,w           ;
        btfsc   STATUS,Z                        ;
        bsf     vI2CSIntStatus,I2CSTxBufFull    ;
                                                ;
        bcf     vI2CSIntStatus,I2CSTxBufEmpty   ;
                                                ;
        return                                  ;
                                                ;
;***********************************************;




_I2CSINTGET   CODE                                                      ;
;***********************************************************************;
; Function: I2CSIntGet                                                  ;
;                                                                       ;
; PreCondition: vI2CSIntStatus<I2CSRxBufEmpty> should be '0'            ;
;                                                                       ;
; Overview:                                                             ;
;       This reads data from buffer.                                    ; 
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
I2CSIntGet:                                     ;
                                                ;
        GLOBAL  I2CSIntGet                      ;
                                                ;
        btfss   vI2CSIntStatus,I2CSRxBufOverFlow ;check weather overflow had occured
        goto    _I2CSIntRdRxBuf                 ;
                                                ;
        call    _I2CSIntRdRxBuf                 ;if not read buffer
        BANKSEL _vI2CSTemp1                     ;
        movwf   _vI2CSTemp1                     ;save the data in Temp1
                                                ;
        PAGESEL _I2CSIntWrRxBuf                 ;
        movf    _vI2CSTemp,w                    ;
        call    _I2CSIntWrRxBuf                 ;write the data stored in Temp
                                                ;into the buffer
        BANKSEL _vI2CSTemp1                     ;
        movf    _vI2CSTemp1,w                   ;retrive the data
        bcf     vI2CSIntStatus,I2CSRxBufOverFlow ;clear overflow falg
        BANKSEL SSPCON                          ;
                                                ;
        #if I2CS_TIMER != 0                     ;
                                                ;
        clrf    _I2CS_TMR_HIGH                  ;
        clrf    _I2CS_TMR_LOW                   ;
                                                ;
        #endif                                  ;
                                                ;
        bsf     SSPCON,CKP                      ;release the clock line
        return                                  ;
                                                ;
;***********************************************;        
_I2CSIntRdRxBuf                                 ;
                                                ;
        btfsc   vI2CSIntStatus,I2CSRxBufEmpty   ;
        return                                  ;
                                                ;
        BANKSEL _vI2CSIntDupFSR                 ;
        movf    FSR,w                           ;save FSR
        movwf   _vI2CSIntDupFSR                 ;
                                                ;
        movlw   vI2CSIntRxBuffer                ;load wreg with read pointer address
        addwf   _vI2CSIntRxBufRdPtr,w           ;
        movwf   FSR                             ;load fsr with read pointer address
        movf    INDF,w                          ;move wreg the content of read pointer address
                                                ;
        movwf   _vI2CSIntTempReg                ;read data is saved in temflg
                                                ;
        movf    _vI2CSIntDupFSR,w               ;
        movwf   FSR                             ;
                                                ;
        incf    _vI2CSIntRxBufRdPtr,f           ;increment read pointer
        movlw   I2CS_RX_BUFFER_LENGTH           ;
        xorwf   _vI2CSIntRxBufRdPtr,w           ;
        btfsc   STATUS,Z                        ;
        clrf    _vI2CSIntRxBufRdPtr             ;
                                                ;
        movf    _vI2CSIntRxBufRdPtr,w           ;check weather the buffer is empty
        xorwf   _vI2CSIntRxBufWrPtr,w           ;
        btfsc   STATUS,Z                        ;
        bsf     vI2CSIntStatus,I2CSRxBufEmpty   ;
                                                ;
        movf    _vI2CSIntTempReg,w              ;
                                                ;
        bcf     vI2CSIntStatus,I2CSRxBufFull    ;
                                                ;
        return                                  ;
;***********************************************;




_I2CSINTDISRXBUF   CODE                                                 ;
;***********************************************************************;
; Function: I2CSIntDiscardRxBuf                                         ;
;                                                                       ;
; PreCondition: None.                                                   ;
;                                                                       ;
; Overview:                                                             ;
;       This flushes the buffer.                                        ; 
;                                                                       ;
; Input: None                                                           ;
;                                                                       ;
; Output: None                                                          ;
;                                                                       ;
; Side Effects: None                                                    ;
;                                                                       ;
; Stack requirement: 1 level deep                                       ;
;                                                                       ;
;***********************************************;***********************;
                                                ;        
I2CSIntDiscardRxBuf:                            ;
        GLOBAL  I2CSIntDiscardRxBuf             ;
                                                ;
        BANKSEL _vI2CSIntRxBufRdPtr             ;
        clrf    _vI2CSIntRxBufRdPtr             ;
        clrf    _vI2CSIntRxBufWrPtr             ;
        bsf     vI2CSIntStatus,I2CSRxBufEmpty   ;
        bcf     vI2CSIntStatus,I2CSRxBufFull    ;
        bcf     vI2CSIntStatus,I2CSRxBufOverFlow ;
                                                ;
        return                                  ;
                                                ;
;***********************************************;




_I2CSINTISR   CODE                                                      ;
;***********************************************************************;
; Function: I2CSIntISR                                                  ;
;                                                                       ;
; PreCondition: Must be called from an interrupt handler                ;
;                                                                       ;
; Overview:                                                             ;
;       This is a Interrupt service routine for Serial Interrupt.       ;
;       It handles Reception and Transmission of data on interrupt.     ;
;                                                                       ;
; Input: None                                                           ;
;                                                                       ;
; Output: None                                                          ;
;                                                                       ;
; Side Effects: Bank selection bits are changed                         ;
;                                                                       ;
; Stack requirement: 2 level deep                                       ;
;                                                                       ;
;***********************************************;***********************;
                                                ;
I2CSIntISR:                                     ;
        GLOBAL  I2CSIntISR                      ;
                                                ;
        BANKSEL PIR1                            ;
        btfss   PIR1,SSPIF                      ;check for SSPIF
        goto    I2CTestTmrIntBit                ;
                                                ;
        movf    SSPCON,w                        ;
        andlw   00eh                            ;check, weather it is Slave Mode
        xorlw   006h                            ;
        btfss   STATUS,Z                        ;
        return                                  ;
                                                ;
        #if I2CS_TIMER != 0                     ;
                                                ;
        clrf    _I2CS_TMR_HIGH                  ;
        clrf    _I2CS_TMR_LOW                   ;
        bcf     _I2CS_TMR_INT_FLAG              ;
        bsf     _I2CS_TMR_INT                   ;enable the timer interrupt
                                                ;
        #endif                                  ;
;-----------------------------------------------;
        bsf     STATUS,RP0                      ;
                                                ;
        if HIGH(I2CS_SELF_ADDRESS) != 0         ;If the address is 10Bit
                                                ;
        btfss   SSPSTAT,UA                      ;Is address to be updated
        goto    I2CSNoAddrsUpDate               ;
                                                ;
        btfss   I2CSIntStatus,I2CSAddressLow    ;check Address_LOw or Address_High
        movlw   LOW(I2CS_SELF_ADDRESS)          ;to be updated.
        btfsc   I2CSIntStatus,I2CSAddressLow    ;
        movlw   HIGH(I2CS_SELF_ADDRESS)         ;
        movwf   SSPADD                          ;
                                                ;
        movlw   _I2CS_ADDRESS_LOW_WORD          ;
        xorwf   I2CSIntStatus                   ;Toggle I2CSAddressLow
                                                ;
        bcf     STATUS,RP0                      ;
        movf    SSPBUF,w                        ;Dummy read to clear BF
        bcf     PIR1,SSPIF                      ;
                                                ;
        #if I2CS_TIMER != 0                     ;
                                                ;
        clrf    _I2CS_TMR_HIGH                  ;
        clrf    _I2CS_TMR_LOW                   ;
                                                ;
        #endif                                  ;
                                                ;
        return                                  ;
                                                ;
I2CSNoAddrsUpDate                               ;
        endif                                   ;
                                                ;
;-----------------------------------------------;
        #ifndef _MSSP_CLOCK_STRETCH_MODULE      ;
                                                ;
        bcf     STATUS,RP0                      ;
        bcf     SSPCON,CKP                      ;hold the clock line
        bsf     STATUS,RP0                      ;
                                                ;
        #endif                                  ;
                                                ;
        btfsc   SSPSTAT,R_W                     ;check weather Tx or Rx
        goto    I2CSTransmit                    ;
                                                ;
;-----------------------------------------------;
I2CSReceive                                     ;
        bcf     vI2CSIntStatus,I2CSTx           ;clear I2CSTx to indicate Reception
                                                ;
        btfsc   SSPSTAT,D_A                     ;check weather data is received 
        goto    I2CSRxData                      ;or address
                                                ;
        bcf     STATUS,RP0                      ;
        movf    SSPBUF,w                        ;Dummy read to clear BF
        bcf     PIR1,SSPIF                      ;
                                                ;
        #if I2CS_TIMER != 0                     ;
                                                ;
        clrf    _I2CS_TMR_HIGH                  ;
        clrf    _I2CS_TMR_LOW                   ;
                                                ;
        #endif                                  ;
                                                ;
        bsf     SSPCON,CKP                      ;release the clock line
        return                                  ;
                                                ;
I2CSRxData                                      ;
        bsf     STATUS,RP0                      ;
        btfss   SSPSTAT,BF                      ;check weather any thing in SSPBUF
        goto    I2CSEnd                         ;
                                                ;
        bcf     STATUS,RP0                      ;if so
        movf    SSPBUF,w                        ;read SSPBUF into w
                                                ;
        btfsc   vI2CSIntStatus,I2CSRxBufFull    ;checking is buffer Full
        goto    I2CSBufFullErr                  ;
                                                ;
        PAGESEL _I2CSIntWrRxBuf                 ;
        call    _I2CSIntWrRxBuf                 ;store the byte in circular buffer
                                                ;
        BANKSEL PIR1                            ;
        bcf     PIR1,SSPIF                      ;
                                                ;
        #if I2CS_TIMER != 0                     ;
                                                ;
        clrf    _I2CS_TMR_HIGH                  ;
        clrf    _I2CS_TMR_LOW                   ;
                                                ;
        #endif                                  ;
                                                ;
        bsf     SSPCON,CKP                      ;release the clock line
        return                                  ;
                                                ;
I2CSTransmit                                    ;
        bsf     vI2CSIntStatus,I2CSTx           ;set I2CSTx to indicate Transmission
                                                ;
        btfsc   vI2CSIntStatus,I2CSTxBufEmpty   ;checking is buffer Empty
        goto    I2CSBufEmptyErr                 ;
                                                ;
        PAGESEL _I2CSIntRdTxBuf                 ;
        call    _I2CSIntRdTxBuf                 ;read a byte from circular buffer
                                                ;
        BANKSEL SSPBUF                          ;
        movwf   SSPBUF                          ;write 'w' to SSPBUF
                                                ;
        bcf     PIR1,SSPIF                      ;
                                                ;
        #if I2CS_TIMER != 0                     ;
                                                ;
        clrf    _I2CS_TMR_HIGH                  ;
        clrf    _I2CS_TMR_LOW                   ;
                                                ;
        #endif                                  ;
                                                ;
        bsf     SSPCON,CKP                      ;release the clock line
        return                                  ;
                                                ;
;-----------------------------------------------;
I2CSBufEmptyErr                                 ;
        bsf     vI2CSIntStatus,I2CSTxBufUnderFlow ;set Buffer under flow flag
        bcf     STATUS,RP0                      ;
        bcf     PIR1,SSPIF                      ;
        return                                  ;
                                                ;
I2CSBufFullErr                                  ;
        bsf     vI2CSIntStatus,I2CSRxBufOverFlow ;set Buffer over flow flag
        bcf     PIR1,SSPIF                      ;
        BANKSEL _vI2CSTemp                      ;
        movwf   _vI2CSTemp                      ;
        return                                  ;
                                                ;
;-----------------------------------------------;
I2CSEnd                                         ;
        BANKSEL SSPCON                          ;
        #if I2CS_TIMER != 0                     ;
                                                ;
        clrf    _I2CS_TMR_HIGH                  ;
        clrf    _I2CS_TMR_LOW                   ;
                                                ;
        #endif                                  ;
                                                ;
        bsf     SSPCON,CKP                      ;release the clock line
        bcf     PIR1,SSPIF                      ;
        return                                  ;
                                                ;
;-----------------------------------------------;
I2CTestTmrIntBit                                ;
        #if I2CS_TIMER != 0                     ;
                                                ;
        btfss   _I2CS_TMR_INT_FLAG              ;check for timer interrupt
        return                                  ;
        bcf     _I2CS_TMR_INT_FLAG              ;clear timer interrupt flag
                                                ;
        bsf     STATUS,RP0                      ;
        bcf     _I2CS_TMR_INT                   ;disable timer interrupt
                                                ;
        bcf     STATUS,RP0                      ;
        bcf     SSPCON,SSPEN                    ;
        bsf     SSPCON,CKP                      ;release the clock line
        bsf     SSPCON,SSPEN                    ;
                                                ;
        #endif                                  ;
                                                ;
        return                                  ;
                                                ;        
;***********************************************;





_I2CSINTWRRXBUF   CODE                                                  ;
;***********************************************************************;
; Function: _I2CSIntWrRxBuf                                             ;
;                                                                       ;
; PreCondition: This is called from I2CSIntISR.                         ;
;                                                                       ;
; Overview:                                                             ;
;       This writes data into buffer.                                   ; 
;                                                                       ;
; Input: 'W' Register                                                   ;
;                                                                       ;
; Output: None                                                          ;
;                                                                       ;
; Side Effects: Bank selection bits and 'W' register are changed        ;
;                                                                       ;
; Stack requirement: 1 level deep                                       ;
;                                                                       ;
;***********************************************;***********************;
                                                ;        
_I2CSIntWrRxBuf:                                ;
        btfsc   vI2CSIntStatus,I2CSRxBufFull    ;
        return                                  ;
                                                ;        
        BANKSEL _vI2CSIntTempReg                ;
        movwf   _vI2CSIntTempReg                ;save the 'W' (data) in Tempreg
                                                ;
        movf    FSR,w                           ;Save FSR
        movwf   _vI2CSIntDupFSR                 ;
                                                ;
        movlw   vI2CSIntRxBuffer                ;load wreg with write pointer address
        addwf   _vI2CSIntRxBufWrPtr,w           ;
                                                ;
        movwf   FSR                             ;increment write pointer
        movf    _vI2CSIntTempReg,w              ;read data from SSPBUF
        movwf   INDF                            ;move wreg content to write pointer pointing location
                                                ;
        movf    _vI2CSIntDupFSR,w               ;retrive FSR
        movwf   FSR                             ;
                                                ;
        incf    _vI2CSIntRxBufWrPtr,f           ;increment write pointer
        movlw   I2CS_RX_BUFFER_LENGTH           ;
        xorwf   _vI2CSIntRxBufWrPtr,w           ;
        btfsc   STATUS,Z                        ;
        clrf    _vI2CSIntRxBufWrPtr             ;
                                                ;
        movf    _vI2CSIntRxBufWrPtr,w           ;check weather buffer is full
        xorwf   _vI2CSIntRxBufRdPtr,w           ;
        btfsc   STATUS,Z                        ;
        bsf     vI2CSIntStatus,I2CSRxBufFull    ;
                                                ;
        bcf     vI2CSIntStatus,I2CSRxBufEmpty   ;
                                                ;
        return                                  ;
                                                ;
;***********************************************;




_I2CSINTRDTXBUF   CODE                                                  ;
;***********************************************************************;
; Function: _I2CSIntRdTxBuf                                             ;
;                                                                       ;
; PreCondition: This is called from I2CSIntISR.                         ;
;                                                                       ;
; Overview:                                                             ;
;       This reads data from buffer.                                    ; 
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
_I2CSIntRdTxBuf:                                ;
                                                ;
        btfsc   vI2CSIntStatus,I2CSTxBufEmpty   ;
        return                                  ;
                                                ;
        BANKSEL _vI2CSIntDupFSR                 ;
        movf    FSR,w                           ;Save FSR
        movwf   _vI2CSIntDupFSR                 ;
                                                ;
        movlw   vI2CSIntTxBuffer                ;load wreg with read pointer address
        addwf   _vI2CSIntTxBufRdPtr,w           ;
        movwf   FSR                             ;load fsr with read pointer address
        movf    INDF,w                          ;move the read pointer address content to wreg
                                                ;
        movwf   _vI2CSIntTempReg                ;save read data 
                                                ;
        movf    _vI2CSIntDupFSR,w               ;retrive FSR
        movwf   FSR                             ;
                                                ;
        incf    _vI2CSIntTxBufRdPtr,f           ;increment read pointer
        movlw   I2CS_TX_BUFFER_LENGTH           ;
        xorwf   _vI2CSIntTxBufRdPtr,w           ;
        btfsc   STATUS,Z                        ;
        clrf    _vI2CSIntTxBufRdPtr             ;
                                                ;
        movf    _vI2CSIntTxBufRdPtr,w           ;check weather buffer is empty
        xorwf   _vI2CSIntTxBufWrPtr,w           ;
        btfsc   STATUS,Z                        ;
        bsf     vI2CSIntStatus,I2CSTxBufEmpty   ;
                                                ;
        movf    _vI2CSIntTempReg,w              ;retrive read data
                                                ;
        bcf     vI2CSIntStatus,I2CSTxBufFull    ;
                                                ;
        return                                  ;
;***********************************************;




;***********************************************;
;***********************************************;




