#example p-file
#$1 = "enter/leave" $2 = 'project name' $3 = 'project directory'
[ "$1"  == "enter" ] && [ -d .git ] && echo "git status" && git status;
[ "$1"  == "enter" ] && [ -d .svn ] && echo "svn status" && svn status;

export PROJECT_HOME="$3"
alias home='cd $PROJECT_HOME';

function _p_snapshot_aliases {
	local afile="${_P_DATA:-$HOME/.p}/$2-aliases"
	alias > $afile;
}

function _p_compare_aliases {
	function _p_asksave {
		while true; do
			echo -n "Save the new alias? [y]/n: ";
			read q < /dev/tty;
			case $q in
				"y") return 0;;
				"n") return 1;;
				"") return 0;;
			esac;
		done;
	}

	local afile="${_P_DATA:-$HOME/.p}/$2-aliases"
	diff $afile <(alias) | grep '>' | sed 's/^> //' | while read al; do
		aname=$(echo $al|sed 's/alias \([^=]*\)=.*/\1/')
		grep -q "$al" "$3/.pfile.sh" || {
			echo "new alias: $al";
			existing=false
			grep -q "alias $aname=" "$3/.pfile.sh" && existing=true &&
				echo -n "previous definition: " && grep -o "alias $aname=.*" "$3/.pfile.sh" &&
				echo -n "     new definition: " && alias $aname;
			_p_asksave && {
				lpfile="$3/.pfile.sh"
				echo "saving $al to project $2 ($lpfile)";
				[ "$existing" == "true" ] && sed -i .tmp "/.*alias $aname=.*/c\\
[ \"\$1\" == \"enter\" ] && $al
" $lpfile && rm "$lpfile.tmp"
				[ "$existing" != "true" ] && echo '[ "$1" == "enter" ] && '"$al" >> $lpfile;
			}
		}
	done;
}

[ "$1" == "enter" ] && _p_snapshot_aliases $@;
[ "$1" == "leave" ] && _p_compare_aliases  $@;
