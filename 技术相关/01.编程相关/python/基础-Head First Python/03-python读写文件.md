### ʵ��һ
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
ʹ�÷���ģʽwʱ��python���ָ�����ļ������д�������������ļ��Ѿ����ڣ��Ὣ���ļ���ա�
׷�� a  д�Ͷ� w+ �������ļ�b

### ʵ����
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
            # with���������һ����Ϊ context management protocol �ļ�����ʹ��withʱ���Բ��ÿ��ǹرմ򿪵��ļ�
  	    with open('man_data.txt', 'w') as man_file, open('other_data.txt', 'w') as other_file:
  	    	print(man, file=man_file)
  	    	print(other, file=other_file)
  	except IOError as err:
  	    print('File error: '+str(err))
except IOError, e:
	print("read sketch.txt failed")
finally:
	if 'data' in locals():   #���data�Ƿ��Ѿ������ˣ���data=open��仰�Ƿ�ִ�гɹ���
		data.close()
```

### ʵ����pickle
```
import pickle
with open('mydata.pickle', 'wb') as mysavedata:
	pickle.dump([1, 2, 'three'], mysavedata)

with open('mydata.pickle', 'rb') as myrestoredata:
	a_list = pickle.load(myrestoredata)

print(a_list)
```

