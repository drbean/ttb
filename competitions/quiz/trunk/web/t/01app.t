use strict;
use warnings;
use Test::More tests => 2;

BEGIN { use_ok 'Catalyst::Test', 'CompComp' }

ok( request('/')->is_success, 'Request should succeed' );
