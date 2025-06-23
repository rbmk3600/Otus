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
CODE_SELECTOR = 8 ; смещение в GDT таблице
STR_SIZE equ 15
X_POS equ 40
Y_POS equ 11
TEXT_PAGE equ 0
CODE_SEG equ 8
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

	;Печать строки "Transmition to PM"
	xor al, al
	mov al, 01h
	mov ah, 13h
	mov bp,  MsgBeforePM
	mov cx, STR_SIZE
	mov dl, X_POS - STR_SIZE
	mov dh, Y_POS
	mov bl, 010b
	int 10h

	xor bx, bx 
	xor dx, dx
	mov ah, 03h
	int 10h

	
	;making code segment
	push cs
	pop ax
	;											  Физический адр.
	shl eax, 4 ; в EAX физический адресс сегмента PA_В4, PA_B3, PA_B2, PA_B1
	mov ecx, eax
	
	shl ecx, 16 ; 			 в ECX в старших байтах PA_B2 и PA_B1
	mov cx, 0x8c00 ;			 в младших байтах ECX лимит
	xchg bx, bx
	mov bx, GDT
	add bx, 8
	;Запишем 4 младших байта дескриптора 
	mov [bx], ecx
	shr eax, 16 	; PA_B4 и PA_B3 теперь в AX
	mov cl, ah ; PA_B4 в CL
	shl cx, 24 ; PA_B4 в старшем байте ECX
	mov cl, al ; PA_B3 в младшем байте ECX
	mov ch, 10011000b
	add bx, 4
	mov [bx], ecx

	xor eax, eax
	mov edx, eax
	xchg bx, bx
	
	mov ax, ds
	shl eax, 4
	mov dx, GDT
	add eax, edx
	

	
	mov [GDT_addr], eax
	mov dx, 39
	mov [GDT_lim], dx
	
	cli	
	lgdt [GTDR]

	or eax, 1
	mov cr0, eax
	jmp 8:init_pm
	
	use32

init_pm:					   
	xchg bx, bx
	mov ax, cs
	nop
	nop
	nop
	jmp $

MsgBeforePM db 'REAL MODE ON',0x00

GTDR:

GDT_lim dw ?
GDT_addr dd ?
GDT:
	db 		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
												; limit 512
GDT_CS db 0x00 dup(8)
;desc_access dw b01000000, b10101010
desc_cs_base_addr2 	db 0x00
desc_cs_base_addr1 	db 0x00
desc_cs_limit 		db 0x02, 0x00
;Сегмент кода

Middle db 0x00

Symbol db 0x00    


db 510 - ($-$$ ) dup (0)
db 0x55, 0xAA





