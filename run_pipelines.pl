use strict;

# This is a prototype for a tool that will consume an ini file from a queue
# and will trigger the docker workflow containers in order starting with
# data download, followed by EMBL and DKFZ, and then ending with upload.
# It currently doesn't really call these workflows but mocks up the
# calls for integration later.

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

# SUBROUTINES

sub get_order_info {
  open INI, "<$ini" or die;
  while(<INI>) {
    chomp;
    if (//) {

    }
  }
}

sub run {
  my $cmd = shift;
  print ("CMD: $cmd\n");
  return(system($cmd));
}
