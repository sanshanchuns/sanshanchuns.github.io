#!/bin/sh

remotes=`git remote`
# echo ${remotes#origin}
remote1=${remotes:0:6}
#remote2=${remotes:7}
current_branch=`git rev-parse --abbrev-ref HEAD`
if [ -z "$1" ];then
	git add .
	git ci -m"update files"
	git push $remote1 $current_branch
#	git push $remote2 $current_branch
else
	git add .
	git ci -m"$1"
	git push $remote1 $current_branch
#	git push $remote2 $current_branch
fi
