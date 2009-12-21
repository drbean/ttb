#!/usr/bin/perl

=head1 NAME

loadYAMLid.pl -- Load one text with questions from a YAML file

=head1 SYNOPSIS

loadYAMLid.pl data/business.yaml careercandidate

=head1 DESCRIPTION

Cut and paste from YAML into texts, questions tables 

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
my ($text, $question) = LoadFile $ARGV[0];
my @text;
push @text, shift @$text;
$_->[2] = 'intermediate' for @$text;
push @text, grep { $_->[0] eq $ARGV[1] } @$text;
my @qn;
push @qn, shift @$question;
$_->[0] = 'intermediate' for @$question;
push @qn, grep { $_->[1] eq $ARGV[1] } @$question;
my $t = $d->resultset('Text');
$t->populate(\@text);
my $q = $d->resultset('Question');
$q->populate(\@qn);
