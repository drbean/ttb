package Moodle::Command::user_mod;

use lib "lib";

use Moodle -command;
use strict;
use warnings;
use YAML qw/Dump LoadFile DumpFile/;
use IO::All;

sub abstract { "moopl user_mod -c 41 -l FLA0003" }
sub description { "Leverage Moosh's user-mod php script to do higher-level moodle user_mod work in perl (set username and idnumber)" }

sub usage_desc { "moodle user_mod -c 41 -l FLA0003" }

sub opt_spec  {
        return (
                ["l=s", "league"]
                , ["c=s", "course id on moodle"]
	);
}


sub execute {
	my ($self, $opt, $args) = @_;

	my ($league) = @$opt{qw/l/};
	my ($course_id) = @$opt{qw/c/};
	my $semester="$ENV{SEMESTER}";

	chdir '/var/www/cgi-bin/moodle';

	unless ( $course_id ) {
		my $course_id = qx/Moosh -n course-list -i "shortname='$league'"/;
		chomp $course_id;
	}

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
		my $cohorter = $m{$schoolid};
		unless ( defined $cohorter ) {
			warn "No user with $schoolid id in $league league";
			next;
		}
		my $password = $m{$schoolid}->{password};
		my $firstname = '"' . $m{$schoolid}->{name} . '"';
		my $email = $m{$schoolid}->{email};
		my $city = $city;
		system("Moosh -n user-mod -i --idnumber $schoolid --firstname $firstname $id");
		push @mod, {firstname => $firstname, id => $id, idnumber => $schoolid};
	}
	print "firstname: " . $_->{firstname} . "\tid: " . $_->{id} . "\tidnumber: " . $_->{idnumber} . "\n" for @mod;
}

1;
