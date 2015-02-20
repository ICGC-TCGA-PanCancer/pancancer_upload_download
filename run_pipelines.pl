use strict;

# This is a prototype for a tool that will consume an ini file from a queue
# and will trigger the docker workflow containers in order starting with
# data download, followed by EMBL and DKFZ, and then ending with upload.
# It currently doesn't really call these workflows but mocks up the
# calls for integration later.
# LEFT OFF WITH: I should be able to fill in the upload jobs below

# TODO
# ----
# * need names, versions, URLs for workflows below, see vcf upload jobs
# * need to set current time string
#

my $test = 0;
# FIXME: need actual dates
my $year = "2015";
my $month = "02";
my $day = "20";


my ($ini_file) = @ARGV;

# reads the "order" for the workflow
# TODO: this will need to interact with RabbitMQ or SQS from AWS
my $ini = get_order_info($ini_file);

# create needed directories
setup_dirs();

# download data
# FIXME: need these URLs
my $download_status = download_data($ini);

# download inputs
my $download_status = download_inputs($ini);

# makes an ini file for this workflow
my $embl_ini_file = generate_embl_ini_file($ini);

# executes this workflow
my $embl_status = run_embl_workflow($embl_ini_file);

# upload the results
my $embl_upload_status = upload_embl();

# makes an ini file for this workflow
my $dkfz_ini_file = generate_dkfz_ini_file($ini);

# executes this workflow
my $dkfz_status = run_dkfz_workflow($dkfz_ini_file);

# upload the results
my $dkfz_upload_status = upload_dkfz();

# cleanup
my $cleanup_status = cleanup();


# SUBROUTINES

# setup directories
sub setup_dirs {
  run("mkdir -p ".$ini->{workingDir}."/settings");
  run("mkdir -p ".$ini->{workingDir}."/results");
  run("mkdir -p ".$ini->{workingDir}."/working");
  run("mkdir -p ".$ini->{workingDir}."/downloads/dkfz");
  run("mkdir -p ".$ini->{workingDir}."/downloads/embl");
  run("mkdir -p ".$ini->{workingDir}."/inputs");
  run("mkdir -p ".$ini->{workingDir}."/uploads");
  run("echo '{}' > /tmp/empty.json");
}

# in the future this will get a message in JSON format from a queue
sub get_order_info {
  my $ini = shift;
  my $d = {};
  open INI, "<$ini" or die;
  while(<INI>) {
    chomp;
    if (/^\s*(\S+)\s*=\s*(.+)$/) {
      $d->{$1} = $2;
    }
  }
  close INI;
  return($d);
}

# this will download any data files needed by each Docker image
sub download_data {
  my ($ini) = @_;
  # FIXME: Joachim and Michael, need to get the URLs from you
  # DKFZ data bundle: https://gtrepo-dkfz.annailabs.com/cghub/data/analysis/download/41f20501-3f29-480d-863d-51c47efa112e
}

sub download_inputs {
  my ($ini) = @_;

  # IDs
  my @analysisIds = split /,/, $ini->{tumourAnalysisIds};
  my $controlAnalysisId = $ini->{controlAnalysisId};
  push @analysisIds, $controlAnalysisId;

  # BAMs
  my @bams = split /,/, $ini->{tumourBams};
  push @bams, $ini->{controlBam};

  # server and key
  my $server = $ini->{gnosServer};
  my $pem = $ini->{pemFile};

  # now download via Docker
  for (my $i=0; $i<scalar(@analysisIds); $i++) {
    my $currId = $analysisIds[$i];
    my $currBam = $bams[$i];
    #my $return = run("docker run -t -i -v /media/large_volume/workflow_data:/workflow_data -v  $pem:/root/gnos_icgc_keyfile.pem briandoconnor/pancancer-upload-download:1.0.0 /bin/bash -c 'cd /workflow_data/ && gtdownload -c /root/gnos_icgc_keyfile.pem -k 60 -vv $server/cghub/data/analysis/download/$currId'");
    my $return = run("docker run -t -i -v /media/large_volume/workflow_data/inputs:/workflow_data -v  $pem:/root/gnos_icgc_keyfile.pem briandoconnor/pancancer-upload-download:1.0.0 /bin/bash -c 'cd /workflow_data/ && perl -I /opt/gt-download-upload-wrapper/gt-download-upload-wrapper-1.0.3/lib /opt/vcf-uploader/vcf-uploader-1.0.0/gnos_download_file.pl --command \"gtdownload -c /root/gnos_icgc_keyfile.pem -k 60 -vv $server/cghub/data/analysis/download/$currId\" --file $currId/$currBam --retries 10 --sleep-min 1 --timeout-min 60'");
  }
}

sub generate_embl_ini_file {
  # FIXME: better version to come
  run("cp $ini_file ".$ini->{workingDir}."/settings/ebi.ini");
}

# TODO
sub run_embl_workflow {
  # IDs
  my @tumourAnalysisIds = split /,/, $ini->{tumourAnalysisIds};
  my $controlAnalysisId = $ini->{controlAnalysisId};

  # BAMs
  my @tumourBams = split /,/, $ini->{tumourBams};
  my $controlBam = $ini->{controlBam};

  # server and key
  my $server = $ini->{gnosServer};
  my $pem = $ini->{pemFile};

  run("echo docker run -t -i -v ".$ini->{workingDir}.":/workflow_data -v ".$ini->{workingDir}."/settings/ebi.ini:/workflow_data/workflow.ini -v ".$ini->{workingDir}."/results:/result_data <embl_name>/<embl_workflow>:<version> /bin/bash -c 'cd /workflow_data/ && run_embl_workflow.pl <...> '");

}

