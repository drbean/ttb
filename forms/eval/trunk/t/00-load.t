#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Evalform' );
}

diag( "Testing Evalform $Evalform::VERSION, Perl $], $^X" );
