
#входные данные
#смещение 
base_adress = 20000
#предел
limit = 255 + 256*15
#уровень привелегий
DPL = 3

print( "LIMIT", bin(limit))
base_adress_bytes = base_adress.to_bytes(4, 'big')
# Поле "предел" - храним как три байта 
limit_bytes = limit.to_bytes(3, 'big')

b0 = 0b00000000
b1 = 0b00000000
b2 = 0b00000000
b3 = 0b00000000
b4 = 0b00000000
b5 = 0b00000000
b6 = 0b00000000
b7 = 0b00000000

b2 = base_adress_bytes[3]
b3 = base_adress_bytes[2]
b4 = base_adress_bytes[1]
b7 = base_adress_bytes[0]

b0 = limit_bytes[0]
b1 = limit_bytes[1]

# если у нас установлен младший бит в старшем байте "Предела" 
# помещаем его в самую старшую позицию 6 байта (b5) структуры "Дескриптор сегмента"
if ( limit_bytes[2] & 0b00000001):
    b5 = b5 | 0b10000000

# а биты в позиции 1, 2, 3 старшего байта структуры "Предел" помещаем в позицию 0, 1, 2  7-го байта (b6) структуры "Дескриптор сегмента"    
b6 = b6 | ( limit_bytes[0]>>1)
print("B5 FOR LIMIT", bin(b5) )
print("B6 FOR LIMIT", bin(b6))


desc_dump = [b0, b1, b2, b3, b4, b5, b6, b7]


DPL_MASK = 0
DPL_POS = 5     # DPL стоит 5 по счету в 6-ом бите (b5) структуры "Дескриптор сегмента"
#сдвинем биты отвечающие за DPL в нужную позицию ( начинется с 5-го по счету бита)
DPL_MASK = ( DPL << (DPL_POS-1))
b5 = b5 | DPL_MASK
desc_dump.reverse()

f = open('descriptor.bin', 'wb')
for el in desc_dump:
    bt = el.to_bytes(1, byteorder='big', signed=False)
    print(bin( el))
    f.write(bt)
f.close()
#byte6 = b'00000001'