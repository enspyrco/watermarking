FROM watermarking2:latest

# install boost 
RUN apt-get install -y libboost-all-dev

# copy over the C++ for the marking software 
COPY main.cpp /main.cpp
COPY watermarking-functions /watermarking-functions



# install nodejs and npm
RUN apt-get install -y nodejs npm 

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

#CMD ["node", "listener.js"]
