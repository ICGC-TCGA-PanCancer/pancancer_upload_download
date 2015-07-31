# 1.4.0

* removed the `USER seqware` line in the Dockerfile so callers can specify the user they want. This may have unintended consequences for our workflows so caution is needed if you update a core PCAWG workflow to use this container release
* I added samtools and tabix to the apt-get install
* I updated to:
    * vcf-uploader version 2.0.6
    * gt-download-upload-wrapper 2.0.12
