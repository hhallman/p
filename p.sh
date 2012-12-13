#!/bin/bash

if [[ "$BASH_SOURCE" == "$0" ]]; then
	ABSOLUTE_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)/`basename "${BASH_SOURCE[0]}"`;
    echo "This ($ABSOLUTE_PATH) is a source script, and should not be run directliy. Rather source the script by running:
source $ABSOLUTE_PATH;
p;
    "
fi

function p {
	eval pfile="~/.p/projects"
	[ -f "$pfile" ] || { mkdir -p $(dirname "$pfile") && touch "$pfile"; }
	[ "$1" == "create" ] && {
		[ "$2" == "" ] && {
			echo "Usage p create <project-name> [project-path]";
			return 1;
		}
		path="$3";
		[ "$path" == "" ] && path="$(pwd)";
		[ -d "$path" ] || {
			echo "ERROR: path $path does not exist";
			return 1;
		}
		_p_project_exists "$2" && {
			echo "ERROR: project $1 exists";
			return 1;
		}
		echo "$2 $path" >> "$pfile";
		# Jump to the newly created project
		p "$2";
		return 0;
	}
	[ "$1" == "path" ] && {
		_p_path "$2";
		return $?;
	}
	[ "" == "$1" ] && {
		echo "Usage: p <project>";
		return 1;
	}
	proj="$1";
	grep -q "^$proj " "$pfile" || {
		echo "No project named $1 could be found. Create it with 'p create $1 <path>'";
		return 1;
	}

	pdir=$(_p_path "$proj");
	[ -d "$pdir" ] || { echo -e "ERROR: project $proj points to directory $pdir which does not exist.\nTo fix, edit file: $pfile"; return 1; }
	#TODO: enable subshell by flag
	[ "$_p_subshell" != "true" ] && {
		echo -e "Opening project \033[0;32m$proj\033[0m at $pdir";
		cd "$pdir";
		_p_title "$proj";
		[ -f ~/.pfile.sh ] && {
			source ~/.pfile.sh "enter" "$proj" "$pdir";
		}
		[ -f ".pfile.sh" ] && {
			source ".pfile.sh" "enter" "$proj" "$pdir";
		}
	}
	[ "$_p_subshell" == "true" ] && {
		echo -e "Opening project \033[0;32m$proj\033[0m at $pdir in subshell";
		(export PS1;
		cd "$pdir" && _p_title "$proj";
		_p_title "$proj";
		export HISTFILE=~/.p/bash_history_${proj};

		local PINITFILE="/tmp/p-init-$$";
		cat > $PINITFILE <<.
		[ -f ~/.bashrc ] && source ~/.bashrc;
		[ -f ~/.pfile.sh ] && {
			source ~/.pfile.sh "enter" "$proj" "$pdir";
		}
		[ -f "./.pfile.sh" ] && {
			source "./.pfile.sh" "enter" "$proj" "$pdir";
		}
		function _p_current_exit {
			[ -f ~/.pfile.sh ] && {
				source ~/.pfile.sh "leave" "$proj" "$pdir";
			}
			[ -f "./.pfile.sh" ] && {
				source "./.pfile.sh" "leave" "$proj" "$pdir";
			}			
		}
		trap _p_current_exit EXIT;
		rm $PINITFILE;
.

		bash --init-file $PINITFILE;
		echo -e "exit project \033[0;32m$proj\033[0m"
		_p_title "$proj."
		);
	}
}

function _p_path {
	grep "^$1 " "$pfile" | head -1 | awk '{print $2}';
	_p_project_exists "$1"; #To get correct return code
}

function _p_title {
	title="$@";
	echo -ne "\033]0;$title\007";
}

function _p_project_exists {
	_p_projects | grep -q "^$1$";
}

function _p_projects {
	eval pfile="~/.p/projects"
	awk '{print $1}' < "$pfile";
}

_p_complete() 
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="$(_p_projects)"

    if [[ $COMP_CWORD == 1 ]] ; then
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi
}
complete -F _p_complete p
