#!perl

use strict;
use warnings;
use lib 'lib';

use Config::General;
use Cwd;
use File::Spec;
use List::Util qw/first/;
use List::MoreUtils qw/all/;
use YAML qw/LoadFile/;

BEGIN {
	my @MyAppConf = glob( '*.conf' );
	die "Which of @MyAppConf is the configuration file?"
				unless @MyAppConf == 1;
	my %config = Config::General->new($MyAppConf[0])->getall;
	$::name = $config{name};
	require "$::name.pm"; $::name->import;
	require "$::name/Schema.pm"; $::name->import;
}

my @leagueids = qw/GL00006 GL00013 CLA0023 FLA0014 MIA0014 BMA0071 FLA0017 FLA0030/;
my $dir = ( File::Spec->splitdir(getcwd) )[-1];
$dir = qr/^(GL000|BMA|FL|MIA|CLA)/ if $dir eq 'dic';
@leagueids = grep m/$dir/, @leagueids;

no strict qw/subs refs/;
my $connect_info = "${::name}::Model::DB"->config->{connect_info};
# my $connect_info = [ 'dbi:SQLite:db/demo','','' ];
my $schema = "${::name}::Schema"->connect( @$connect_info );
use strict;

my ($groupfile, $players, @allLeaguerolebearers);
my @roleIds = ( 'A'..'D' );

for my $id ( @leagueids ) {
	my $league = LoadFile "/home/drbean/class/$id/league.yaml";
	my $members = $league->{member};
	my $lastsession = $league->{series}->[-1];
	my $groups = LoadFile "/home/drbean/class/$id/$lastsession/jigsaw.yaml";
	my $players = $schema->resultset('Player');
	my %rolebearers;
	for my $group ( keys %$groups ) {
		my @members = @{$groups->{$group}};
		for my $n ( 0 .. @members-1 ) {
			my $name = $groups->{$group}->[$n];
			next unless $name;
			my $member = first { $_->{name} eq $name } @$members;
			my $Chinese = $member->{Chinese};
			my $count = $players->count( { name=>$Chinese } );
			die "$name in $id league $group group not a Player"
							unless $count;
			my $playerid = $member->{id};
			my $player = $players->find( { id => $playerid } );
			die "2 ${name}s in $id league, 1 in $group" if
							$rolebearers{$playerid};
			my $role = $roleIds[$n];
			$rolebearers{$playerid} = [ $id, $playerid, $role ];
		}
		push @allLeaguerolebearers, values %rolebearers;
	}
}


uptodatepopulate( 'Jigsawroles', [ [ qw/league player role/ ], 
	# [ 193001, 1 ],
				@allLeaguerolebearers ] );

sub uptodatepopulate
{
	my $class = $schema->resultset(shift);
	my $entries = shift;
	my $columns = shift @$entries;
	foreach my $row ( @$entries )
	{
		my %hash;
		@hash{@$columns} = @$row;
		$class->update_or_create(\%hash);
	}
}


=head1 NAME

script_files/playerleagues.pl.pl - populate leagues, players, members, roles, rolebrarer tables

=head1 SYNOPSIS

perl script_files/playerleagues.pl

=head1 DESCRIPTION

INSERT INTO players (id, name, password) VALUES (?, ?, ?)

=head1 AUTHOR

Dr Bean, C<drbean at (@) cpan dot, yes a dot, org>

=head1 COPYRIGHT


This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
