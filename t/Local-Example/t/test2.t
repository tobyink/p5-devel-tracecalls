use strict;
use warnings;
use Test::More tests => 3;

use Local::Example;

is(
	Local::Example::Module2::foo(),
	'Local::Example::Module2->foo',
);

is(
	Local::Example::Module2::bar(),
	'Local::Example::Module1->bar',
);

is(
	Local::Example::quux(),
	'Local::Example->quux',
);
