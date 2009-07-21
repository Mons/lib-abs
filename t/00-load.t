#!/usr/bin/env perl -w

use strict;
use Test::More tests => 3;
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
