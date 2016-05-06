#!/usr/bin/env bash

eval P_SOURCEFILE_LOCAL="$HOME/.p.sh";
eval P_SOURCEFILE_REMOTE="https://raw.githubusercontent.com/hhallman/p/master/p.sh";
eval P_PROJECTFILE_USER_LOCAL="$HOME/.pfile.sh";
eval P_PROJECTFILE_USER_REMOTE="https://raw.githubusercontent.com/hhallman/p/master/example-pfile.sh";
eval USER_BASHRC_NOPROFILE="$HOME/.bashrc"
eval USER_BASHRC_PROFILE="$HOME/.bash_profile"

function FAIL {
	echo -e "\033[31m[FAIL]\033[0m $@";
	exit 1;
}

function STEP {
	echo -e "\033[34m[STEP]\033[0m $@";
}

function NOTE {
	echo -e "\033[33m[NOTE]\033[0m $@";
}

function DONE {
	echo -e "\033[32m[DONE]\033[0m $@";
}

STEP "Downloading files into $P_SOURCEFILE_LOCAL, $P_PROJECTFILE_USER_LOCAL";
curl -s -o "$P_SOURCEFILE_LOCAL" "$P_SOURCEFILE_REMOTE" || 
	FAIL "Could not download $P_SOURCEFILE_REMOTE to $P_SOURCEFILE_LOCAL";
[ -f "$P_PROJECTFILE_USER_LOCAL" ] && {
	NOTE "Local projectfile already exists, ($P_PROJECTFILE_USER_LOCAL) will not overwrite. Consider updating from: $P_PROJECTFILE_USER_REMOTE"
}
[ -f "$P_PROJECTFILE_USER_LOCAL" ] || {
	curl -s -o "$P_PROJECTFILE_USER_LOCAL" "$P_PROJECTFILE_USER_REMOTE" || 
		FAIL "Could not download $P_PROJECTFILE_USER_REMOTE to $P_PROJECTFILE_USER_LOCAL";
}

function install_to_script {
	USER_BASHRC="$1";
	STEP "Configuring bash profile: $USER_BASHRC";
	[ -f $USER_BASHRC ] || { NOTE "Creating file: $USER_BASHRC"; }
cat >> $USER_BASHRC << EOF

#############
# Set up p-project manager. (info: https://github.com/hhallman/p )
[ -f $P_SOURCEFILE_LOCAL ] || {
	echo "ERROR: p project-manager script is missing. Please check https://github.com/hhallman/p or clean script: $USER_BASHRC ";
}
[ -f $P_SOURCEFILE_LOCAL ] && {
	. $P_SOURCEFILE_LOCAL;
}
# end-of-p
#############

EOF
}
#p project manager should be accessible in both login and nologin shells:
install_to_script "$USER_BASHRC_NOPROFILE";
install_to_script "$USER_BASHRC_PROFILE";

DONE "Done setting up p project-manager. Use 'p create' to create a project";
NOTE "To load p project-manager into the current shell, run the following command: (Automatic in new shells.)"
echo "source $P_SOURCEFILE_LOCAL"

