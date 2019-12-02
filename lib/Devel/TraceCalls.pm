use strict;
use warnings;

package Devel::TraceCalls;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.001';

use constant ACTIVE => $ENV{'PERL_TRACE_CALLS'};

BEGIN {
	eval q{
		use match::simple ();
		use Carp ();
		use File::Spec ();
		use FindBin ();
		use Hook::AfterRuntime ();
		use JSON::PP ();
		use Sub::Util ();
		1;
	} || die($@) if ACTIVE;
};

our $JSON;
our %CALL;
$JSON = 'JSON::PP'->new->pretty(1)->canonical(1) if ACTIVE;

sub import {
	my $me = shift;
	my $caller = caller;
	my (%opts) = @_;	
	&Hook::AfterRuntime::after_runtime(
		sub { $me->setup_for($caller, %opts) },
	) if ACTIVE;
}

sub setup_for {
	my $me = shift;
	my ($caller, %opts) = @_;
	$opts{match} = sub {
		local $_ = shift;
		!/^_/ and /\p{Ll}/;
	} unless exists $opts{match};
	no strict 'refs';
	my @names =
		grep  match::simple::match($_, $opts{match}),
		grep !/::$/,
		sort keys %{"$caller\::"};
	$me->wrap_sub($caller, $_) for @names;
}

sub wrap_sub {
	my $me = shift;
	no strict 'refs';
	no warnings 'redefine';
	my ($package, $sub) = @_;
	($package, $sub) = (/^(.+)::([^:]+)$/ =~ $package)
		if !defined $sub;
	my $code    = \&{"$package\::$sub"};
	my $newcode =
		Sub::Util::set_prototype prototype($code),
		Sub::Util::set_subname Sub::Util::subname($code),
		sub { ++$CALL{$package}{$sub}; goto $code };
	*{"$package\::$sub"} = $newcode;
}

END {
	if (ACTIVE) {
		my $map = $JSON->encode(\%CALL);
		
		my $outfile = 'File::Spec'->catfile(
			$FindBin::RealBin,
			$FindBin::RealScript . ".map",
		);
		my $already = 0;
		
		if (-f $outfile) {
			my $slurped = do {
				local $/; my $fh;
				open($fh, '<', $outfile) ? <$fh> : undef;
			};
			$already++ if $slurped eq $map;
		}
		
		if (!$already) {
			open my $outfh, '>', $outfile
				or Carp::croak("Cannot open $outfile for output: $!");
			print {$outfh} $map
				or Carp::croak("Cannot write to $outfile: $!");
			close $outfh
				or Carp::croak("Cannot close $outfile: $!");
		}
	};
}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Devel::TraceCalls - which subs were called by which test scripts?

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=Devel-TraceCalls>.

=head1 SEE ALSO

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2019 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.


=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

