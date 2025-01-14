#!/bin/bash

# Predix Dev Bootstrap Script
# Authors: GE SDLP 2015
#
# These are a group of helper methods that will perform actions around local-setup
#

function run_mac_setup() {
	#get the url and branch of the requested repo from the version.json
	__readDependency "local-setup" LOCAL_SETUP_URL LOCAL_SETUP_BRANCH

  echo "Let's start by verifying that you have the required tools installed."
  read -p "Should we install the required tools if not already installed? ($TOOLS) > " -t 30 answer
  if [[ -z $answer ]]; then
      echo -n "Specify (yes/no)> "
      read answer
  fi
  if [[ ${answer:0:1} == "y" ]] || [[ ${answer:0:1} == "Y" ]]; then
		if [[ $LOCAL_SETUP_URL == *"github.com"* ]]; then
			LOCAL_SETUP_URL="${LOCAL_SETUP_URL/github.com/raw.githubusercontent.com}"
		else
			if [[ $LOCAL_SETUP_URL == *"github.build"* ]]; then
				LOCAL_SETUP_URL="${LOCAL_SETUP_URL/github.build.ge.com/github.build.ge.com/raw}"
			fi
		fi
		SETUP_MAC="$LOCAL_SETUP_URL/$LOCAL_SETUP_BRANCH/setup-mac.sh"
    bash <(curl -s -L $SETUP_MAC) $TOOLS_SWITCHES
  fi
}

function __print_out_standard_usage
{
  echo -e "**************** Usage ***************************"
	echo -e "     ./$SCRIPT_NAME [ options ]\n"
  echo -e "     options are as below"
  echo "        [-b|          --branch]                        => Github Branch, default is master"
  echo "        [-cf|         --continue-from]                 => After passing -cf switch, add the switch from which you want to continue"
  echo "        [-skip-setup| --skip-setup]                    => Skip the installation of tools"
  echo "        [-o|          --override]                      => After passing -o switch, list the features you want to install"
  echo "        [-h|-?|--?|   --help]                          => Print usage"

	echo -e "     *** examples\n"
  echo -e "     ./$SCRIPT_NAME                                                       => install all features"
  echo -e "     ./$SCRIPT_NAME --skip-setup                        => skip the installation of tools"
  echo -e "     ./$SCRIPT_NAME --continue-from -xxx                => start from the feature -xxx, skipping anything before that"
  echo -e "     ./$SCRIPT_NAME --override -yyy                     => only run the yyy service install feature"
  echo -e "**************************************************"
}

function __standard_mac_initialization() {
  echo ""
  echo "Welcome to the $APP_NAME Quick Start."
  __print_out_standard_usage
  echo "SKIP_SETUP            : $SKIP_SETUP"
  echo "BRANCH                : $BRANCH"
  echo "QUICKSTART_ARGS       : $QUICKSTART_ARGS"
  run_mac_setup
  echo ""
  echo "The required tools have been installed or you have chosen to not install them. Proceeding with the setting up services and application."
  echo ""
  echo ""
}

function __echoAndRun() {
  echo $@
  $@
}

function __verifyAnswer() {
  if [[ -z $answer ]]; then
    echo -n "Specify (yes/no)> "
    read answer
  fi
  if [[ ${answer:0:1} == "y" ]] || [[ ${answer:0:1} == "Y" ]]; then
    answer="y"
  else
    answer="n"
  fi
}



function __pause() {
	if [[ $SKIP_INTERACTIVE == 0 ]]; then
		read -n1 -r -p "Press any key to continue..."
	  echo ""
	fi
}
#	----------------------------------------------------------------
#	Function for echoing a command and then running it
#		Accepts any number of arguments:
#	----------------------------------------------------------------
__echo_run() {
  echo $@
  $@
  return $?
}

