#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Seats' );
}

diag( "Testing Seats $Seats::VERSION, Perl $], $^X" );
