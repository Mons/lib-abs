#!/usr/bin/env perl -w

our $tests;
use strict;
use Test::More;
BEGIN { my $tests = 3; eval q{ use Test::NoWarnings;1 } and $tests++; plan tests => $tests };
use FindBin;
use Cwd;
use lib "$FindBin::Bin/../lib"; # there is no lib::abs yet ;)

BEGIN {
	use_ok( 'lib::abs','.' );
	{
		local $@;
		eval q{ use lib::abs; };
		ok(!$@, 'lib::abs empty usage allowed');
	}
	{
		local $@;
		eval q{ use lib::abs '../linux/macosx/windows/dos/path-that-never-exists'; }; # ;)
		ok($@, 'lib::abs wrong path failed');
	}
}

diag( "Testing lib::abs $lib::abs::VERSION using Cwd $Cwd::VERSION, Perl $], $^X" );
