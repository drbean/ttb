#!/usr/bin/perl

use strict;
use warnings;
use IO::All;
use YAML::XS qw/LoadFile DumpFile Dump/;
use Cwd;

$_REPL->load_plugin('DumpHistory');

my $semester="$ENV{SEMESTER}";
my $school='must';
my $league='251';

use Grades;
use Grades::Groupwork;
my $l = League->new( leagues => "/home/drbean/$semester", id => $league );
my $g = Grades->new({ league => $l });
my $co = Compcomp->new({ league => $l });
my $cl = $g->classwork;
my %m = map { $_->{id} => $_ } @{ $l->members };
#my %m = ( drbean =>
#	{ Chinese => "drbean",
#	id => "drbean",
#	name => "DrBean",
#	password => "bean",
#	}
#);
my $approach = $l->approach;

my $cohort_name = $league;
my $header = join "\t", ( qw/username lastname firstname email password cohort1/ );
my @cohort = ( $header );
for my $id ( sort keys %m ) {
	my $lower_id = lcfirst $id;
	my $username = $lower_id;
	my $lastname = $id;
	my $firstname =$m{$id}->{name};
	my $email = $m{$id}->{email};
	my $password = $m{$id}->{password};
	my $city = "Hsinchu";
	system("Moosh user-create --password $password --email $email --city $city --country TW --firstname $firstname --lastname $id $username");
}


