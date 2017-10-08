- man system可以看到如下返回值说明:

```
The value returned is -1 on error (e.g.  fork(2) failed), and the return status of the command otherwise.   This  latter  return

status  is in the format specified in wait(2).  Thus, the exit code of the command will be WEXITSTATUS(status).  In case /bin/sh

could not be executed, the exit status will be that of a command that does exit(127).

If the value of command is NULL, system() returns nonzero if the shell is available, and zero if not.

system() does not affect the wait status of any other children.<strong>
```

- system是个综合的操作，分解开来看就是相当于执行了  
1.fork  生成一个子进程。  
2.在子进程执行 execl（"/bin/sh","sh","-c" command,(char*)0）;  
3.waitpid  

- system函数对返回值的处理分3个阶段  
阶段一：创建子进程等准备工作，失败返回-1  
阶段二：调用/bin/sh/拉起shell脚本，如果如果/bin/sh拉起shell命令失败，或者是shell命令没有正常执行 （比如命令根本就是非法的命令），那么，将原因填入status的8～15位。  
阶段三：如果shell顺利执行完毕，那么将shell的返回值填到system返回值的8～15位

#### 测试代码
```c
#include <stdio.h>
#include <stdlib.h>
int main(int argc, char* argv[])
{
    int result = 0;

	if (argc != 2)
	{
		printf("args is not equal 2! \n");
		return 1;
	}

	result = system(argv[1]);

	printf("system return value is %d. \n", result);

	return 0;
}
```

#### 测试
```
root@test:/opt/tmp# cat test.sh
#!/bin/bash


exit 1
root@test:/opt/tmp# ./systemtest /opt/tmp/test.sh
system return value is 256. 
root@test:/opt/tmp# vi test.sh 
root@test:/opt/tmp# cat test.sh
#!/bin/bash


exit 0
root@test:/opt/tmp# ./systemtest /opt/tmp/test.sh
system return value is 0. 
root@test:/opt/tmp# rm test.sh 
root@test:/opt/tmp# ./systemtest /opt/tmp/test.sh
sh: 1: /opt/tmp/test.sh: not found
system return value is 32512. 

35152=256*127
```