FROM watermarking2:latest

# install boost 
RUN apt-get install -y libboost-all-dev

# install nodejs and npm
RUN apt-get install -y nodejs npm 


# copy the key for gsutil 
COPY WatermarkingPrintAndScan-320faf6a7881.p12 /keys/WatermarkingPrintAndScan-320faf6a7881.p12

# copy over the C++ for the marking software 
COPY main.cpp /main.cpp
COPY watermarking-functions /watermarking-functions

# compile the marking software 
RUN g++ main.cpp watermarking-functions/WatermarkDetection.cpp watermarking-functions/Utilities.cpp -I. -I/usr/include/ -I/usr/local/include -L/usr/local/lib -lopencv_core -lopencv_imgcodecs -lopencv_imgproc -o mark-image 

# copy the json key 
COPY WatermarkingPrintAndScan-8705059a4ba1.json /keys/WatermarkingPrintAndScan-8705059a4ba1.json

# get the firebase server sdk installed 
COPY package.json /package.json
RUN npm install

# copy the listener node app 
COPY listener.js /listener.js

# copy the shell script and make executable 
COPY mark.sh /mark.sh
RUN chmod +x /mark.sh

CMD ["nodejs", "listener.js"]
