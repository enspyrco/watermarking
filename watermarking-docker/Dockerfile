FROM asia.gcr.io/watermarking-print-and-scan/wm2


# marking and detection C++ programs 

# copy over the C++ for the marking and detecting software 
COPY mark.cpp /mark.cpp
COPY detect.cpp /detect.cpp
COPY watermarking-functions /watermarking-functions

# compile the marking software 
RUN g++ mark.cpp -std=c++11 watermarking-functions/WatermarkDetection.cpp watermarking-functions/Utilities.cpp -I. -I/usr/include/ -I/usr/local/include -L/usr/local/lib -lopencv_core -lopencv_imgcodecs -lopencv_imgproc -o mark-image

# compile the detection software 
RUN g++ detect.cpp -std=c++11 watermarking-functions/WatermarkDetection.cpp watermarking-functions/Utilities.cpp -I. -I/usr/include/ -I/usr/local/include -L/usr/local/lib -lopencv_core -lopencv_imgcodecs -lopencv_imgproc -o detect-wm


# listener.js 

# copy the listener node app 
COPY listener.js /listener.js
COPY tools.js /tools.js
COPY marking-queues.js /marking-queues.js
COPY detection-queues.js /detection-queues.js
COPY firebase-admin-singleton.js /firebase-admin-singleton.js 

CMD ["nodejs", "listener.js"]
