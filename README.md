# Download/Upload Docker Image

This creates a download/upload Docker image. It allows you to download/upload
data from GNOS, including the VCF upload process used for PanCancer.

## Developers

Make sure you update the release versions in the Dockerfile then build the Docker image using:

        docker build -t pancancer/pancancer_upload_download .

## Users

1. Get this image

        docker pull pancancer/pancancer_upload_download

2. You can launch this Docker container either interactively or just run the vcf uploader non-interactively.  The former:

        docker run -it pancancer/pancancer_upload_download /bin/bash

You can then look in `/opt/vcf-uploader/vcf-uploader-2.0.5` where the vcf uploader is installed.

Also, you will probably want to mount the pem key you use into the container, see how to use the `-v` parameter in Docker to do this.

3. See the [vcf-uploader](https://github.com/ICGC-TCGA-PanCancer/vcf-uploader) tool for information on how to use this to upload VCFs to GNOS.  There's an example on how to call the uploader tool.
