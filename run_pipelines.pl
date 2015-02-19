use strict;

# this tool will consume an ini file and will trigger the docker images in order

my ($ini) = @ARGV;

my $d = {};

open INI, "<$ini" or die;
while(<INI>) {
  chomp;
  if (//) {
    
  }
}

