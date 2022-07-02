#!/bin/sh

# 拉取远程分支
fetchAll(){
  git fetch --all
}

# 获取当前分支名
getCurrentBranch(){
  branchInfo=$(cat .git/HEAD)
  branch=$(echo "$branchInfo" | cut -d/ -f3)
  echo "$branch";
}

# 重制分支
resetHard(){
  currentBranch=$(getCurrentBranch)
  git reset --hard "origin/$currentBranch";
  if [ -n "$1" ] && [ "$currentBranch" != "$1" ]; then
      git checkout "$1";
      if [ $? -eq 1 ]; then
          return;
      fi
  fi
}

# 重制到最新的分支版本
resetToLast(){
  fetchAll;
  resetHard "$1";
  git pull
  deleteUntrackedFiles;
  git diff;
  git status;
}

# 获取未添加到git分支的文件
getUntrackedFiles(){
  git status --porcelain 2>/dev/null | awk '{print $2}'
}

# 删除未添加到git分支的所有文件
deleteUntrackedFiles(){
  getUntrackedFiles | xargs -n1 rm -rf
}

main(){
  case $1 in
    'resetToLast')
      resetToLast "$2"
	  ;;
	  'getUntrackedFiles')
	    getUntrackedFiles
	  ;;
	  'cleanFiles')
	    deleteUntrackedFiles
	  ;;
    *)
      echo 'no options!!'
    ;;
  esac
}

main "$@";
