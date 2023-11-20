# hailo_integration

## Overview

This project contains a few files used to setup Hailo AI Tappas so it can be used for the Elsabot project with the OAK-D camera serving as the Camera source.  Tappas is an example framework provided by Hailo AI for demonstrating various example uses for the Hailo 8 TPU.  Tappas is provided as a Docker image.  A Hailo 8 TPU on an m.2 pcie card was used.

Currently, the facial recognition Tappas example pipeline is used to implement facial recognition using various AI models run on a Hailo 8 TPU.  Camera frames from the OAK-D camera received by the Vision node of the robot_head ROS package are published to the topic /color/image_to_hailo.  The ros-gst-bridge package is used to implement a node that provides a gstreamer source element for receiving those frames and passing them down the pipeline created by the face_recognition.sh script.

The detection/recognition output meta data is exported from the pipeline using a ZMQ publisher element provided by Hailo.  That data is received by the Vision node of the robot_head package and integrated with the detection info obtained from the OAK-D (which perform basic person detection and tracking).  The additional facial recognization data is then available to upper level processing (like the elsabot_bt node using behavior trees).

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