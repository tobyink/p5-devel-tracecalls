use strict;
use warnings;
use Test::More tests => 2;

use File::Spec;
use FindBin qw($Bin);
use lib File::Spec->catdir($Bin, '..', 'lib');
use lib File::Spec->catdir($Bin, '..', '..', '..', 'lib');

use Local::Example;

is(
	Local::Example::Module1::foo(),
	'Local::Example::Module1->foo',
);

is(
	Local::Example::Module1::bar(),
	'Local::Example::Module1->bar',
);
