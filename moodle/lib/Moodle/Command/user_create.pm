package Moodle::Command::user_create;

use lib "lib";

use Moodle -command;
use strict;
use warnings;
use YAML qw/Dump LoadFile DumpFile/;
use IO::All;

sub abstract { "Leverage Moosh's php scripts to do higher-level moodle work in perl" }
sub description { "Leverage Moosh's php scripts to do higher-level moodle work in perl" }

sub usage_desc { "moodle user_create -s nuu -l FLA0003" }

sub opt_spec  {
        return (
                ["c=s", "school"]
                , ["l=s", "league"]
	);
}


sub execute {
	my ($self, $opt, $args) = @_;

	my ($school, $league) = @$opt{qw/c l/};
	my $semester="$ENV{SEMESTER}";
	my $city;
	if ( $l->yaml->{school} eq "must" ) {
		$city = "Hsinchu";
	}
	else { $city = "Miaoli";}

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

	chdir '/var/www/cgi-bin/moodle';

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
		system("Moosh user-create --password $password --email $email --city $city --country TW --firstname $firstname --lastname $id $username");
	}


}

1;
