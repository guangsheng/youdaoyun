#### Ubuntu������sambaʵ���ļ��й���
##### һ. samba�İ�װ:
```
sudo apt-get install samba -y
```
##### ��. ��������Ŀ¼:
```
mkdir /home/phinecos/share
sodu chmod 777 /home/phinecos/share
```
##### ��. ����Samba�����ļ�:
1. �������е������ļ�
```
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
```
2. �޸��������ļ�
```
sudo gedit /etc/samba/smb.conf
```
��smb.conf������
```
[share]
      path = /home/phinecos/share
      available = yes
      browsealbe = yes
      public = yes
      writable = yes
```
##### ��. ����samba�ʻ�
```
sudo smbpasswd -a root
```
Ȼ���Ҫ��������samba�ʻ�������

���û�е��Ĳ��������¼ʱ����ʾ session setup failed: NT_STATUS_LOGON_FAILURE��

##### ��. ����samba������
```
sudo /etc/init.d/samba restart
```
##### ��. ����
```
smbclient -L //localhost/share
```
##### ��. ʹ��

���Ե�windows������ipʹ���ˣ����ļ��д����� "\\" + "Ubuntu������ip��������" + "\\" + "share"