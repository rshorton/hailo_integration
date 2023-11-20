From hailo_tappas:v3.26.0

ARG UNAME=elsabot
ARG UID=1000
ARG GID=1000

USER hailo

RUN sudo groupadd -g $GID -o $UNAME 
RUN sudo useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME
RUN sudo usermod -a -G sudo $UNAME

RUN \
    DEBIAN_FRONTEND=noninteractive && \
    sudo apt update && sudo apt install locales && \
    sudo locale-gen en_US en_US.UTF-8 &&\
    sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
    export LANG=en_US.UTF-8

RUN \
    DEBIAN_FRONTEND=noninteractive && \
    sudo apt install software-properties-common && \
    sudo add-apt-repository universe && \
    sudo apt update && \
    sudo apt install -y curl -y
    
RUN \    
    sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

RUN \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

RUN \    
    DEBIAN_FRONTEND=noninteractive && \
    sudo apt update && \
    sudo apt install -y ros-humble-ros-base && \
    sudo apt install -y ros-dev-tools

CMD /bin/bash
