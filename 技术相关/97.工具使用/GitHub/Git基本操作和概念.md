##### Fork ��ĳ���ض��ֿ⸴�Ƹ��Լ�
##### ����ȫ����Ϣ
git config --global
���磺
git config --global user.email "enzesheng@foxmail.com"
##### �����ļ����ļ���
git add filename|foldername
##### �ύ
git commit -m "Comments"
##### ���͵�����ֿ�
git push


#### Git��������
##### ��ʼ���ֿ� git init
���뵽��ӦĿ¼ִ�У�ִ����ɺ������ .git Ŀ¼�����Ŀ¼�´����git������ص��ļ�
##### git status   --�鿴�ֿ�״̬  
##### git add      --���ݴ������ύ�ļ����ļ��� 
##### git commit   --����ֿ����ʷ��¼ 
##### git log      --�鿴�ύ��־ 
ֻ��ʾ�ύ��Ϣ��һ�� git log --pretty=short

ֻ��ʾָ��Ŀ¼���ļ�����־ git log README.md

��ʾ�ļ��ĸĶ� git log -p README.md

��ͼ�η�ʽ��ʾ��־ git log --graph

##### git reflog   --�鿴��ǰ�ֿ�ִ�й������в���
##### git diff     --�鿴����ǰ��ĵĲ�� 
�鿴�����ύ���ϴ��ύ�Ĳ�𣨼��޸���ʲô�� git diff HEAD

#### Git��֧��ز���
##### git branch       --��ʾ��֧һ����
##### git checkout -b  --�������л���֧
git checkout -  �л���һ����֧
git checkout name  �л�ָ����֧
##### git merge        --�ϲ���֧
ǰ�᣺ ���лص�Ҫ������Ǹ���֧

git merge --no-ff Ҫ�ϲ��ķ�֧����

##### git reset --hard    --Ŀ��hashֵ  ���ݻ��ƽ���ָ���汾
##### git commit --amend  --�޸��ύ��Ϣ
##### git branch -d name  --ɾ��ָ����֧
