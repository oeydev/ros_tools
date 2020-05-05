#!/bin/bash
# Apache License 2.0
# Copyright (c) 2018, Anman Technology Co.,Ltd.

echo ""
echo "[Note] Target OS version  >>> Ubuntu 18.04 (bionic)"
echo "[Note] Target ROS version >>> ROS Melodic Morenia"
echo "[Note] Catkin workspace   >>> $HOME/catkin_ws"
echo ""
echo "PRESS [ENTER] TO CONTINUE THE INSTALLATION"
echo "IF YOU WANT TO CANCEL, PRESS [CTRL] + [C]"
read

echo "[Set the target OS, ROS version and name of catkin workspace]"
name_os_version=${name_os_version:="bionic"}
name_ros_version=${name_ros_version:="melodic"}
name_catkin_workspace=${name_catkin_workspace:="catkin_ws"}

#echo "[Update the package lists and upgrade them]"
#sudo apt-get update -y
#sudo apt-get upgrade -y

echo "[Install build environment, the chrony, ntpdate and set the ntpupdate]"
sudo apt-get install -y chrony ntpdate build-essential
sudo ntpdate ntp.ubuntu.com

echo "[Add the ROS repository]"
if [ ! -e /etc/apt/sources.list.d/ros-lastest.list ]; then
    sudo sh -c "echo \"deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main\" > /etc/apt/sources.list.d/ros-latest.list"
fi

echo "[Download the ROS keys]"
roskey=`apt-key list | grep "Open Robotics"`
if [ -z "$roskey" ]; then
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
fi

echo "[Check the ROS keys]"
roskey=`apt-key list | grep "Open Robotics"`
if [ -n "$roskey" ]; then
    echo "[ROS key exists in the list]"
else
    echo "[Failed to receive the ROS key, aborts the installation]"
    exit 0
fi

echo "[Update the package lists and upgrade them]"
sudo apt-get update -y
sudo apt-get upgrade -y

echo "[Install the ros-desktop-full, all rqt plugin and so on]"
sudo apt-get install -y ros-$name_ros_version-desktop-full ros-$name_ros_version-rqt-* 

echo "[Initialize rosdep]"
if [ ! -e /etc/ros/rosdep/sources.list.d/20-default.list ]; then
    sudo sh -c "rosdep init"
fi
rosdep update

echo "[Environment setup and getting rosinstall]"
source /opt/ros/$name_ros_version/setup.sh
sudo apt-get install -y python-rosinstall clang-format-6.0 vim python-flake8 git

echo "[Make the catkin workspace and test the catkin_make]"
mkdir -p $HOME/$name_catkin_workspace/src
cd $HOME/$name_catkin_workspace/src
cd $HOME/$name_catkin_workspace
catkin_make

echo "[Set the ROS evironment]"
sh -c "echo \"source /opt/ros/$name_ros_version/setup.bash\" >> ~/.bashrc"
sh -c "echo \"source ~/$name_catkin_workspace/devel/setup.bash\" >> ~/.bashrc"

sh -c "echo \"export ROS_MASTER_URI=http://localhost:11311\" >> ~/.bashrc"
sh -c "echo \"export ROS_HOSTNAME=localhost\" >> ~/.bashrc"

source $HOME/.bashrc
sudo apt install python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential -y

sudo apt install ros-melodic-navigation ros-melodic-cartographer-ros ros-melodic-teb-local-planner ros-melodic-twist-mux -y

cd $HOME
sudo rosdep init
rosdep update
echo "[Complete!!!]"
exit 0
