#!/usr/bin/perl

=head1 NAME

loadYAML.pl -- Load questions for a curriculum sequence from a YAML file

=head1 SYNOPSIS

loadYAMLid.pl business/negotiations/cards.yaml

=head1 DESCRIPTION

Cut and paste from YAML into questions tables. The YAML file is organized into topics, each of which has stories, with each of the latter having quizzes.

But be careful with targets

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 COPYRIGHT


This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

use strict;
use warnings;
use lib 'lib';

use Config::General;

my @MyAppConf = glob( '*.conf' );
die "Which of @MyAppConf is the configuration file?"
			unless @MyAppConf == 1;
my %config = Config::General->new($MyAppConf[0])->getall;
my $name = $config{name};
require $name . ".pm";
my $model = "${name}::Schema";
my $modelfile = "$name/Model/DB.pm";
my $modelmodule = "${name}::Model::DB";
# require $modelfile;

my $connect_info = $modelmodule->config->{connect_info};
my $d = $model->connect( @$connect_info );

use YAML qw/LoadFile DumpFile/;
use IO::All;
my $sequence = LoadFile $ARGV[0];
my @questions;
for my $t ( keys %$sequence ) {
	my $topic = $sequence->{$t};
	for my $s ( keys %$topic ) {
		my $story = $topic->{$s};
		my $quiz = $story->{quiz};
		my $n = 1;
		for my $qa ( @$quiz ) {
			push @questions, {
				genre => 'business',
				topic => $t,
				story => $s,
				id => $n++,
				target => 'all',
				content => $qa->{question},
				answer => $qa->{answer},
			};
		}
	}
}
my $q = $d->resultset('Questions');
$q->populate(\@questions);
