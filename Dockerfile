FROM ubuntu:12.04
MAINTAINER Brian O'Connor <boconnor@oicr.on.ca>
RUN apt-get update && apt-get install -y wget
RUN cd /opt && wget -t 5 --timeout=5 --no-check-certificate https://cghub.ucsc.edu/software/downloads/GeneTorrent/3.8.6/genetorrent-download_3.8.6-ubuntu2.130-12.04_amd64.deb
RUN cd /opt && wget -t 5 --timeout=5 --no-check-certificate https://cghub.ucsc.edu/software/downloads/GeneTorrent/3.8.6/genetorrent-common_3.8.6-ubuntu2.130-12.04_amd64.deb
RUN cd /opt && wget -t 5 --timeout=5 --no-check-certificate https://cghub.ucsc.edu/software/downloads/GeneTorrent/3.8.6/genetorrent-upload_3.8.6-ubuntu2.130-12.04_amd64.deb
RUN apt-get update && apt-get install -y libcurl3 libxqilla6 python
RUN apt-get update && apt-get install -y libboost-program-options1.48.0 libboost-system1.48.0  libboost-filesystem1.48.0 libboost-regex1.48.0
RUN cd /opt && dpkg --install genetorrent-download_3.8.6-ubuntu2.130-12.04_amd64.deb genetorrent-common_3.8.6-ubuntu2.130-12.04_amd64.deb genetorrent-upload_3.8.6-ubuntu2.130-12.04_amd64.deb
RUN mkdir -p /opt/gt-download-upload-wrapper && cd /opt/gt-download-upload-wrapper && wget --no-check-certificate https://github.com/ICGC-TCGA-PanCancer/gt-download-upload-wrapper/archive/2.0.7.tar.gz && tar zxf 2.0.7.tar.gz
RUN mkdir -p /opt/vcf-uploader && cd /opt/vcf-uploader && wget --no-check-certificate https://github.com/ICGC-TCGA-PanCancer/vcf-uploader/archive/2.0.2.tar.gz && tar zxf 2.0.2.tar.gz
RUN apt-get update && apt-get install -y python-dev python-pip libxml-dom-perl libxml-xpath-perl libjson-perl libxml-libxml-perl time libdata-uuid-libuuid-perl libcarp-always-perl libipc-system-simple-perl libdata-uuid-perl curl vim
RUN pip install synapseclient python-dateutil elasticsearch xmltodict pysftp paramiko
# temp workaround until we have new artifact
RUN cd /opt/vcf-uploader/vcf-uploader-2.0.2 && \
  rm gnos_upload_vcf.pl && \
  wget https://raw.githubusercontent.com/ICGC-TCGA-PanCancer/vcf-uploader/develop/gnos_upload_vcf.pl
RUN cd /opt/gt-download-upload-wrapper/gt-download-upload-wrapper-2.0.7/lib/GNOS/ && \
  rm Download.pm Upload.pm && \
  wget https://raw.githubusercontent.com/ICGC-TCGA-PanCancer/gt-download-upload-wrapper/develop/lib/GNOS/Download.pm && \
  wget https://raw.githubusercontent.com/ICGC-TCGA-PanCancer/gt-download-upload-wrapper/develop/lib/GNOS/Upload.pm
