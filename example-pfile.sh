[ "$1"  == "enter" ] && [ -d .git ] && echo "git status" && git status;
[ "$1"  == "enter" ] && [ -d .svn ] && echo "svn status" && svn status;
