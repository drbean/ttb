use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    license             => 'perl',
    dist_author         => 'Dr Bean <drbean@cpan.org>',
    dist_version   => 0.01,
    dist_name => 'Evalform',
    script_files => 'script_files/evalform',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Evalform-*' ],
);

$builder->create_build_script();
