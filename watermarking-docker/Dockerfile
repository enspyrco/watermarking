FROM ubuntu:latest

RUN apt-get update

# from http://docs.opencv.org/trunk/d7/d9f/tutorial_linux_install.html 
# compiler 
RUN apt-get install -y build-essential
# required
RUN apt-get install -y cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev
# optional
#RUN apt-get install -y python-dev python-numpy libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libjasper-dev libdc1394-22-dev

RUN apt-get install -y wget
RUN apt-get install -y unzip
WORKDIR /tmp
RUN wget https://github.com/Itseez/opencv/archive/3.1.0.zip
RUN unzip 3.1.0.zip

RUN wget https://github.com/opencv/opencv_contrib/archive/master.zip
RUN unzip master.zip

WORKDIR /tmp/opencv-3.1.0
RUN mkdir /tmp/opencv-3.1.0/build

WORKDIR /tmp/opencv-3.1.0/build

RUN cmake -D CMAKE_BUILD_TYPE=Release -D BUILD_opencv_aruco=OFF -D OPENCV_EXTRA_MODULES_PATH=/tmp/opencv_contrib-master/modules -D CMAKE_INSTALL_PREFIX=/usr/local ..
RUN make 
RUN make install

WORKDIR /
RUN rm -rf /tmp/*

# note: OpenCV is built without the aruco module as it was causing compile errors, seems like a recent change is the problem, see discussion below 
# http://answers.opencv.org/question/101157/opencv-310-compile-with-contrib-error-when-compile-aruco/
