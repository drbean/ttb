#!/usr/bin/perl

=head1 NAME

loadYAMLid.pl -- Load one text with questions from a YAML file

=head1 SYNOPSIS

loadYAMLid.pl data/business.yaml careercandidate

=head1 DESCRIPTION

Cut and paste from YAML into questions tables. The YAML file is organized into topics, each of which has stories, with each of the latter having quizzes.

The difference with loadYAML.pl is this only loads questions for one story from one topic.

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
TOPIC: for my $t ( keys %$sequence ) {
	next unless $t = $ARGV[1];
	my $topic = $sequence->{$t};
	for my $s ( keys %$topic ) {
		next unless $s = $ARGV[2];
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
		last TOPIC;
	}
}
my $q = $d->resultset('Questions');
$q->populate(\@questions);
