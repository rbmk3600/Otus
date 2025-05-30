
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt
  
N = 4  
org 100h

MOV SI, OFFSET NUM1
MOV BX, OFFSET NUM2

MOV CX, N

MOV DI, OFFSET RES

Summ:
    
    LODSB      ; 
    PUSH SI    ; Save SI for NUM1        
    MOV AH, AL ; Save AL for NUM1
    
    MOV SI, BX ; Set BI to NUM2 
    LODSB      ; 
    MOV BX, SI ; Save SI for NUM2
     
    POP SI     ; Restore SI to point to NUM1
    
    
    ADD AL, AH ;Sum NUM1 and NUM2 bytes and store them to RES
    STOSB
    
LOOP Summ

JMP $
num1 DB 0x05, 0x07, 0x09, 0x0A
num2 DB 0x02, 0x04, 0x06, 0x01 
;       0x07  0x0B  0x0F, 0x0B
RES DB N DUB(0x00)
ret




