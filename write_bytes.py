
volume_file = 'FLOPPY_0'

f = open(volume_file, 'wb')

for i in range(512):
	f.write(b'\x44')
for i in range(512):
	f.write(b'\x55')
f.close()
