use strict;
use warnings;
use Test::More tests => 3;

use File::Spec;
use FindBin qw($Bin);
use lib File::Spec->catdir($Bin, '..', 'lib');
use lib File::Spec->catdir($Bin, '..', '..', '..', 'lib');

use Local::Example;

is(
	Local::Example::Module2::foo(),
	'Local::Example::Module2->foo',
);

is(
	Local::Example::Module2::bar(),
	'Local::Example::Module1->bar',
);

Local::Example::quux();

is(
	Local::Example::quux(),
	'Local::Example->quux',
);
