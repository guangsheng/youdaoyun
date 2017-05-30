#### 内置库：re

#### 需要记忆的
- \n 匹配换行符
- \r 匹配制表符
- \w 匹配任意一个字母、数字和下划线
- \W 匹配除任意一个字母、数字和下划线外的其他字符
- \d 匹配任意一个十进制数
- \D 匹配除十进制数以外的任意一个字符
- \s 匹配一个空白字符
- \S 匹配除空白字符外任意一个其他字符
- 
-
- [^] 除了中括号中的原子其他均可以匹配
- {n} 恰好n次
- {n,} 至少n次
- {n,m} 至少n次，至多m次
- |  模式选择符
- () 模式单元符

####  特殊之处
- I 匹配时忽略大小写
- M 多行匹配
- L 做本地化识别匹配
- U 根据Unicode字符集解析字符
- S 让.匹配包括换行符，即使用该模式后.可以匹配任意字符  
**使用方式**: re.search(pattern, string, re.I)
----
- 贪婪模式：尽可能多的匹配(p.*y)
- 懒惰模式：尽可能少的匹配(p.*?y)

#### 相关函数
函数名|说明
----|----
re.match(pattern, string, flag)|只匹配一个结果，从源字符串的***起始位置**匹配一个模式，这儿起始位置的意思是起始位置必须和pattern匹配
re.search(pattern, string, flag)|只匹配一个结果，在全文中进行检索并匹配
complie/findall|两者配合使用做全局匹配用，匹配所有结果
re.sub(pattern, repl, string, count, flags)|实现替换某些字符串的功能，第二个参数为要替换成的字符串，第四个参数为可选想，代表替换的次数，如果不写，则会将符合模式的全部替换


#### 示例
##### 函数实际使用
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
输出
```
result1: None
result2: <_sre.SRE_Match object at 0x00000000022116B0>
result3: ['ypythont', 'spythono', 'rpythone']
result5: hellomphphiphpuphpnd
result6: hellomphphiphpurpythonend
```

##### 几个常用的模式
```Python
#匹配.com和.cn后缀的网址
pattern="[a-zA-Z]+://[^\s]*[.com|.cn]"
#匹配电话号码
pattern="\d{4}-\d{7}|\d{3}-\d{8}"
#匹配电子邮件地址
pattern="\w+([.+-]\w+)*@\w+([.-]\w+)*\.\w+([.-]\w+)*"
```
