use16

OldPlace EQU 0x7c00
DATA_SEG_ADDRESS EQU 0x8000
STACK_SEG_ADDRESS EQU 0x9000
delta EQU newOffset-start
CODE_SELECTOR = 8
DATA_SELECTOR = 16 ; смещение в GDT таблице
STACK_SELECTOR = 24

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

	xchg bx, bx
	;making code segment
	push cs
	pop ax
	;											  Физический адр.
	shl eax, 4 ; в EAX физический адресс сегмента PA_В4, PA_B3, PA_B2, PA_B1
	mov ecx, eax
	
	shl ecx, 16 ; 			 в ECX в старших байтах PA_B2 и PA_B1
	mov cx, 0x7c00 + 0x200 ;			 в младших байтах ECX лимит

	mov bx, GDT
	
	mov [ bx + CODE_SELECTOR], ecx ;Запишем 4 младших байта дескриптора 
	shr eax, 16 	; PA_B4 и PA_B3 теперь в AX
	mov cl, ah ; PA_B4 в CL
	shl cx, 24 ; PA_B4 в старшем байте ECX
	mov cl, al ; PA_B3 в младшем байте ECX
	mov ch, 10011000b

	mov [bx + CODE_SELECTOR +4], ecx
	
	;data segment
	xor eax, eax
	mov ecx, eax

	mov ax, DATA_SEG_ADDRESS
	
	mov ecx, eax
	shl ecx, 16 ; 
	
	mov cx, DATA_SEG_ADDRESS + 0x200 ; выделим 512 байт
	mov bx, GDT
	;xchg bx, bx ; здесь ecx должен быть равено 0x  80 00 82 00
	mov [bx + DATA_SELECTOR], ecx
	shr eax, 16	; в AX PA_B4 и PA_B3
	xor ecx, ecx
	mov ch, 10010010b 
	mov [bx + DATA_SELECTOR + 4], ecx
	
	xchg bx, bx
	;stack segment
	xor eax, eax
	mov ecx, eax
	mov ax, STACK_SEG_ADDRESS
	mov ecx, eax
	shl ecx, 16
	mov cx, 0x9000 + 0x200
	mov bx, GDT
	mov [bx + STACK_SELECTOR], ecx
	xor ecx, ecx
	mov ch, 10010110b ; P = 1, DPL = 00b, S = 1, TYPE = 011b, A=0
	mov [bx + STACK_SELECTOR + 4], ecx
	

	xor eax, eax
	mov edx, eax

	mov ax, ds
	shl eax, 4
	mov dx, GDT
	add eax, edx
	
	; подготовим регистр lgdt
	mov [GDT_addr], eax
	mov dx, 39
	mov [GDT_lim], dx
	
	cli	
	xchg bx, bx
	lgdt [GTDR]

	or eax, 1
	mov cr0, eax
	; переходим в сегмент кода, он у нас по смещению 8
	jmp 8:init_pm
	
	use32

init_pm:					   
	mov ax, cs
	nop
	jmp $

MsgBeforePM db 'REAL MODE ON',0x00

GTDR:

GDT_lim dw ?
GDT_addr dd ?
GDT:
GDT_EMPTY db 0x00 dup(8)
												; limit 512
GDT_CS db 0x00 dup(8)
GDT_DS db 0x00 dup(8)
GDT_SS db 0x00 dup(8)
;
;Сегмент кода

Middle db 0x00

Symbol db 0x00    



db 510 - ($-$$ ) dup (0)
db 0x55, 0xAA





