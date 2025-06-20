# Формирование дескриптора сегмента на основании введенных параметров
# Смещение
# Лимит
# Уровень превилегий
# b - смещение
# l - лимит
# g - гранулярность
# Пример запуска python mkdes.py -b 2000000 -l 20000 -d 0 -p 0 -s 0 -a 0 -g 0 -x 0
import sys
import getopt

NotSet = -1
segment_base = NotSet
segment_limit = NotSet
segment_priv = NotSet
segment_present = NotSet
segment_system = NotSet
segment_accessed = NotSet
segment_granularity = NotSet
segment_db = NotSet
argv = sys.argv[1:]
isParamsCorrect = True
try:
    opts, args = getopt.getopt(argv, "b:l:d:p:s:a:g:x:")
    for opt, arg in opts:
        if opt in['-b']:
            print("BAZE OFFSET :   ", arg)
            segment_base = int(arg)
        if opt in['-l']:
            print("LIMIT: ", arg)
            segment_limit = int(arg)
        if opt in['-d']:
            print("PRIV: ", arg)
            segment_priv = int(arg)
        if opt in['-p']:
            print("Present: ", arg)
            segment_present = int(arg)
        if opt in['-s']:
            segment_system = int(arg)
            print("SYSTEM SEGMENT: ", arg)
        if opt in['-a']:
            segment_accessed = int(arg)
            print("Segment accessed: ", arg)
        if opt in['-g']:
            segment_granularity = int(arg)
            print("Segment granularity: ", arg) 
        if opt in['-x']:
            segment_db = int(arg)
            print("Segment DB: ", arg)        

    if (segment_base == NotSet):
        print("Command line options error! Please enter segment base !")
        isParamsCorrect = False   
    if (segment_limit == NotSet):
        print ("Command line options error! Please enter segment limit!")
        isParamsCorrect = False 
    if (segment_priv == NotSet):
        print ("Command line options error! please enter segment privileges!")    
        isParamsCorrect = False 
    if (segment_system == NotSet):
        print ("Command line options error! please enter segment system flag (s)!")    
        isParamsCorrect = False 
except:
    print("ERROR! Not enough correct parameters use:")
    print("-b [base size]")
    print("-l [limit]")
    print("-p privileges from 0 to 3")
    print("-a accessed")
    print("-g [granularity]")
    print("-x [DB] 0 for 16 bit 1 for 32 bit")
    isParamsCorrect = False 


if (isParamsCorrect == False):
    sys.exit()


if ( (segment_limit >= (256 * 256 * 16)) or (segment_limit <0)):
    print ("Incorrect segment limit size:", segment_limit)
    sys.exit()

if ( (segment_base>= (256 * 256 * 256 * 256)) or (segment_base < 0) ):
    print("Incorrect segment base: ", segment_base)
    sys.exit()

if ( (segment_priv > 3) or ( segment_priv < 0) ):
    print ("Incorrect priv: ", segment_priv)
    sys.exit()

print("Segmetn base:",  segment_base)
print("segment limit:", segment_limit)
print("Segment priv:",  segment_priv)
print("Segment present:",  segment_present)
print("Segment present:",  segment_system)
print("Segment accessed:",  segment_accessed)
print("Segment granularity:",  segment_granularity)
DPL = segment_priv
DPL = segment_priv

base_adress_bytes = segment_base.to_bytes(4, 'big')


b0 = 0b00000000
b1 = 0b00000000
b2 = 0b00000000
b3 = 0b00000000
b4 = 0b00000000
b5 = 0b00000000
b6 = 0b00000000
b7 = 0b00000000

# 4 байта под Base addres, base адресс занимает биты в позициях 2, 3, 4, 7
b2 = base_adress_bytes[3]
b3 = base_adress_bytes[2]
b4 = base_adress_bytes[1]
b7 = base_adress_bytes[0]


# Поле "предел" - храним как три байта 
limit_bytes = segment_limit.to_bytes(3, 'big')
print(limit_bytes)
# Два младших байта дескриптора отданы под Limit
FIRST_LIMIT_BYTE_POS    = 0
SECOND_LIMIT_BYTE_POS   = 1
LAST_LIMIT_BYTE_POS     = 2
b0 = limit_bytes[LAST_LIMIT_BYTE_POS]

b1 = limit_bytes[SECOND_LIMIT_BYTE_POS]

b6 = b6 |  limit_bytes[FIRST_LIMIT_BYTE_POS]

print("BAZE:", bin(segment_base)[2:].rjust(32, '0'))
print ( '\t', bin(b7)[2:].rjust(8, '0'), "|", bin(b4)[2:].rjust(8, '0'), "|", bin(b3)[2:].rjust(8, '0'), "|", bin(b2)[2:].rjust(8, '0'))

print("LIMIT:", bin(segment_limit)[2:].rjust(24, '0'))
print( '\t', bin(b6)[2:].rjust(8, '0'), "|", bin(b1)[2:].rjust(8, '0'), "|", bin(b0)[2:].rjust(8, '0') )


desc_dump = [b0, b1, b2, b3, b4, b5, b6, b7]


DPL_MASK = 0
DPL_POS = 5     # DPL стоит 5 по счету в 6-ом бите (b5) структуры "Дескриптор сегмента"
#сдвинем биты отвечающие за DPL в нужную позицию ( начинется с 5-го по счету бита)
DPL_MASK = ( DPL << (DPL_POS-1))
b5 = b5 | DPL_MASK
if (segment_system==1):
    b5 = b5 | 0b00001000


if (segment_present==1):
    b5 = b5 | 0b10000000
if (segment_accessed == 1):
    b6 = b6 | 0b00010000
if (segment_granularity == 1):
    b6 = b6 | 0b10000000
if (segment_db == 1):
    b6 = b6 | 0b01000000
print("DPL:", bin(DPL)[2:].rjust(8, '0'))
print( '\t', bin(b5)[2:].rjust(8, '0') )
# Дескриптор записываем в формате big-endian в файл, b7 идет первым
desc_dump.reverse()


print("DESCRIPTOR")
print ( '\t', bin(b7)[2:].rjust(8, '0'), "|", bin(b6)[2:].rjust(8, '0'), "|", bin(b5)[2:].rjust(8, '0'), "|", bin(b4)[2:].rjust(8, '0'))
print ( '\t', bin(b3)[2:].rjust(8, '0'), "|", bin(b2)[2:].rjust(8, '0'), "|", bin(b1)[2:].rjust(8, '0'), "|", bin(b0)[2:].rjust(8, '0'))
f = open('descriptor.bin', 'wb')
for el in desc_dump:
    bt = el.to_bytes(1, byteorder='big', signed=False)

    f.write(bt)
f.close()

#byte6 = b'00000001'