use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Comp',
    license             => 'perl',
    dist_author         => 'Dr Bean <<drbean at, ie, (a) cpan dot, ie . org>>',
	dist_abstract	=> "Paired Comprehension Competitions",
    dist_version   => '0.02',
    build_requires => {
        'Test::More' => 0,
    },
	script_files => [ qw[ paper/script_files/comptron.pl
							paper/script_files/score_comp.pl ] ],
    add_to_cleanup      => [ 'Comp-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
