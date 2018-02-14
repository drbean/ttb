package Moodle::Command::user_create;

use lib "lib";

use Moodle -command;
use strict;
use warnings;
use Scalar::Util qw/looks_like_number/;

sub abstract { "moodle user_create -s nuu -l FLA0003" }
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

	use Grades;
	my $l = League->new( leagues => "/home/drbean/$semester", id => $league );
	my $m = $l->members;
	my %m = map { $_->{id} => $_ } @$m;
	my $city;
	if ( $l->yaml->{school} eq "must" ) {
		$city = "Hsinchu";
	}
	else { $city = "Miaoli";}

	chdir '/var/www/cgi-bin/moodle';

	#my $cohort_name = $league;
	#my $category_id;
	#my $field = $l->yaml->{field};
	#if ( $field =~ m/英語會話/ ) {
	#	$category_id = 4;
	#}
	#elsif ( $field =~ m/商用英文書信實務/ ) {
	#	$category_id = 8;
	#}
	#else { die "no course category for $field\n" }

	#my $cohort_id;
	#$cohort_id = qx/moosh cohort-create -c $category_id $cohort_name/;
	#die "$cohort_name cohort already exists? $cohort_id id not number\n"
	#	unless looks_like_number( $cohort_id );
	for my $id ( qw/U0433118/ ) {
		my $lower_id = lcfirst $id;
		my $username = $lower_id;
		my $lastname = $id;
		my $firstname =$m{$id}->{name};
		my $email = $m{$id}->{email};
		my $password = $m{$id}->{password};
		my $user_id;
		$user_id = qx/Moosh user-create --password $password --email $email --city $city --country "tw" --firstname $firstname --lastname $id $username/;
		#die "$username user already exists? $user_id id not number\n"
		#	unless looks_like_number( $user_id );
		print "$username: $user_id\t";
		#system("Moosh cohort-enrol -u $user_id $cohort_name");
	}


}

1;
