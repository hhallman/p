p - bash project manager


P(1)				 User Commands				  P(1)



NAME
       p - project manager


SYNOPSIS
       p [create] proeject-name


AVAILABILITY
       bash


DESCRIPTION
       Utility for your shell that lets you easily step to project directories while
       loading a project-specific profile into your shell.

       You can use a user-wide profile ('pfile') and/or project specific profiles.

OPTIONS
       −s step to the project directory in a subshell.


EXAMPLES
       p foo	 	open project foo
       p -s foo 	open project foo in subshell
       p create bar create and open project bar in current directory


NOTES
       Installation:

       Put something like this in your $HOME/.bashrc or $HOME/.zshrc:

	. /path/to/p.sh

       create some projects and enjoy!

       Optionally:
	Set $_P_CMD to change the command name (default p).
	(These settings should go in .bashrc/.zshrc  before  the  lines  added
       above.)
	Install  the provided man page p.1 somewhere like /usr/local/man/man1.


       Tab Completion:

       p supports tab completion. After typing the p command, press TAB  to
       complete project names that match (optionally) written project names.

PFILES
       When opening a project, p will source global and local 'pfiles',
       ~/.pfile and ./.pfile with arguments "enter" "project-name" "project-directory".
       If the project is loaded in subshell, the pfiles will be sourced with "leave" 
       instead of "enter" when the shell exits.
       Example of global pfile:
       		[ "$1"  == "enter" ] && [ -d .git ] && echo "git status" && git status;
			[ "$1"  == "enter" ] && [ -d .svn ] && echo "svn status" && svn status;	


ENVIRONMENT
       A function _p() is defined.

       The contents of the variable $_P_CMD is aliased to _p. If not set,
       $_P_CMD defaults to p.


       To set the subshell behavior as default, set variable _p_subshell=true


FILES
       Data is stored in $HOME/.p. This  can  be  overridden  by  setting  the
       $_P_DATA environment variable.

       A man page (p.1) is provided.


SEE ALSO
       z(1), pushd, popd, 

       Please file bugs at https://github.com/hhallman/p/

       This project has been inspired by the z bash extension by "Rupa".
       Please use it, z is awesome! https://github.com/rupa/z



p				 December 2012				  P(1)