FROM watermarking2:latest

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

CMD ["node", "listener.js"]
