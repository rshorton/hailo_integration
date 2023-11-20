# hailo_integration


## Build Docker

This Docker is based on the Hailo Tappas docker and includes:
  * ROS2 Humble
  * Add user elsabot with the same UID/GID as the main user.  This was found to be needed for DDS to work.
 
To build: 

     docker build --tag test1 .

## Running

First time, run of container:

     ./my_run_tappas_docker.sh --tappas-image test1

then shell in as hailo user:

     docker exec -it  --user hailo 492f /bin/bash   

and:

>* sudo useradd elsabot -u 1000 -g ht -m -s /bin/bash
>* sudo adduser elsabot sudo
>* sudo passwd elsabot
>* copy ~/hailo/.bash* files from hailo user to elsabot user.

To run additional shells in container as elsabot user:

     docker exec -it  --user elsabot 492f /bin/bash

## Setup ros-gst-bridge

* Cloned https://github.com/BrettRD/ros-gst-bridge (also forked to make one change)
* Cloned into /local/shared_with_docker to make the files more easily accessiable outside the container.
* Followed readme instructions (ROS already installed in Docker) to build.

## Other

The my_run_tappas_docker.sh was modified as follows:

* Added this to the run docker script in the prepare function:
   --cap-add=IPC_OWNER
*  Not sure if that is needed since that alone did not resolve the issue with DDS not working (until adding elsabot user).
*  Changed run script to specify --user elsabot
    docker exec -it --user elsabot -e DISPLAY=$DISPLAY "$CONTAINER_NAME" /bin/bash

ros-gst-bridge was modified to include pixel-aspect-ratio cap.