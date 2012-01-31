#!perl

use strict;
use warnings;
use lib 'lib';

use Config::General;
use Cwd;
use File::Spec;
use List::MoreUtils qw/all/;
use YAML qw/LoadFile/;

use Tennis;
use Tennis::Model::DB;
use Tennis::Schema;

my %config = Config::General->new( "bett.conf" )->getall;
my $connect_info = Tennis::Model::DB->config->{connect_info};
my $schema = Tennis::Schema->connect( $connect_info );

my $leaguegenres = [
			[ qw/league genre/ ],
			[ "GL00003",	1 ],
			[ "GL00016",	1 ],
			[ "FLA0015",	1 ],
			[ "FLA0023",	1 ],
			[ "BMA0031",	2 ],
			[ "FIA0012",	2 ],
			[ "MIA0015",	2 ],
			[ "FLA0019",	4 ],
			[ "FLA0028",	5 ],
		];

my @leagueids = map $_->[0], @$leaguegenres[1..$#$leaguegenres];

my ($leaguefile, $players);
my $leagues = [ [ qw/id name field/ ] ];
for my $league ( @leagueids ) {
	$leaguefile = LoadFile "$config{leagues}/$league/league.yaml";
	push @$leagues, [ $league, $leaguefile->{league}, $leaguefile->{field} ];
	push @{$players->{$league}},
		map {[ $_->{id}, $_->{Chinese}, $_->{password} ]}
					@{$leaguefile->{member}};
}

uptodatepopulate( 'League', $leagues );

uptodatepopulate( 'Genre', [
			[ qw/id value/ ],
			[ 1, "intermediate" ],
			[ 2, "business" ],
			[ 3, "friends" ],
			[ 4, "intercultural" ],
			[ 5, "speaking" ],
			] );

uptodatepopulate( 'Leaguegenre', $leaguegenres );

push @{$players->{officials}}, [split] for <<OFFICIALS =~ m/^.*$/gm;
193001	DrBean	ok
OFFICIALS

my %players;
foreach my $league ( 'officials', @leagueids )
{
	next unless $players->{$league} and ref $players->{$league} eq "ARRAY";
	my @players = @{$players->{$league}};
	foreach ( @players )
	{
		$players{$_->[0]} = [ $_->[0], $_->[1], $_->[2] ];
	}
}
my $playerpopulator = [ [ qw/id name password/ ], values %players ];
uptodatepopulate( 'Player', $playerpopulator );

my (@allLeaguerolebearers, @allLeaguePlayers);
foreach my $league ( @leagueids )
{
	my (%members, %rolebearers);
	next unless $players->{$league} and ref $players->{$league} eq "ARRAY";
	my @players = @{$players->{$league}};
	foreach my $player ( @players )
	{
		$members{$player->[0]} =  [ $league, $player->[0] ];
		$rolebearers{$player->[0]} =  [ $player->[0], 2 ];
	}
	push @allLeaguePlayers, values %members;
	push @allLeaguerolebearers, values %rolebearers;
	$members{193001} = [ $league, 193001 ];
}
uptodatepopulate( 'Member', [ [ qw/league player/ ], 
				@allLeaguePlayers ] );

uptodatepopulate( 'Role', [ [ qw/id role/ ], 
[ 1, "official" ],
[ 2, "player" ],
[ 3, "amateur" ], ] );

uptodatepopulate( 'Rolebearer', [ [ qw/player role/ ], 
				[ 193001, 1 ],
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

Actually UPDATE or INSERT. So it can be used when new players are added.

=head1 AUTHOR

Dr Bean, C<drbean at (@) cpan dot, yes a dot, org>

=head1 COPYRIGHT


This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
