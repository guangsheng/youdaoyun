通过设置环境变量 ```export HISTTIMEFORMAT="%F %T `whoami` " ```给history加上时间戳  
  
 ```
[root@servyou_web ~]# export HISTTIMEFORMAT="%F %T `whoami` "  
[root@servyou_web ~]# history  |  tail  
 1014  2011-06-22 19:17:29 root    15  2011-06-22 19:13:02 root ./test.sh   
 1015  2011-06-22 19:17:29 root    16  2011-06-22 19:13:02 root vim test.sh   
 1016  2011-06-22 19:17:29 root    17  2011-06-22 19:13:02 root ./test.sh   
 1017  2011-06-22 19:17:29 root    18  2011-06-22 19:13:02 root vim test.sh   
 1018  2011-06-22 19:17:29 root    19  2011-06-22 19:13:02 root ./test.sh   
 1019  2011-06-22 19:17:29 root    20  2011-06-22 19:13:02 root vim test.sh   
 1020  2011-06-22 19:17:29 root    21  2011-06-22 19:13:02 root ./test.sh   
 1021  2011-06-22 19:17:29 root    22  2011-06-22 19:13:02 root vim test.sh   
 1022  2011-06-22 19:25:22 root    22  2011-06-22 19:13:02 root vim test.sh   
 1023  2011-06-22 19:25:28 root history  |  tail  
 ```