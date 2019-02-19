package Moodle::Command::cohort_enrol;

use lib "lib";

use Moodle -command;
use strict;
use warnings;
use Scalar::Util qw/looks_like_number/;

sub abstract { "moopl cohort_enrol -c 072BMA0047 -l FLA0003" }
sub description { "Leverage Moosh's php scripts to do higher-level moodle work in perl" }

sub usage_desc { "moopl cohort_enrol -c 072BMA0047 -l FLA0003" }

sub opt_spec  {
        return (
                ["c=s", "cohort name"]
                , ["l=s", "league"]
	);
}


sub execute {
	my ($self, $opt, $args) = @_;

	my ($cohort_name, $league) = @$opt{qw/c l/};
	my $semester="$ENV{SEMESTER}";

	use Grades;
	my $l = League->new( leagues => "/home/drbean/$semester", id => $league );
	my $m = $l->members;
	my %m = map { $_->{id} => $_ } @$m;

	#$cohort_id = qx/Moosh cohort-create -c $category_id $cohort_name/;
	my @users;
	for my $id ( sort keys %m ) {
		my $lower_id = lcfirst $id;
		my $username = $lower_id;
		my $lastname = $id;
		my $firstname = '"' . $m{$id}->{name} . '"';
		my $email = $m{$id}->{email};
		my $password = $m{$id}->{password};
		my $user_id;
		my $user_list = qx/Moosh -n user-list "username = '$username'"/;
		my @user_list = split /\n/, $user_list;
		unless ( @user_list == 1 ) {
			if ( @user_list == 0 ) {
				$user_id = qx/Moosh -n user-create --password $password --email $email --city Miaoli --country TW --firstname $firstname --lastname $id $username/;
			die "$username user already exists? $user_id id not number\n"
				unless looks_like_number( $user_id );
			print "new user: $username: $user_id\t";
			chomp $user_id;


			}
			else { die "multiple @users users with $username username\n" }
			
		}
		else {
			( my $user = $user_list ) =~ m/^([a-z]\d*) \((\d*)\)/;
			next unless $1 && $2;
			$user_id = $2;
		}
		system("Moosh -n cohort-enrol -u $user_id $cohort_name");
	}


}



1;
