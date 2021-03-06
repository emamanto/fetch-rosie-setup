#!/bin/bash

echo "Checking for ROS Indigo..."
if [ -d /opt/ros/indigo/ ]
then
    echo "ROS directory found."
    if [ $(which roslaunch) ]
    then
        echo "ROS setup seems to be working. Good to go!"
    else
        echo "Did you add ROS configuration to your .bashrc?"
        exit
    fi
else
    echo "Have you installed ROS already?"
    exit
fi

THIS_DIR=$(pwd)
if [ -e kinematics.yaml ]
then
    echo "Found kinematics config file."
else
    echo "Please run this script from the fetch-rosie-setup directory."
    exit
fi


echo "Installing ROS packages and maven..."
sudo apt-get install ros-indigo-moveit ros-indigo-fetch-gazebo-demo \
    ros-indigo-rosbridge-server ros-indigo-trac-ik \
    ros-indigo-trac-ik-kinematics-plugin maven

echo "Cloning and building jrosbridge..."
cd $ROSIE_PROJ
git clone https://github.com/emamanto/jrosbridge.git
if [ -d jrosbridge ]
then
    echo "Cloned repo."
else
    echo "Whoops! Couldn't clone the jrosbridge repo."
    exit
fi

cd jrosbridge
mvn clean package
if [ -d target ]
then
    echo "Built jrosbridge."
else
    echo "Build failed!"
    exit
fi

echo "#ROS" >> $ROSIE_PROJ/envvars
echo "export CLASSPATH=$CLASSPATH:$ROSIE_PROJ/jrosbridge/target/jrosbridge-0.2.1-SNAPSHOT-fat.jar" >> $ROSIE_PROJ/envvars


echo "Creating catkin workspace..."
mkdir -p ~/catkin_ws/src
cd ~/catkin_ws/src
git clone https://github.com/emamanto/rosie_msgs.git
git clone https://github.com/emamanto/rosie_motion.git
cd ..
catkin_make

if [ -e devel/setup.bash ]
then
    source devel/setup.bash
    echo "Catkin workspace initialized. Make sure the catkin_ws/src directory is in the list below:"
    echo $ROS_PACKAGE_PATH
else
    echo "Couldn't set up catkin workspace!"
    exit
fi
echo "source ~/catkin_ws/devel/setup.bash" >> ~/.bashrc

echo "Changing IK solver to TRAC_IK..."
roscd fetch_moveit_config
cd config
sudo cp kinematics.yaml kinematics.yaml.bkup
sudo cp $THIS_DIR/kinematics.yaml kinematics.yaml

echo "Open a new terminal and run roslaunch rosie_motion rosie_motion.launch to see if things are working!"
