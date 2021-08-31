#!/bin/bash

###################################################
#                                                 #
#                COMMAND EXAMPLES                 #
#  pattern:                                       #
#  . grafana-box.sh <OS> <WORKFLOW> <ARCH>        #
#                                                 #
#  build developer environment:                   #
#  . grafana-box.sh centos-8 devenv intel         #
#                                                 #
#  build from specific binary on AMD EPYC:        #
#  . grafana-box.sh windows-2016 8.1.1 amd        #
#                                                 #
#  build from native package manager:             #
#  . grafana-box.sh debian-9 package intel        #
#                                                 #
###################################################


usage() { echo "Usage: $0 [-d <string>] [-w <string>] [-p <string>]" 1>&2; exit 1; }

while getopts ":d:w:p:" o; do
    case "${o}" in
        d)
            d=${OPTARG}            
            if ! [[ "$d" =~ $(echo ^\($(paste -sd'|' distro-list)\)$) ]]; then
              usage
            fi
            ;;
        w)
            w=${OPTARG}
            ;;
        p)
            p=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${d}" ] || [ -z "${w}" ]; then
  usage
fi

DISTRO=${d}
PROCESSOR=${p}
WORKFLOW=${w}

echo $PROCESSOR