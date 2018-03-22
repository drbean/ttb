package Moodle::Command::user_mod;

use lib "lib";

use Moodle -command;
use strict;
use warnings;
use YAML qw/Dump LoadFile DumpFile/;
use IO::All;

sub abstract { "moopl user-mod -l FLA0003" }
sub description { "Leverage Moosh's php scripts to do higher-level moodle work in perl" }

sub usage_desc { "moodle user_mod -s nuu -l FLA0003" }

sub opt_spec  {
        return (
                ["l=s", "league"]
	);
}


sub execute {
	my ($self, $opt, $args) = @_;

	my ($league) = @$opt{qw/l/};
	my $semester="$ENV{SEMESTER}";

	chdir '/var/www/cgi-bin/moodle';

	my $course_id = qx/Moosh -n course-list -i "shortname='$league'"/;

	use Grades;
	my $l = League->new( leagues => "/home/drbean/$semester", id => $league );
	my %m = map { $_->{id} => $_ } @{ $l->members };
	#my %m = ( drbean =>
	#	{ Chinese => "drbean",
	#	id => "drbean",
	#	name => "DrBean",
	#	password => "bean",
	#	}
	#);
	my $city;
	if ( $l->yaml->{school} eq "must" ) {
		$city = "Hsinchu";
	}
	else { $city = "Miaoli";}

	my $user_list = qx/Moosh -n user-list --course $course_id/;
	my @user_list = split /\n/, $user_list;
	my @users;
	for my $user ( @user_list ) {
		$user =~ m/^([a-z]\d*) \((\d*)\)/;
		next unless $1 && $2;
		push @users, {username => $1, id => $2};
	}

	my @mod;
	for my $user ( @users ) {
		my $id = $user->{id};
		my $schoolid = ucfirst $user->{username};
		my $password = $m{$schoolid}->{password};
		my $firstname = $m{$schoolid}->{name};
		my $email = $m{$schoolid}->{email};
		my $city = $city;
		system("Moosh -n user-mod -i --firstname $firstname --password $password --email $email $id");
		push @mod, {firstname => $firstname, id => $id};
	}
	print "firstname: " . $_->{firstname} . "\tid: " . $_->{id} . "\n" for @mod;
}

1;
