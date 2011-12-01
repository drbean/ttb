#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'CompComp' );
}

diag( "Testing CompComp $CompComp::VERSION, Perl $], $^X" );
