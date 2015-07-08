# Download/Upload Docker Image

This creates a download/upload Docker image. It allows you to download/upload
data from GNOS, including the VCF upload process used for PanCancer.

## Developers

Make sure you update the release versions in the Dockerfile then build the Docker image using:

        docker build -t pancancer/pancancer_upload_download .

## Users

1. Get this image

        docker pull pancancer/pancancer_upload_download

2. See the [vcf-uploader](https://github.com/ICGC-TCGA-PanCancer/vcf-uploader) tool for information on how to use this to upload VCFs to GNOS.
