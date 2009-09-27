use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Comp',
    license             => 'perl',
    dist_author         => 'Dr Bean <<drbean at, ie, (a) cpan dot, ie . org>>',
    dist_version_from   => 'lib/Comp.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Comp-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
