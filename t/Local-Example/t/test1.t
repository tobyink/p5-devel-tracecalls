use strict;
use warnings;
use Test::More tests => 2;

use Local::Example;

is(
	Local::Example::Module1::foo(),
	'Local::Example::Module1->foo',
);

is(
	Local::Example::Module1::bar(),
	'Local::Example::Module1->bar',
);