sub upload_embl {

  # metadata for inputs
  my $metadataUrls = $ini->{uploadServer}."/cghub/metadata/analysisFull/".$ini->{controlAnalysisId};
  foreach my $tumorAnalysisId (split /,/, $ini->{tumourAnalysisIds}) {
    $metadataUrls .= ",".$ini->{uploadServer}."/cghub/metadata/analysisFull/$tumorAnalysisId";
  }

  # the list of files to upload
  my @vcfs;
  my @tbis;
  my @tars;
  my @vcfmd5s;
  my @tbimd5s;
  my @tarmd5s;

  foreach my $type ("snv_mnv", "indel", "sv", "cnv") {
    foreach my $tumorAliquotId (split /,/, $ini->{tumourAliquotIds}) {
      my $baseFile = "/workflow_data/results/$tumorAliquotId.embl_1-0-0.$year$month$day.somatic.$type";
      push @vcfs, "$baseFile.vcf.gz";
      push @tbis, "$baseFile.vcf.gz.tbi";
      push @tars, "$baseFile.tar.gz";
      push @vcfmd5s, "$baseFile.vcf.gz.md5";
      push @tbimd5s, "$baseFile.vcf.gz.tbi.md5";
      push @tarmd5s, "$baseFile.tar.gz.md5";
    }
  }

  # FIXME: need a sample file list for the output
  # FIXME: need to fill in URLs below
  run("echo docker run -t -i -v /media/large_volume/workflow_data:/workflow_data -v $pem:/root/gnos_icgc_keyfile.pem -v <embl_output_per_donor>:/result_data briandoconnor/pancancer-upload-download:1.0.0 /bin/bash -c 'cd /workflow_data/results/ && perl -I /opt/gt-download-upload-wrapper/gt-download-upload-wrapper-1.0.3/lib
  /opt/vcf-uploader/vcf-uploader-1.0.0/gnos_upload_vcf.pl --metadata-urls $metadataUrls
  --vcfs ".join(",", @vcfs)."
  --vcf-md5sum-files ".join(",", @vcfmd5s)."
  --vcf-idxs ".join(",", @tbis)."
  --vcf-idx-md5sum-files ".join(",", @tbis)."
  --tarballs ".join(",", @tars)."
  --tarball-md5sum-files ".join(",", @tarmd5s)."
  --outdir ".$ini->{workingDir}."/uploads
  --key ".$ini->{uploadPemFile}."
  --upload-url ".$ini->{uploadServer}."
  --qc-metrics-json /tmp/empty.json
  --timing-metrics-json /tmp/empty.json
  --workflow-src-url http://github.com
  --workflow-url http://github.com
  --workflow-name EMBL
  --workflow-version 1.0.0
  --seqware-version ".$ini->{seqwareVersion}."
  --vm-instance-type ".$ini->{vmInstanceType}."
  --vm-instance-cores ".$ini->{vmInstanceCores}."
  --vm-instance-mem-gb ".$ini->{vmInstanceMemGb}."
  --vm-location-code ".$ini->{vmLocationCode}."
  --study-refname-override ".$ini->{study-refname-override}."
  --analysis-center-override ".$ini->{analysis-center-override}."
  '");
}


sub generate_dkfz_ini_file {
  # TODO: better version to come
  # The tumor bams and the delly files are stored in a bash array, i.e. arr=( a b c d )
  # Please note the syntax for that! You can query it with for i in ${arr[@]}; do ...
  my $ini = "#!/bin/bash
  tumorBams=( <full_path>/7723a85b59ebce340fe43fc1df504b35.bam )
  controlBam=8f957ddae66343269cb9b854c02eee2f.bam
  dellyFiles=( <per_tumor> )
  runACEeq=true
  runSNVCalling=true
  runIndelCalling=true
  date=$year$month$day";
  open OUT, ">".$ini->{workingDir}."/settings/dkfz.ini" or die;
  print OUT $ini;
  close OUT;
}

# FIXME: need to have Michael fill this in
sub run_dkfz_workflow {
  my $cmd = "docker run -t -i -v ".$ini->{workingDir}."/downloads/dkfz:/mnt/datastore/bundledFiles -v ".$ini->{workingDir}.":/mnt/datastore/workflow_data -v ".$ini->{workingDir}."/settings/dkfz.ini:/mnt/datastore/workflow_data/workflow.ini -v ".$ini->{workingDir}."/results:/mnt/datastore/result_data <user>/<dockername>:<dockerversion> /bin/bash -c '/root/bin/runwrapper.sh'";
}

sub upload_dkfz {
  run("echo docker run -t -i -v /media/large_volume/workflow_data:/workflow_data -v $pem:/root/gnos_icgc_keyfile.pem -v <dkfz_output_per_donor>:/result_data briandoconnor/pancancer-upload-download:1.0.0 /bin/bash -c 'cd /result_data/ && run_upload.pl ... '");
}

sub cleanup {
  # TODO
  run("echo rm -rf ".$ini->{workingDir});
}

sub run {
  my $cmd = shift;
  print ("CMD: $cmd\n");
  my $ret = 0;
  if (!$test) { $ret = (system($cmd)); die if ($ret); }
  return($ret);
}
