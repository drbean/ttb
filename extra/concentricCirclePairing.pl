#!/usr/bin/perl 

use warnings;
use strict;
use integer;

sub allocate_schedule
{
	my $N = shift;
	my $n = ($N+1)/2;
	my @inner = ();
	my @outer = ();
	$outer[$_] = $_ foreach 0 .. $n-1;
	$inner[$_] = $n+$_ foreach 0 .. $n-1;
	# $outer[$n-1] = 'bye' if $N % 2;
	my $arrangement;
	for my $twostep ( 0 .. $n ) 
	{
		my $shufflein;
		for my $position ( 0 .. $n-1 ) 
		{
			$$shufflein[$inner[$position]] = $outer[$position];
			$$shufflein[$outer[$position]] = $inner[$position];
		}
		push @$arrangement, $shufflein;
		my $shuffler = $outer[$n-1];
		$outer[$n-1] = $inner[$n-1];
		$inner[$n-1] = $shuffler;
		unshift @inner, pop @inner;

		my $shuffleout;
		for my $position ( 0 .. $n-1 ) 
		{
			$$shuffleout[$inner[$position]] = $outer[$position];
			$$shuffleout[$outer[$position]] = $inner[$position];
		}
		push @$arrangement, $shuffleout;
		$shuffler = $inner[0];
		$inner[0] = $outer[0];
		$outer[0] = $shuffler;
		push @outer, shift @outer;

	}
	return $arrangement;
}

print allocate_schedule(8);
