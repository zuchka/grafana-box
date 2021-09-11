#!/bin/bash

# getops arg-parsing logic
function usage() { echo -e "Usage: $0 [-d <distro>] [-w <workflow>] [optional: -a <FLAG_ONLY> runs AMD processors instead of default Intel]\n" 1>&2; exit 1; }

function validateArgs () {
    case "${o}" in
        d)
            d="${OPTARG}"
            #pattern-match the argument against a list in a file           
            if ! [[ "${d}" =~ $(echo ^\($(paste -sd'|' ./helpers/distro-list)\)$) ]]; then
                echo -e "You have not chosen a valid distro.\nPlease choose one from the following list:\n"
                cat ./helpers/distro-list
                printf "\n"              
                usage
            else
                DISTRO="${d}"
            fi
            
            if [[ "${DISTRO}" =~ ubuntu ]]; then
                IMAGE_FAMILY="ubuntu-os-cloud"
            elif [[ "${DISTRO}" =~ debian ]]; then
                IMAGE_FAMILY="debian-cloud"
            elif [[ "${DISTRO}" =~ centos ]]; then
                IMAGE_FAMILY="centos-cloud"
            elif [[ "${DISTRO}" =~ rocky ]]; then
                IMAGE_FAMILY="rocky-linux-cloud"
            elif [[ "${DISTRO}" =~ windows ]]; then
                IMAGE_FAMILY="windows-cloud"         
            fi
            ;;
        w)
            w="${OPTARG}"
            if ! [[ "${w}" =~ ^(devenv|package|[0-9]\.[0-9]\.[0-9]+) ]]; then
                echo -e "You have not chosen a valid workflow.\nPlease choose one from the following list:\n\n* package (if available, uses native package manager)\n* devenv  (fresh build from main branch. Grafana Frontend (yarn start) and Backend (make run) launched in detached Tmux sessions)\n* version (enter as 3 digits. -w 7.5.10, for example, will install Grafana version 7.5.10)\n"              
                usage
            elif [[ "${w}" =~ ^[0-9]\.[0-9]\.[0-9]+$ ]]; then
                WORKFLOW="binary"
                GF_VERSION="${w}"
                CPU_COUNT=2
                RAM="4gb"
            elif [[ "${w}" =~ ^devenv ]]; then
                WORKFLOW="devenv"
                BRANCH="${w}"
                CPU_COUNT=8
                RAM="16gb"
            else
                WORKFLOW="${w}"
                CPU_COUNT=2
                RAM="4gb"
            fi
            ;;
        a)
            MACHINE_TYPE="n2d"
            CPU="AMD"
            ;;
        *)
            usage
            ;;
    esac
}

function validateBranch () {
    if [ -z "${BRANCH}" ]; then
        BRANCH="n/a"
    elif [[ "${BRANCH}" =~ ^devenv$ ]]; then
        BRANCH="main"
    else
        # drop first seven characters of ${w} "devenv-"
        BRANCH=$(echo "${BRANCH}" | cut -c 8-)
        echo "checking existence of remote branch '${BRANCH}'"
        
        BRANCH_VAL=$(git ls-remote --heads git@github.com:grafana/grafana.git "${BRANCH}" | wc -l)

        if [[ "${BRANCH_VAL}" == 0 ]]; then
            echo -e "\n${BRANCH} is not a valid remote branch. please try again\n"
            usage
        else 
            echo -e "\n${BRANCH} found. Continuing...\n"
        fi
    fi
}

function nullCheck () {
    # these two parameters can't be null
    if [ -z "${d}" ] || [ -z "${w}" ]; then
        usage
    fi

    # workaround to keep the -a flag optional but set a default when it's absent
    if ! [[ "${MACHINE_TYPE}" =~ ^n2d$ ]]; then
        MACHINE_TYPE="e2"
        CPU="Intel"
    fi
}
function printValues () {
    # report this with ip at end? ram? disk? username? branch? ssh access? browser access?
    printf "\n%s:%30s\n\n" "current configuration" "VALID "
    printf "%21b:%30b\n" \
    "gcp_machine_type"  "${MACHINE_TYPE} " \
    "gcp_image_family"  "${IMAGE_FAMILY} " \
    "gcp_image_project" "${DISTRO}\n" \
    "workflow"          "${WORKFLOW} " \
    "branch"            "${BRANCH}\n" \
    "cpu"               "${CPU} " \
    "cpu_count"         "${CPU_COUNT} " \
    "ram"               "${RAM} " \
    "disk"              "25gb\n" \
    "ssh access"        "ssh grafana@127.168.001.102 " \
    "browser access"    "http://127.168.001.102:3000\n"
}