#	----------------------------------------------------------------
#	Function for creating an asset with metadata
#		Accepts 3 arguments:
#			string of Directory to which to clone
#			string indicating whether to not remove directory
#  Returns:
#	----------------------------------------------------------------
function getGitRepo() {
	__validate_num_arguments 1 $# "\"curl_helper_funcs:getGitRepo\" Directory to clone to, optional arg whether to remove dir" "$logDir"

	if [[ $2 == "" ]] || $2 == "false" || $2 == "FALSE" ]]; then
		rm -rf $1
	fi
	currentDir=$(pwd)
	echo $currentDir
	if [[ $currentDir/ == *"$1/"* ]]; then
		cd ..
		if [ -d "$1" ]; then
			__append_new_line_log "copy $1 dir to.. $currentDir" "$logDir"
			mkdir -p $currentDir/$1
			find $1/* -maxdepth 0 -type f -not \( -path $1/predix-scripts -prune \) -not \( -path $1/.git -prune \) -exec cp '{}' predix-scripts/$1 2>>/dev/null ';'
			find $1/.* -maxdepth 0 -type f -not \( -path $1/predix-scripts -prune \) -not \( -path $1/.git -prune \) -exec cp '{}' predix-scripts/$1 2>>/dev/null ';'
			find $1/* -maxdepth 0 -type d -not \( -path $1/predix-scripts -prune \) -not \( -path $1/.git -prune \) -exec cp -R '{}' predix-scripts/$1 ';'
			cd $currentDir
			return
		else
			cd ..
			pwd
			if [ -d "$1" ]; then
				__append_new_line_log "copy $1 dir to... $currentDir" "$logDir"
				mkdir -p $currentDir/$1
				find $1/* -maxdepth 0 -type f -not \( -path $1/predix-scripts -prune \) -not \( -path $1/.git -prune \) -exec cp '{}' $1/predix-scripts/$1 2>>/dev/null ';'
				find $1/.* -maxdepth 0 -type f -not \( -path $1/predix-scripts -prune \) -not \( -path $1/.git -prune \) -exec cp '{}' $1/predix-scripts/$1 2>>/dev/null ';'
				find $1/* -type d -not \( -path $1/predix-scripts -prune \) -not \( -path $1/.git -prune \) -exec cp -R '{}' $1/predix-scripts/$1 ';'
				cd $currentDir
				return
			else
				__append_new_line_log "$1 dir not available to copy, will git clone" "$logDir"
			fi
		fi
		cd ..
	else
		cd ..
		if [ -d "$1" ]; then
			__append_new_line_log "copy $1 dir to.... $currentDir" "$logDir"
			mkdir -p $currentDir/$1
			find $1/* -maxdepth 0 -type f -not \( -path $1/predix-scripts -prune \) -not \( -path $1/.git -prune \) -exec cp '{}' predix-scripts/$1 2>>/dev/null ';'
			find $1/.* -maxdepth 0 -type f -not \( -path $1/predix-scripts -prune \) -not \( -path $1/.git -prune \) -exec cp '{}' predix-scripts/$1 2>>/dev/null ';'
			find $1/* -maxdepth 0 -type d -not \( -path $1/predix-scripts -prune \) -not \( -path $1/.git -prune \) -exec cp -R '{}' predix-scripts/$1 ';'
			cd $currentDir
			return
		else
			__append_new_line_log "$1 dir not available to copy, will git clone" "$logDir"
		fi
	fi

	#get using git, look in version.json to find the reponame and branch
	cd $currentDir
	getRepoURL $1 git_url ../version.json
	getRepoVersion $1 branch ../version.json
	if [ ! -n "$branch" ]; then
		branch="$BRANCH"
	fi
	if git clone -b "$branch" "$git_url" "$1"; then
		__append_new_line_log "Successfully cloned \"$git_url\" and checkout the branch \"$branch\"" "$logDir"
	else
		__error_exit "There was an error cloning the repo \"$1\". Is the repo listed in version.json?  Also, be sure to have permissions to the repo, or SSH keys created for your account" "$logDir"
	fi
}
