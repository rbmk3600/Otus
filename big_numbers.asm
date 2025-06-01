;
;
;
  
N = 4  
org 100h


 
PUSH OFFSET Num1
PUSH OFFSET Num2
PUSH OFFSET RES
PUSH N
 
call SUM_BYTES


SUM_BYTES:
    MOV BP, SP
    MOV CX, [BP+2] ; num length
    MOV DI, [BP+4]
    MOV BX, [BP+6] ; Offset num2
    MOV SI, [BP+8] ; Offset num1
    STD            ; Start work from the end of string
    Summ:
                   ; Read byte of Num1
        LODSB      ; 
        PUSH SI    ; Save SI for Num1     
        MOV AH, AL ; Save AL for Num1
        
                   ; Read byte of Num2
        MOV SI, BX ; Set BI to Num2
        LODSB      ; 
        MOV BX, SI ; Save SI for Num2
         
        POP SI     ; Restore SI to point to NUM1
        
                   ; Add byte from Num1 to byte from Num2    
        ADC AL, AH ;Sum NUM1 and NUM2 bytes and store them to RES
        STOSB
        
    LOOP Summ  
        MOV BYTE PTR OFFSET RES, 0
        ADC BYTE PTR OFFSET RES, 0
        
    RET
    
    
    Num1 DB      0xFF, 0x05, 0x07, 0x09, 0x0A
    Num2 DB      0x0A, 0x02, 0x04, 0x06, 0x01 
    ;RES    0x01 0x09  0x07  0x0B, 0x0F  0x0B
 
        
    Res DB N+1 DUB(0x00)
ret




