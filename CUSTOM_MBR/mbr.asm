use16

SECTOR_SIZE equ 512 	;размер блока байт в котором расположены слагаемые для сложения (каждое слагаемое это данные из одного сектора)
SEC_NUM equ  0x01
SEC_COUNT equ  0x01
FUNCTION_READ_SEC equ  0x02; код ф-ии для чтения сектора
REC_NUM equ  0x00;
FIRST_DISK_NUM equ 0x00;
PSSWD_MAX_LENGTH equ 6 ;Ограничим пароль 6 символами, если после достижения лимита пользователь что-то жмет еще, отправляем на проверку
HEAD_NUM EQU  0; 

OldPlace EQU 0x7c00
NewPlace EQU 0x0600
delta EQU newOffset-start

STR_SIZE equ 15
X_POS equ 40
Y_POS equ 11
TEXT_PAGE equ 0

;start from offset 0x7c00
org OldPlace
start:

    xor ax, ax
	mov es, ax
	mov ds, ax
	mov ss, ax

    ; set video mode  
	mov	ah, 0x00
	mov     al, 03h  
	int	10h   
	 
	; set cursor
	mov	ah, 02h
	xor bx, bx
	int 10h        

	;Печать строки "Введите пароль"
	xor al, al
	mov al, 01h
	mov ah, 13h
	mov bp,  MsgPswd
	mov cx, STR_SIZE
	mov dl, X_POS - STR_SIZE
	mov dh, Y_POS
	mov bl, 010b
	int 10h

	xor bx, bx 
	xor dx, dx
	mov ah, 03h
	int 10h

	; set cursor
	mov ah, 02h
	mov DH, Y_POS
	mov DL, X_POS  + 1
	xor bx, bx
	int 10h      
		   
	mov AL, '_'
	mov AH, 0Ah
	
	mov CX, 1      
	int 10h    
						   
	mov [PsswdLength], PSSWD_MAX_LENGTH                       
	mov di,  Password
    mov [Symbol], 0x00
    mov [Middle], 0x00
    xor cx, cx
    mov cl,  [PsswdLength]
   
read_symbol:
    push cx
    ;READ FROM KEYBORD
    xor ax, ax
    int 16h
    
    mov al, ah
    stosb
    ;Нажали клавишу Enter?
    cmp ah, 0x1c
    ;Если клавиша Enter была нажата, проверяем пароль
    je check_password
    
    ;Напечатали звездочку в позиции введенного символа и перевели курсор на 1 символ вправо
    mov ah, 02h
    mov dh, Y_POS
    mov dl, [Symbol]
    add dl, X_POS + 1
    int 10h
         
    mov al, '*'
    mov ah, 0ah
    mov cx, 1
    int 10h
    
    ;print input symbol
    ;set cursor for input
    mov ah, 02h
    mov dh, Y_POS
    mov dl, [Symbol]
    add dl, X_POS   + 2
    int 10h
    
    ;print input
    mov al, '_'
    mov ah, 0Ah
    mov cx, 1
    mov bl, 010b
    int 10h 
    ; куда будем выводить курсор с приглашением символа
    inc [Symbol]
    ; возможно cx где-то в прерываниях мог быть изменен, а здесь кол-во считанных символов
    pop cx
    loop read_symbol

check_password:
    mov si,  Secret
    mov di,  Password
    mov cx, 6
    repe cmpsb
    jnz password_incorrect
    ;Очистим экран
    mov ah, 0x00
    mov al, 03h  
    int 10h  
    
    ;Выведем на экран сообщения о том что "Доступ разрешен"
    xor al, al
    mov al, 01h
    mov ah, 13h 
    mov bp,  MsgGranted 
    mov cx, STR_SIZE
    mov dl, X_POS - STR_SIZE
    mov dh, Y_POS
    mov bl, 010b
    int 10h   
    ;Print string
    
    xor ax, ax
    mov al,  [LenPressAnyKey]
    mov bl, 2
    div bl
    mov  [Middle],  al
    
    xor al, al
    mov al, 01h
    mov ah, 13h
    mov bp,  MsgPressAnyKey 
    mov cl, [LenPressAnyKey]   
    mov dl, X_POS
    sub dl, [Middle]
    mov dh, Y_POS + 1
    mov bl, 010b
    int 10h   
    xor ax, ax
    int 16h   
   
    jmp password_correct   
password_incorrect: 
    ;Если пароль неправильный, очистим экран и выведем сообщение что "доступ запрещен"
    mov ah, 0x00
    mov al, 03h  
    int 10h  
    
    ;Вывод строки доступ запрещен
    xor al, al
    mov al, 01h
    mov ah, 13h 
    mov bp,  MsgDenied 
    mov cx, STR_SIZE   
    mov dl, X_POS - STR_SIZE
    mov dh, Y_POS
    mov bl, 100b
    int 10h
    ;wait for key 
    xor ax, ax
    int 16h
    jmp start

MsgPswd db 'ENTER PASSWORD:',0x00

MsgGranted db 'ACCESS GRANTED',0x00
MsgDenied db 'ACCESS DENIED!', 0x00
MsgPressAnyKey db '(press any key to load operation system)', 0x00
LenPressAnyKey db $ - MsgPressAnyKey

;Пароль для доступа 123456, здесь запишем пасскоды клавиш
Secret db 0x02, 0x03, 0x04, 0x05, 0x06, 0x07
Password db 8 dup (0x00) 
PsswdLength db 0x00 ; максимальная длина пароля
Middle db 0x00

Symbol db 0x00    

password_correct:   
	xor ax, ax
	mov es, ax
	mov ds, ax
	mov ss, ax

    cld
	mov di, NewPlace
	mov si, OldPlace
	mov cx, 200h
	rep movsb
    
    mov bx, delta

    push es
	push NewPlace + delta
    retf
newOffset:	

org NewPlace + delta
    
	mov bx, cs
	mov ds, bx
	mov es, bx
	xor bx, bx
	;Прочитаем из 2 сектора дискеты старый загрузчик
    mov ah, FUNCTION_READ_SEC
    mov al, SEC_COUNT
    mov bx, 7c00h
    mov cl, 2
    mov ch, REC_NUM
    mov dl, FIRST_DISK_NUM 
    mov dh, HEAD_NUM
    int 13h 
    push 0
    push OldPlace
    retf

db 510 - ($-$$ + delta) dup (0)
db 0x55, 0xAA

old_mbr:
    file "mbr.bck"



