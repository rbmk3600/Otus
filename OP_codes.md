#Список команд с одинаковыми мнемониками, но разными опкодами
## Команда ADC
### Для r16
ADC AX, AX
0x13 0xC0
0x11 0xC0

ADC BX, BX
0x11 0xDB
0x13 0xDB

### Для r8
ADC AL, AL
0x10 0xC0
0x12 0xC0

ADC AH, AH
0x10 0xE4
0x12 0xE4

ADC BL, BL
0x12 0xDB
0x10 0xDB

ADC BH, BH
0x10 0xFF
0x12 0xFF

ADC CH, CH
0x10 0xED
0x12 0xED

ADC CH, CH
0x10 0xC9
0x12 0xC9

## Команда SBB
## r8
SBB AL, AL
0x1A 0xC0
0x18 0xC0

##@ r16
SBB AX, AX
0x19 0xC0
0x1B 0xC0

## Команда AND
### r8
AND AL, AL
0x20 0xC0
0x22 0xC0

## Команда CMP
### r8
CMP AL, AL
0x3A 0xC0
0x38 0xC0

CMP AX, AX
0x39 0xC0
0x3B 0xC0

## Команда MOV
### r8
MOV AL, AL
0x88 0xC0
0x8A 0xC0

## Команда XOR
### r8
XOR AL, AL
0x30 0xC0
0x32 0xC0