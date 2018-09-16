package Moodle::Command::user_create;

use lib "lib";

use Moodle -command;
use strict;
use warnings;
use Scalar::Util qw/looks_like_number/;

sub abstract { "moopl user_create -s nuu -l FLA0003" }
sub description { "Leverage Moosh's php scripts to do higher-level moodle work in perl" }

sub usage_desc { "moopl user_create -s nuu -l FLA0003" }

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

	my $cohort_name = $semester . $league;
	my $category_id;
	my $field = $l->yaml->{field};
	my $id = $l->yaml->{id};
	my $english = qr/\x{82f1}\x{8a9e}/; # 英語
	if ( $field =~ $english) {
		$category_id = 4;
	}
	elsif ( $id =~ m/BMA00|MIA00|FIA00/ ) {
		$category_id = 8;
	}
	else { die "no course category for $field\n" }

	my $cohort_id;
	#$cohort_id = qx/Moosh cohort-create -c $category_id $cohort_name/;
	#die "$cohort_name cohort already exists? $cohort_id id not number\n"
	#	unless looks_like_number( $cohort_id );
	for my $id ( sort keys %m ) {
		my $lower_id = lcfirst $id;
		my $username = $lower_id;
		my $lastname = $id;
		my $firstname = '"' . $m{$id}->{name} . '"';
		my $email = $m{$id}->{email};
		my $password = $m{$id}->{password};
		my $user_id;
		$user_id = qx/Moosh -n user-create --password $password --email $email --city $city --country TW --firstname $firstname --lastname $id $username/;
		die "$username user already exists? $user_id id not number\n"
			unless looks_like_number( $user_id );
		print "$username: $user_id\t";
		chomp $user_id;
		system("Moosh -n cohort-enrol -u $user_id $cohort_name");
	}


}

1;
