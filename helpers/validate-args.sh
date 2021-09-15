#!/bin/bash

# getops arg-parsing logic
function usage () { 
    printf "\n%b\n" "Usage: $0 [-d <distro>] [-w <workflow>] [optional: -a <FLAG_ONLY> runs AMD processors instead of default Intel]\n" 1>&2; exit 1; 
}

function validateArgs () {
    case "$1" in
        d)
            d="${OPTARG}"
            #pattern-match the argument against a list in a file           
            if ! [[ "${d}" =~ $(paste -sd'|' ./helpers/distro-list) ]]; then
                printf "%b\n\n" "\nYou have not chosen a valid distro" "Please choose one from the following list:"
                cat ./helpers/distro-list
                printf "%b\n\n" ""
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
                printf "%b" "You have not chosen a valid workflow.\nPlease choose one from the following list:\n\n* package (if available, uses native package manager)\n* devenv  (fresh build from main branch. Grafana Frontend (yarn start) and Backend (make run) launched in detached Tmux sessions)\n* version (enter as 3 digits. -w 7.5.10, for example, will install Grafana version 7.5.10)\n"
                usage
            elif [[ "${w}" =~ ^[0-9]\.[0-9]\.[0-9]+$ ]]; then
                WORKFLOW="binary"
                GF_VERSION="${w}"
                CPU_COUNT=2
                RAM="4gb"
                NODE_VERSION="n/a"
            elif [[ "${w}" =~ ^devenv ]]; then
                WORKFLOW="devenv"
                BRANCH="${w}"
                CPU_COUNT=8
                RAM="16gb"
            else
                WORKFLOW="${w}"
                CPU_COUNT=2
                RAM="4gb"
                NODE_VERSION="n/a"
            fi
            ;;
        n)
            NODE_VERSION="${OPTARG}"
            if ! [[ "${NODE_VERSION}" =~ $(paste -sd'|' ./helpers/nvm-remote-versions) ]]; then
                printf "%b" "You have not chosen a valid node version.\nPlease choose one from the following list:\n"
                cat ./helpers/nvm-remote-versions
                printf "%b\n" ""
                usage
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
        printf "\n%b\n" "checking existence of remote branch '${BRANCH}'"
        
        BRANCH_VAL=$(git ls-remote --heads git@github.com:grafana/grafana.git "${BRANCH}" | wc -l)

        if [[ "${BRANCH_VAL}" == 0 ]]; then
            printf "\n%b\n" "'${BRANCH}' is not a valid remote branch. please try again"
            usage
        else 
            printf "\n%b\n" "${BRANCH} found. Continuing..."
        fi
    fi
}

function nullCheck () {
    # these two parameters can't be null
    if [ -z "${d}" ] || [ -z "${w}" ]; then
        usage
    fi

    # workarounds to keep the -a and -n flags optional but set a default when they're absent
    if [[ -z "${MACHINE_TYPE}" ]]; then
        MACHINE_TYPE="e2"
        CPU="Intel"
    fi

    if [[ -z "${NODE_VERSION}" && "${WORKFLOW}" =~ devenv ]]; then
        NODE_VERSION="--lts"
    fi  
}
function printValues () {
    MACHINE_IP=$(terraform -chdir="${GFB_FOLDER}"/ output -raw instance_ip)

    printf "\n%s:%30s\n\n" "current configuration" "VALID "
    printf "%21b:%30b\n" \
    "gcp_machine_type"  "${MACHINE_TYPE} " \
    "gcp_image_family"  "${IMAGE_FAMILY} " \
    "gcp_image_project" "${DISTRO}\n" \
    "workflow"          "${WORKFLOW} (${GF_VERSION}) " \
    "branch"            "${BRANCH} " \
    "NodeJS version"    "${NODE_VERSION}\n" \
    "cpu"               "${CPU} " \
    "cpu_count"         "${CPU_COUNT} " \
    "ram"               "${RAM} " \
    "disk"              "25gb\n" \
    "ssh access"        "ssh grafana@${MACHINE_IP} " \
    "browser access"    "http://${MACHINE_IP}:3000\n"
}
