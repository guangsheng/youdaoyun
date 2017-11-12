
#### 下载和解压go环境包
http://golangtc.com/static/go/  

```
cd /opt/hellobike
tar zxvf go1.4beta1.linux-amd64.tar.gz
```



#### 设置系统环境变量
```
vi ~/.bash_profile
export GOROOT=/opt/hellobike/go
export GOBIN=$GOROOT/bin
export PATH=$PATH:$GOBIN
```
 

#### 加载参数使其生效
```source ~/.bash_profile```


#### 验证，查看是否配置成功
```go version```

#### 编译测试
```
$ cat helloworld.go 
package main

import  "fmt" 

func main() {
    fmt.Println("Hello World!")
}

$ go build helloworld.go 
$ ./helloworld 
Hello World!

```