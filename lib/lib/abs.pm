#
# Copyright (c) 200[789] Mons Anderson <mons@cpan.org>. All rights reserved
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
package lib::abs;

=head1 NAME

lib::abs - The same as C<lib>, but makes relative path absolute.

=cut

$lib::abs::VERSION = '0.90';

=head1 VERSION

Version 0.90

=head1 SYNOPSIS

Simple use like C<use lib ...>:

	use lib::abs qw(./mylibs1 ../mylibs2);
	use lib::abs 'mylibs';

Extended syntax (glob)

	use lib::abs 'modules/*/lib';

There are also may be used helper function from lib::abs (see example/ex4):

	use lib::abs;
	# ...
	my $path = lib::abs::path('../path/relative/to/me'); # returns absolute path

=head1 DESCRIPTION

The main reason of this library is transformate relative paths to absolute at the C<BEGIN> stage, and push transformed to C<@INC>.
Relative path basis is not the current working directory, but the location of file, where the statement is (caller file).
When using common C<lib>, relative paths stays relative to curernt working directory, 

	# For ex:
	# script: /opt/scripts/my.pl
	use lib::abs '../lib';

	# We run `/opt/scripts/my.pl` having cwd /home/mons
	# The @INC will contain '/opt/lib';

	# We run `./my.pl` having cwd /opt
	# The @INC will contain '/opt/lib';

	# We run `../my.pl` having cwd /opt/lib
	# The @INC will contain '/opt/lib';

Also this module is useful when writing tests, when you want to load strictly the module from ../lib, respecting the test file.

	# t/00-test.t
	use lib::abs '../lib';

Also this is useful, when you running under C<mod_perl>, use something like C<Apache::StatINC>, and your application may change working directory.
So in case of chdir C<StatINC> fails to reload module if the @INC contain relative paths.

=head1 BUGS

None known

=head1 COPYRIGHT & LICENSE

Copyright 2007-2009 Mons Anderson.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 AUTHOR

Mons Anderson, <mons@cpan.org>

=cut

use strict;
use warnings;
use lib ();
use Cwd 3.12 qw(abs_path);
$lib::abs::sep = {
	( map { $_ => qr{[^\\/]+$}o } qw(mswin32 netware symbian dos) ),
	( map { $_ => qr{[^:]+:?$}o } qw(macos) ),
}->{lc$^O} || qr{[^/]+$}o;

BEGIN { *DEBUG = sub () { 0 } unless defined &DEBUG } # use constants is heavy

sub _carp  { require Carp; goto &Carp::carp  }
sub _croak { require Carp; goto &Carp::croak }
sub _debug ($@) { printf STDERR shift()." at @{[ (caller)[1,2] ]}\n",@_ }

sub mkapath($) {
	my $depth = shift;
	
	# Prepare absolute base bath
	my ($pkg,$file) = (caller($depth))[0,1];
	_debug "file = $file " if DEBUG > 1;
	$file =~ s/${lib::abs::sep}//s;
	$file = '.' unless length $file;
	_debug "base path = $file" if DEBUG > 1;
	my $f = abs_path($file) . '/';
	_debug "source dir = $f " if DEBUG > 1;
	$f;
}

sub path {
	local $_ = shift;
	s{^\./+}{};
	local $!;
	my $abs = mkapath(1) . $_;
	my $ret = abs_path( $abs ) or _carp("Bad path specification: `$_' => `$abs'" . ($! ? " ($!)" : ''));
	_debug "$_ => $ret" if DEBUG > 1;
	$ret;
}

sub transform {
	my $prefix;
	map {
		ref || m{^/} ? $_ : do {
			my $lib = $_;
			s{^\./+}{};
			local $!;
			my $abs = ( $prefix ||= mkapath(2) ) . $_;
			if (index($abs,'*') != -1 or index($abs,'?') !=-1) {
				_debug "transforming $abs using glob" if DEBUG > 1;
				map {
					abs_path( $_ )
						or _croak("Bad path specification: `$lib' => `$_'" . ($! ? " ($!)" : ''))
				} glob $abs;
			} else {
				$_ = abs_path( $abs ) or _croak("Bad path specification: `$lib' => `$abs'" . ($! ? " ($!)" : ''));
				_debug "$lib => $_" if DEBUG > 1;
				($_);
			}
		}
	} @_;
}

sub import {
	shift;
	return unless @_;
	@_ = ( lib => transform @_ = @_ );
	_debug "use @_\n" if DEBUG > 0;
	goto &lib::import;
	return;
}

sub unimport {
	shift;
	return unless @_;
	@_ = ( lib => transform @_ = @_ );
	_debug "no @_\n" if DEBUG > 0;
	goto &lib::unimport;
	return;
}

1;
