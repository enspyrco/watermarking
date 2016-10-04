FROM asia.gcr.io/watermarking-print-and-scan/wm2


# mark-image C++ program 

# copy over the C++ for the marking software 
COPY main.cpp /main.cpp
COPY watermarking-functions /watermarking-functions

# compile the marking software 
RUN g++ main.cpp watermarking-functions/WatermarkDetection.cpp watermarking-functions/Utilities.cpp -I. -I/usr/include/ -I/usr/local/include -L/usr/local/lib -lopencv_core -lopencv_imgcodecs -lopencv_imgproc -o mark-image 



# listener.js 

# copy the listener node app 
COPY listener.js /listener.js

CMD ["nodejs", "listener.js"]
