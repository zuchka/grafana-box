#!/bin/bash

###################################################
#                                                 #
#                   TEMPLATE                      #
#                                                 #
#  build developer environment from main/commit   #
#  . grafana-box.sh windows2016 devenv main       #
#                                                 #
#  build from specific binary                     #
#  . grafana-box.sh centos8 8.1.1                 #
#                                                 #
#  build from OS package manager                  #
#  . grafana-box.sh debian9 package               #
#                                                 #
###################################################

# validate user input
if ! [[ ${1} =~ ^(windows2016|ubuntu2004|debian9|centos8)$ ]]; then
  echo "You have not chosen a valid os. Please choose your parameters from the following list:"
  echo -e "\nwe will put columns here with all the distros and workflows"
  exit
fi

if ! [[ ${2} =~ ^(\d\d\d|devenv|package)$ ]]; then
  echo "You have not chosen a valid workflow. Please choose your parameters from the following list:"
  echo -e "\ndevenv\npackage\n[GRAFANA_VERSION_AS_3_DIGITS] e.g. enter 812 for Grafana Version 8.1.2"
  exit
fi

if ! [[ ${3} =~ ^(main|commit-pattern)$ ]]; then
  echo -e "should we add a special logic to validate commits?"
  exit
fi

echo "all fields validated"


# read -p "Enter your username: "
