use 5.006;
use inc::Module::Install;

name     'lib-abs';
all_from 'lib/lib/abs.pm';
version  my $v = '0.91';
author   'Mons Anderson <mons@cpan.org>';
license  'perl';

build_requires 'Test::More';

requires Cwd => '3.12'; # FreeBDS: devel/p5-PathTools

provides 'lib::abs' => {
	version => $v,
	file    => 'lib/lib/abs.pm',
};

auto_install;

WriteAll;
