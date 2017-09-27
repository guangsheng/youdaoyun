#### 用途：报告或删除文件中重复的行。

#### 语法: 
```uniq [ -c | -d | -u ] [ -f Fields ] [ -s Characters ] [ -Fields ] [ +Characters ] [ InFile [ OutFile ] ]```

+ uniq 命令读取由 InFile 参数指定的标准输入或文件。
+ 重复的行一定相邻（在发出 uniq 命令之前，请使用 sort 命令使所有重复行相邻）
+ uniq 命令将最终单独的行写入标准输出或由 OutFile 参数指定的文件
+ uniq 命令将最终单独的行写入标准输出或由 OutFile 参数指定的文件

#### 标志说明
**-c 在输出行前面加上每行在输入文件中出现的次数。**  
**-d 仅显示重复行。**  
**-u 仅显示不重复的行。**  

-f Fields 忽略由 Fields 变量指定的字段数目。如果 Fields 变量的值超过输入行中的字段数目, uniq 命令用空字符串进行比较。这个标志和 -Fields 标志是等价的。  
-s Characters 忽略由 Characters 变量指定的字符的数目。如果 Characters 变量的值超过输入行中的字符的数目, uniq 用空字符串进行比较。如果同时指定 -f 和 -s 标志, uniq 命令忽略由 -s Characters 标志指定的字符的数目，而从由 -f Fields 标志指定的字段后开始。 这个标志和 +Characters 标志是等价的。  
-Fields 忽略由 Fields 变量指定的字段数目。这个标志和 -f Fields 标志是等价的。  
+Characters 忽略由 Characters 变量指定的字符的数目。如果同时指定 - Fields 和 +Characters 标志, uniq 命令忽略由 +Characters 标志指定的字符数目，并从由 -Fields 标志指定的字段后开始。 这个标志和 -s Characters 标志是等价的。  