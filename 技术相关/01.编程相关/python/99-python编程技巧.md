1. print������
```
from __future__ import print_function
print('123123', end='')
```
2.  �Ƶ��б�
�������δ����Ч  
```
    #��ʽһ
	new_filelist=[]
	for each_t in filelist:
	    new_filelist.append(sanitize(each_t))
    #��ʽ��
	new_filelist = [sanitize(each_t) for each_t in filelist]
```
3. �����ԣ��ѷ����������ԣ�����ʱҲ������ʹ�����ԣ�����  
```
# ����  
@property
def top3(self)
    ....
# ����
     xxx.top3
```