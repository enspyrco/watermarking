FROM nickmeinhold/ubuntu-opencv31contrib:latest

# Install gsutil with Python package index, as described in: 
# https://cloud.google.com/storage/docs/gsutil_install#linux 

# Several packages are required to successfully install gsutil from PyPI 
RUN apt-get -y install python-setuptools libffi-dev libssl-dev python-pip

RUN pip install gsutil

COPY WatermarkingPrintAndScan-320faf6a7881.p12 /keys/WatermarkingPrintAndScan-320faf6a7881.p12
