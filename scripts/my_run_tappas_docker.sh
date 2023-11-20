#!/bin/bash

TAPPAS_IMAGE=""
CONTAINER_TAG=""
CONTAINER_NAME="test1"
IMAGE_NAME="test1"
XAUTH_FILE_PC=/tmp/hailo_docker.xauth
XAUTH_FILE_CONTAINER=/home/hailo/.Xauthority
SHARED_DIR="shared_with_docker"
HAILORT_ENABLE_SERVICE=false

TAPPAS_VERSION_FILE=$(dirname $(realpath "$0"))
TAPPAS_VERSION_FILE="$TAPPAS_VERSION_FILE/.tappas_version"

function print_usage() {
    echo "Run Hailo Docker:"
    echo "The default mode is trying to create a new container"
    echo "./run_tappas_docker [options] "
    echo "Options:"
    echo "  --help               Show this help"
    echo "  --tappas-image       Path to tappas image"
    echo "  --resume             Resume an old container"
    echo "  --container-name     Start a container with a specific name, defaults to hailo_tappas_container"
    exit 1
}

function parse_args() {
    while test $# -gt 0; do
        if [[ "$1" == "-h" || "$1" == "--help" ]]; then
            print_usage
        elif [ "$1" == "--resume" ]; then
            RESUME_CONTAINER=true
        elif [ "$1" == "--tappas-image" ]; then
            IMAGE_NAME=$2
            shift
        elif [ "$1" == "--container-name" ]; then
            CONTAINER_NAME=$2
            shift
        elif [ "$1" == "--hailort-enable-service" ]; then
            HAILORT_ENABLE_SERVICE=true
        else
            echo "Unknown parameters, exiting"
            print_usage
            exit 1
        fi
        shift
    done
}

function prepare_docker_args() {
    DOCKER_ARGS="--privileged --net=host \
        --name "$CONTAINER_NAME" \
        --user 1000:1000 \
        --ipc=host \
        --cap-add=IPC_OWNER \
        --device /dev/dri:/dev/dri \
        -v ${XAUTH_FILE_PC}:${XAUTH_FILE_CONTAINER} \
        -v /tmp/.X11-unix/:/tmp/.X11-unix/ \
        -v /dev:/dev \
        -v /lib/firmware:/lib/firmware \
        --group-add 44 \
        -e DISPLAY=$DISPLAY \
        -e XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
        -e hailort_enable_service=yes \
        -v /tmp/hailort_uds.sock:/tmp/hailort_uds.sock \
        -v $(pwd)/${SHARED_DIR}/:/local/${SHARED_DIR}:rw"
}

function handle_xauth() {
    # The function extracts auth entry for current display and saves it to specified file.
    # It's a workaround for ub22 random name of xauth file, which changes every reboot.
    touch $XAUTH_FILE_PC
    xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH_FILE_PC nmerge -
    chmod o+rw $XAUTH_FILE_PC
}

function create_shared_dir() {
    mkdir -p ${SHARED_DIR}
    chmod o+rwx ${SHARED_DIR}
}

function run_docker() {
    # Critical for display
    xhost local:root
    handle_xauth
    create_shared_dir

    if [ "$RESUME_CONTAINER" = true ]; then
        # Finding out if a container already exists
        if [[ $(docker ps -a -q -f "name=$CONTAINER_NAME" | wc -l) -lt "1" ]]; then
            echo "No container found. please run for the first time without --resume"
            exit 1
        fi

        echo "Resuming an old container"
        # Start and then exec in order to pass the DISPLAY env, because this vairble
        # might change from run to run (after reboot for example)
        docker start "$CONTAINER_NAME"
        #docker exec -it  -e DISPLAY=$DISPLAY "$CONTAINER_NAME" /bin/bash
        docker exec -it --user elsabot -e DISPLAY=$DISPLAY "$CONTAINER_NAME" /bin/bash

    else
        echo "Starting a new container"
        export XAUTH_FILE=$(xauth info | head -n1 | tr -s ' ' | cut -d' ' -f3)

        os_distribution=$(cat /etc/os-release | grep ^ID= | awk -F'=' '{print $2}' | xargs)

        if [[ $os_distribution != "ubuntu" && $os_distribution != "debian" ]]; then
            echo "OS: $os_distribution is not supported"
            exit 1
        fi

        prepare_docker_args
        
        docker run $DOCKER_ARGS -it $IMAGE_NAME
    fi
}

parse_args "$@"
# start hailort container
run_docker
