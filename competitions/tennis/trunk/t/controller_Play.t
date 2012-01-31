use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Tennis';
use Tennis::Controller::Play;

ok( request('/play')->is_success, 'Request should succeed' );
done_testing();
