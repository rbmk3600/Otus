
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h
MOV SI, OFFSET NUM1
MOV BX, OFFSET NUM2

MOV DI, OFFSET RES

PUSH SI
lodsb      ; IN AL BYTE WE HAVE READ
MOV AH, AL ; SAVE IT TO BL 
MOV SI, BX ;
LODSB      ; NUM2
MOV BX, SI
 
POP SI     ; POINT TO num1
ADD AL, AH ; 
STOSB



num1 DB 0x05, 0x07, 0x09
num2 DB 0x02, 0x04, 0x06
RES DB 3 DUB(0x00)
ret




