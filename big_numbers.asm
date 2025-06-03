;
;
;

SECTOR_SIZE = 512 	;размер блока байт в котором расположены слагаемые для сложения (каждое слагаемое это данные из одного сектора)
BUFFER_SIZE = 1024
SEC_NUM = 1
SEC_COUNT = 1
FUNCTION_READ_SEC = 2	; код ф-ии для чтения сектора
FUNCTION_WRITE_SEC = 3	; код ф-ии для записи в сектор
REC_NUM = 0;
FIRST_DISK_NUM =0;
SECOND_DISK_NUM = 1
HEAD_NUM = 0; 
org 100h

;Читаем первый сектор диска 0
mov ah, FUNCTION_READ_SEC
mov al, SEC_COUNT
mov bx, offset Num1 
mov cl, SEC_NUM
mov ch, REC_NUM
mov dl, FIRST_DISK_NUM 
mov dh, HEAD_NUM
int 13h
  
;Читаем второй сектор диска 0
mov ah, FUNCTION_READ_SEC
mov al, SEC_COUNT
mov bx, offset Num2
mov cl, SEC_NUM + 1
mov ch, REC_NUM
mov dl, FIRST_DISK_NUM 
mov dh, HEAD_NUM
int 13h 



push OFFSET Num1 + (SECTOR_SIZE - 1)        ; Позиция последнего байта первого числа
push OFFSET Num2 + (SECTOR_SIZE - 1)        ; Позиция последнего байта второго числа
push OFFSET Buffer + (BUFFER_SIZE - 1)
push SECTOR_SIZE
call SumBytes  

push offset Buffer
call WriteToDrive

jmp $

SumBytes:
    PUSH BP
    MOV BP, SP
    
    MOV CX, [BP+4]  ; Передали размер числа (не хотел "хардкодить" т.к. думал еще пригодиться эта ф-ия и тестировал на числах в памяти)
    MOV DI, [BP+6]  ; Позиция последнего байта в буфере
    MOV BX, [BP+8]  ; Позиция последнего байта в числе 1
    MOV SI, [BP+10] ; Позиция последнего байта в числе 2
    STD             ; Читаем с последней позиции (самой правой) т.к. работаем с litle endian формой записи
    
    NextByte:      ; Прочитали байт               
        LODSB      ; 
        PUSH SI    ; Сохраним SI для числа 1     
        MOV AH, AL ; Сохраним AL для числа 1
        
                   ; Читаем теперь байт из числа 2
        MOV SI, BX ; Устанавливем BI на считываемую позицию
        LODSB      ; 
        MOV BX, SI ; Сохраним SI для числа 2
         
        POP SI     ; Восстановим SI для числа 1
        
                   ; Теперь у нас в AH байт из числа 2, а в AL байт из числа 1  
        ADC AL, AH ; Суммируем байты
        STOSB	   ; Помещаем байт, являющийся суммой байтов из первого и второго числа в AL       
    LOOP NextByte  
    
    MOV BYTE PTR OFFSET Buffer + (512-1), 0 ; в нулевой байт, второго блока из 512 байт записываем 0
    ADC BYTE PTR OFFSET Buffer, 0 ; и если суммирование байт из первого блока закончилось переносом, дописываем сюда 1
        
    POP BP
    RET
    

WriteToDrive: 
    push BP
    mov BP, SP
    
    mov dl, SECOND_DISK_NUM ; FLOPPY_1 
    mov ah, FUNCTION_WRITE_SEC
    mov al, 2
    mov bx, [BP+4] 
    mov cl, SEC_NUM
    mov ch, REC_NUM
    
    mov dh, HEAD_NUM   
    
    mov BX, [BP+4] ; адрес результирующего буфера
    pop BP
    
    int 13h
    ret

   
Num1 db  SECTOR_SIZE    DUP(0x00) ; Размещаем в памяти блок байт для первого числа (из 1 сектора диска 0)
Num2 db  SECTOR_SIZE    DUP(0x00) ; Размещаем в памяти блок байт для второго числа (из 2 сектора диска 0)
        
Buffer db BUFFER_SIZE  DUP(0x00)  ; Результирующий буфер в котором храним сумму блоков из 1 сектора и 2 сектора

ret




