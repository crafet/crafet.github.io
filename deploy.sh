cd ./public # Hexo ���ɵ�Ŀ¼Ĭ���� public ��
git init # ��ʼ��һ�� Repo
git config --global push.default matching
git config --global user.email "${GitHubEMail}"
git config --global user.name "${GitHubUser}" # �����ڻ��������ж������Ϣ���� Git
cp  ../themes/ ./ -r
git add --all .
git commit -m "Auto Builder of ${GitHubUser}'s Blog" # commit ��Ϣ

git push --quiet -f https://${GitHubKEY}@github.com/${GitHubUser}/${GitHubRepo}.git master # �����ɵľ�̬��վ����ָ�� Repo �� master ��֧��