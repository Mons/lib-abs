#!/usr/bin/perl -w

use strict;
use Test::More;
use FindBin;
use lib "$FindBin::Bin/../lib";

# Ensure a recent version of Test::Pod
eval "use Test::Pod 1.22; 1"
	or plan skip_all => "Test::Pod 1.22 required for testing POD";
eval "use File::Find; 1"
	or plan skip_all => "File::Find required for testing POD";

my @files;
File::Find::find( sub {
	my $x = $File::Find::name; # only once warning
	push @files, $File::Find::name if /\.pm$/;
}, $INC[0] );

plan tests => 0+@files;

pod_file_ok($_) for @files;
