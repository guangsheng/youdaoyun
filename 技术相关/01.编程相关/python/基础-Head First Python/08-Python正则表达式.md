#### ���ÿ⣺re

#### ��Ҫ�����
- \n ƥ�任�з�
- \r ƥ���Ʊ��
- \w ƥ������һ����ĸ�����ֺ��»���
- \W ƥ�������һ����ĸ�����ֺ��»�����������ַ�
- \d ƥ������һ��ʮ������
- \D ƥ���ʮ���������������һ���ַ�
- \s ƥ��һ���հ��ַ�
- \S ƥ����հ��ַ�������һ�������ַ�
- 
-
- [^] �����������е�ԭ������������ƥ��
- {n} ǡ��n��
- {n,} ����n��
- {n,m} ����n�Σ�����m��
- |  ģʽѡ���
- () ģʽ��Ԫ��

####  ����֮��
- I ƥ��ʱ���Դ�Сд
- M ����ƥ��
- L �����ػ�ʶ��ƥ��
- U ����Unicode�ַ��������ַ�
- S ��.ƥ��������з�����ʹ�ø�ģʽ��.����ƥ�������ַ�  
**ʹ�÷�ʽ**: re.search(pattern, string, re.I)
----
- ̰��ģʽ�������ܶ��ƥ��(p.*y)
- ����ģʽ���������ٵ�ƥ��(p.*?y)

#### ��غ���
������|˵��
----|----
re.match(pattern, string, flag)|ֻƥ��һ���������Դ�ַ�����***��ʼλ��**ƥ��һ��ģʽ�������ʼλ�õ���˼����ʼλ�ñ����patternƥ��
re.search(pattern, string, flag)|ֻƥ��һ���������ȫ���н��м�����ƥ��
complie/findall|�������ʹ����ȫ��ƥ���ã�ƥ�����н��
re.sub(pattern, repl, string, count, flags)|ʵ���滻ĳЩ�ַ����Ĺ��ܣ��ڶ�������ΪҪ�滻�ɵ��ַ��������ĸ�����Ϊ��ѡ�룬�����滻�Ĵ����������д����Ὣ����ģʽ��ȫ���滻


#### ʾ��
##### ����ʵ��ʹ��
```Python
import re

def test_function1():
    string="hellomypythonthispythonourpythonend"
    pattern=".python."
    result1=re.match(pattern, string)
    result2=re.search(pattern,string)
    print "result1:",result1
    print "result2:",result2
    result3=re.compile(pattern).findall(string)
    print "result3:",result3
    result5=re.sub(pattern,"php",string)
    result6=re.sub(pattern,"php",string,2)
    print "result5:",result5
    print "result6:",result6

if __name__ == "__main__":
    test_function1()
```
���
```
result1: None
result2: <_sre.SRE_Match object at 0x00000000022116B0>
result3: ['ypythont', 'spythono', 'rpythone']
result5: hellomphphiphpuphpnd
result6: hellomphphiphpurpythonend
```

##### �������õ�ģʽ
```Python
#ƥ��.com��.cn��׺����ַ
pattern="[a-zA-Z]+://[^\s]*[.com|.cn]"
#ƥ��绰����
pattern="\d{4}-\d{7}|\d{3}-\d{8}"
#ƥ������ʼ���ַ
pattern="\w+([.+-]\w+)*@\w+([.-]\w+)*\.\w+([.-]\w+)*"
```
