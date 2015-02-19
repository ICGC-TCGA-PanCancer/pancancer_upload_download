FROM ubuntu:12.04
MAINTAINER Brian O'Connor <boconnor@oicr.on.ca>
RUN apt-get update
RUN apt-get install -y wget
RUN cd /opt && wget -t 5 --timeout=5 --no-check-certificate https://cghub.ucsc.edu/software/downloads/GeneTorrent/3.8.6/genetorrent-download_3.8.6-ubuntu2.130-12.04_amd64.deb
RUN cd /opt && wget -t 5 --timeout=5 --no-check-certificate https://cghub.ucsc.edu/software/downloads/GeneTorrent/3.8.6/genetorrent-common_3.8.6-ubuntu2.130-12.04_amd64.deb
RUN cd /opt && wget -t 5 --timeout=5 --no-check-certificate https://cghub.ucsc.edu/software/downloads/GeneTorrent/3.8.6/genetorrent-upload_3.8.6-ubuntu2.130-12.04_amd64.deb
RUN apt-get install -y libcurl3 libxqilla6 python
RUN apt-get install -y libboost-program-options1.48.0 libboost-system1.48.0  libboost-filesystem1.48.0 libboost-regex1.48.0
RUN cd /opt && dpkg --install genetorrent-download_3.8.6-ubuntu2.130-12.04_amd64.deb genetorrent-common_3.8.6-ubuntu2.130-12.04_amd64.deb genetorrent-upload_3.8.6-ubuntu2.130-12.04_amd64.deb
RUN mkdir -p /opt/gt-download-upload-wrapper && cd /opt/gt-download-upload-wrapper && wget --no-check-certificate https://github.com/ICGC-TCGA-PanCancer/gt-download-upload-wrapper/archive/1.0.3.tar.gz && tar zxf 1.0.3.tar.gz
RUN mkdir -p /opt/vcf-uploader && cd /opt/vcf-uploader && wget --no-check-certificate https://github.com/ICGC-TCGA-PanCancer/vcf-uploader/archive/1.0.0.tar.gz && tar zxf 1.0.0.tar.gz

