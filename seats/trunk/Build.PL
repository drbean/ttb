use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Seats',
    license             => 'perl',
    dist_author         => 'Dr Bean <drbean at ie(@) cpan dot ie (.) org>',
    dist_version_from   => 'lib/Seats.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Seats-*' ],
    create_makefile_pl => 'traditional',
    script_files	=>  [qw[
    				script_files/expertseat.pl
				script_files/teamseat.pl]],
);

$builder->create_build_script();
