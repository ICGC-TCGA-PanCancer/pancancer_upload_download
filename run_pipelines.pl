use strict;

# This is a prototype for a tool that will consume an ini file from a queue
# and will trigger the docker workflow containers in order starting with
# data download, followed by EMBL and DKFZ, and then ending with upload.
# It currently doesn't really call these workflows but mocks up the
# calls for integration later.

my $test = 1;

my ($ini_file) = @ARGV;

# reads the "order" for the workflow
my $ini = get_order_info($ini_file);

# creates a working directory
run("mkdir -p /media/large_volume/workflow_data");

# download data
my $download_status = download_data($ini);

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

sub download_data {
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
  #my $return = run("docker run -t -i -v /media/large_volume/workflow_data:/workflow_data -v  $pem:/root/gnos_icgc_keyfile.pem briandoconnor/pancancer-upload-download:1.0.0 'cd /workflow_data/ && perl -I /opt/gt-download-upload-wrapper/gt-download-upload-wrapper-1.0.3/lib /opt/vcf-uploader/vcf-uploader-1.0.0/gnos_download_file.pl --command 'gtdownload -c /root/20150212_boconnor_gnos_icgc_keyfile.pem -k 60 https://gtrepo-ebi.annailabs.com/cghub/data/analysis/download/96e252b8-911a-44c7-abc6-b924845e0be6' --file 96e252b8-911a-44c7-abc6b924845e0be6/7d743b10ea1231730151b2c9d91c527f.bam --retries 10 --sleep-min 1 --timeout-min 60'");

  for (my $i=0; $i<scalar(@analysisIds); $i++) {
    my $currId = $analysisIds[$i];
    my $currBam = $bams[$i];
    my $return = run("docker run -t -i -v /media/large_volume/workflow_data:/workflow_data -v  $pem:/root/gnos_icgc_keyfile.pem briandoconnor/pancancer-upload-download:1.0.0 'cd /workflow_data/ && gtdownload -c /root/gnos_icgc_keyfile.pem -k 60 -vv $server/cghub/data/analysis/download/$currId'");
  }
}

sub generate_embl_ini_file {

}

sub run_embl_workflow {

}

sub upload_embl {

}

sub generate_dkfz_ini_file {

}

sub run_dkfz_workflow {

}

sub upload_dkfz {

}

sub cleanup {

}

sub run {
  my $cmd = shift;
  print ("CMD: $cmd\n");
  if (!$test) { return(system($cmd)); }
}