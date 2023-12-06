# hailo_integration

## Overview

This project contains a few files used to setup Hailo AI Tappas so it can be used for the Elsabot project with the OAK-D camera serving as the Camera source.  Tappas is an example framework provided by Hailo AI for demonstrating numerous example uses for the Hailo 8 TPU.  Tappas is provided as a Docker image.

A Hailo-8 TPU on an m.2 pcie card was used for the Elsabot project.

Currently, a modified version of the facial recognition Tappas example pipeline is used to implement facial recognition using various AI models run on a Hailo 8 TPU.  This
pipeline also includes a person re-id sub-pipeline.  Camera frames from the OAK-D camera received by the Vision node of the robot_head ROS package are published to the topic /color/image_to_hailo.  The ros-gst-bridge package is used to implement a node that provides a gstreamer source element for receiving those frames and passing them down the gstreamer pipeline created by the face_recognition_with_reid.sh script.

The detection/recognition output meta data is exported from the pipeline using a ZMQ publisher element provided by Hailo.  That data is received by the Vision node of the robot_head package and integrated with the detection and depth info obtained from the OAK-D.  The additional facial recognition data is then available to upper level processing (like the elsabot_bt node using behavior trees).

## Build Docker

This Docker is based on the Hailo Tappas docker and includes:
  * ROS2 Humble
  * Additional user elsabot with the same UID/GID as the main user.  This was found to be needed for ROS DDS to work.
 
To build: 

     docker build --tag test1 .

## Running

First time run of the container:

     ./my_run_tappas_docker.sh --tappas-image test1

then shell in as hailo user:

     docker exec -it  --user hailo 492f /bin/bash   

and:

>* sudo useradd elsabot -u 1000 -g ht -m -s /bin/bash
>* sudo adduser elsabot sudo
>* sudo passwd elsabot
>* copy ~/hailo/.bash* files from hailo user to elsabot user.

Subsequent runs of the container:

     ./my_run_tappas_docker.sh --resume

To run additional shells in container as elsabot user:

     docker exec -it  --user elsabot 492f /bin/bash


## Setup of ros-gst-bridge

* Run the container
* Clone https://github.com/BrettRD/ros-gst-bridge into /local/shared_with_docker (to make the files more easily accessiable outside the container)
* Follow the ros-gst-bridge readme instructions to build (skipping ROS install since already installed in the Docker)

## Other

The my_run_tappas_docker.sh was modified as follows:

* Added this to the run docker script in the prepare function:
   --cap-add=IPC_OWNER
*  Not sure if that is needed since that alone did not resolve the issue with DDS not working (until adding elsabot user).
*  Changed run script to specify --user elsabot
    docker exec -it --user elsabot -e DISPLAY=$DISPLAY "$CONTAINER_NAME" /bin/bash

ros-gst-bridge was forked and modified to include pixel-aspect-ratio cap.