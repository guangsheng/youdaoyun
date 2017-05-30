### 实例一
```
#coding=utf-8
from __future__ import print_function
import os

data = open('sketch.txt')
data.seek(0)
for each_line in data:
	try:
		(role, line_spoken) = each_line.split(':', 1)
		print(role, end='')
		print(' said: ', end='')
		print(line_spoken, end='')
	except Exception, e:
		pass
	else:
		pass
	finally:
		pass

data.close()
```
使用访问模式w时，python会打开指定的文件来完成写操作，如果这个文件已经存在，会将该文件清空。
追加 a  写和读 w+ 二进制文件b

### 实例二
```
#coding=utf-8
from __future__ import print_function
import os

man = []
other = []
try:
	data = open('sketch.txt')
	data.seek(0)
	for each_line in data:
		try:
		 	(role, line_spoken) = each_line.split(':', 1)
		 	line_spoken = line_spoken.strip()
		 	if role == 'Man':
		 		man.append(line_spoken)
		 	elif role == 'Other Man':
		 	    other.append(line_spoken)
		except Exception, e:
			pass
		finally:
			pass

	try:
            # with语句利用列一种名为 context management protocol 的技术，使用with时可以不用考虑关闭打开的文件
  	    with open('man_data.txt', 'w') as man_file, open('other_data.txt', 'w') as other_file:
  	    	print(man, file=man_file)
  	    	print(other, file=other_file)
  	except IOError as err:
  	    print('File error: '+str(err))
except IOError, e:
	print("read sketch.txt failed")
finally:
	if 'data' in locals():   #检查data是否已经定义了，即data=open这句话是否执行成功了
		data.close()
```

### 实例三pickle
```
import pickle
with open('mydata.pickle', 'wb') as mysavedata:
	pickle.dump([1, 2, 'three'], mysavedata)

with open('mydata.pickle', 'rb') as myrestoredata:
	a_list = pickle.load(myrestoredata)

print(a_list)
```

