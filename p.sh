#!/bin/bash

if [[ "$BASH_SOURCE" == "$0" ]]; then
	ABSOLUTE_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)/`basename "${BASH_SOURCE[0]}"`;
    echo "This ($ABSOLUTE_PATH) is a source script, and should not be run directliy. Rather source the script by running:
source $ABSOLUTE_PATH;
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
	[ "" == "$1" ] && {
		echo "Usage: p <project>";
		return 1;
	}
	proj="$1";
	grep -q "^$proj " "$pfile" || {
		echo "No project named $1 could be found. Create it with 'p create $1 <path>'";
		return 1;
	}

	pdir=$(grep "^$proj " "$pfile" | head -1 | awk '{print $2}');
	#TODO: this color coding does not work on OSX mountain lion.
	echo -e "Switching to project \e[0;32m$proj\e[0m at $pdir";
	#TODO: enable subshell by flag
	[ "$_p_subshell" != "true" ] && {
		cd "$pdir" && _p_title "$proj";
		[ -f ".pfile.sh" ] && {
			source ".pfile.sh" "$proj";
		}
	}
	[ "$_p_subshell" == "true" ] && {
		(export PS1;
		cd "$pdir" && _p_title "$proj";
		_p_title "-$proj";
		bash; #TODO: make bash start by eval the local .pfile.sh file
		echo -e "exit project \e[0;32m$proj\e[0m"
		_p_title "$proj."
		);
	}
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
