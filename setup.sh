#!/bin/bash

echo "Checking for ROS Indigo..."
if [ -d /opt/ros/indigo/ ]
then
    echo "ROS directory found."
else
    echo "Have you installed ROS already?"
    exit
fi

echo "Installing ROS packages..."
sudo apt-get install ros-indigo-moveit ros-indigo-fetch-gazebo-demo \
    ros-indigo-rosbridge-server

echo "Cloning and building jrosbridge..."
cd $ROSIE_PROJ
git clone git@github.com:emamanto/jrosbridge.git
if [ -d jrosbridge ]
then
    echo "Cloned repo."
else
    echo "Whoops! Couldn't clone the jrosbridge repo."
    exit
fi

cd jrosbridge
mvn install
if [ -d target ]
then
    echo "Built jrosbridge."
else
    echo "Build failed!"
    exit
fi

echo "\n#ROS" >> $ROSIE_PROJ/envvars
echo "export CLASSPATH=$CLASSPATH:$ROSIE_PROJ/jrosbridge/target/jrosbridge-0.2.1-SNAPSHOT-fat.jar" >> $ROSIE_PROJ/envvars


echo "Creating catkin workspace..."
cd $ROSIE_PROJ
mkdir -p catkin_ws/src
cd catkin_ws
catkin_make

if [ -e devel/setup.bash ]
then
    echo "Catkin workspace initialized. Make sure the catkin_ws/src directory is found below:"
    echo $ROS_PACKAGE_PATH
else
    echo "Couldn't set up catkin workspace!"
fi

echo "source $ROSIE_PROJ/catkin_ws/devel/setup.bash" >> $ROSIE_PROJ/envvars

cd $ROSIE_PROJ/catkin_ws/src
git clone git@github.com:emamanto/rosie_msgs.git
git clone git@github.com:emamanto/rosie_motion.git
cd ..
catkin_make
