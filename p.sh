#!/bin/bash

if [[ "$BASH_SOURCE" == "$0" ]]; then
	ABSOLUTE_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)/`basename "${BASH_SOURCE[0]}"`;
    echo "This ($ABSOLUTE_PATH) is a source script, and should not be run directliy. Rather source the script by running:
source $ABSOLUTE_PATH;
p;
    "
fi

function _p {
	local pfile="${_P_DATA:-$HOME/.p}/projects"
	[ -f "$pfile" ] || { mkdir -p $(dirname "$pfile") && touch "$pfile"; }

	#since we only have one argument, it is simple to parse it. (works for 'create' as well.)
	[ "$1" == "-s" ] && local _p_subshell="true" && shift;

	[ "$1" == "create" ] && {
		path="$3";
		[ "$path" == "" ] && path="$(pwd)";
		[ -d "$path" ] || {
			echo "ERROR: path $path does not exist";
			return 1;
		}
		path="$(cd $path > /dev/null; pwd)";
		pname=${2-`basename $path`};
		[ "$pname" == "" ] && pname=`basename $path`;
		_p_project_exists "$pname" && {
			echo "ERROR: project $pname exists";
			return 1;
		}
		echo "$pname $path" >> "$pfile";
		# Jump to the newly created project
		_p "$pname";
		return 0;
	}
	[ "$1" == "path" ] && {
		_p_path "$2";
		return $?;
	}
	[ "$1" == "runall" ] && {
		_p_projects | while read projectname; do
			#Enhancement, match the projectname to a parameter to run the command in a subset of all projects.
			(
				#Can not run .pfile as it can be written to do more than the runall intends. 
				#For instance, the example pfile prints vcs status. Two solutions would be to
				#either add a runall kind of enter-verb to the pfile interface or use a flag to enable the pfile in this case.
				#Applies to runin as well.
				shift;
				cd `_p_path $projectname` > /dev/null;
				echo "$projectname> $@"
				eval $@;
			)
		done;
		return 0; #TODO Return fail if any failed.
	}
	[ "$1" == "runin" ] && {
		projectname=$2;
		_p_project_exists "$projectname" || {
			echo "ERROR: project does not exist: $projectname";
			return 1;
		} 
			(
				#TODO: .pfile-solution from runall as well here.
				shift;shift;
				cd `_p_path $projectname` > /dev/null;
				echo "$projectname> $@"
				eval $@;
			)
		return $?;
	}
	[ "$1" == "global" ] && {
		projectname=$2;
		_p_project_exists "$projectname" || {
			echo "ERROR: for p global, project does not exist: $projectname";
			return 1;
		} 
		pdir=$(_p_path "$projectname") || {
			echo "Unknown project: $projectname"
			return 1;
		}
		PROJECT_HOME="$pdir"; #TODO: not so nice, this will reset existing value, a .pfile may also depend on PROJECT_HOME after sourcing.
		source "$pdir/.pfile.sh" "global" "$projectname" "$pdir"
		unset PROJECT_HOME;
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

	pdir=$(_p_path "$proj");
	[ -d "$pdir" ] || { echo -e "ERROR: project $proj points to directory $pdir which does not exist.\nTo fix, edit file: $pfile"; return 1; }
	#TODO: enable subshell by flag
	[ "$_p_subshell" != "true" ] && {
		echo -e "Opening project \033[0;32m$proj\033[0m at $pdir";
		cd "$pdir" > /dev/null;
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
		cd "$pdir" > /dev/null && _p_title "$proj";
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

alias ${_P_CMD:-p}='_p'

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
	local pfile="${_P_DATA:-$HOME/.p}/projects"
	[ -f $pfile ] && awk '{print $1}' < "$pfile";
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
