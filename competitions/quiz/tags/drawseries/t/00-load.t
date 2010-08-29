#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Comp' );
}

diag( "Testing Comp $Comp::VERSION, Perl $], $^X" );
