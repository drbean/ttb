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

my %config = Config::General->new( "tennis.conf" )->getall;
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
my $leagues = [ [ qw/id name description/ ] ];
my $rounds = [ [ qw/league story id swissround start stop/ ] ];
my $now = DateTime->now( time_zone => 'local' );
for my $league ( @leagueids ) {
	$leaguefile = LoadFile "$config{leagues}/$league/league.yaml";
	push @$leagues, [ $league, $leaguefile->{league}, $leaguefile->{field} ];
	push @$rounds, [$league, 'Nothing', 0, 0, $now, $now];
	push @{$players->{$league}},
		map {[ $_->{id}, $_->{Chinese}, $_->{password} ]}
					@{$leaguefile->{member}};
}

find_or_populate( 'Tournament', $leagues );
find_or_populate( 'Rounds', $rounds );

my $genres = [
			[ qw/id value/ ],
			[ 1, "intermediate" ],
			[ 2, "business" ],
			[ 3, "friends" ],
			[ 4, "intercultural" ],
			[ 5, "speaking" ],
			];
#find_or_populate( 'Genre', $genres;

# find_or_populate( 'Leaguegenre', $leaguegenres );

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
find_or_populate( 'Login', $playerpopulator );

my (@allLeaguerolebearers, @allLeaguedraws, @allLeaguePlayers);
foreach my $league ( @leagueids )
{
	my (%members, %draw, %rolebearers);
	next unless $players->{$league} and ref $players->{$league} eq "ARRAY";
	my @players = @{$players->{$league}};
	foreach my $player ( @players )
	{
		$members{$player->[0]} =  [ $league, $player->[0] ];
		$draw{$player->[0]} = 
			[ $league, 0, $player->[0], 0, 'Unknown', 'Unknown' ];
		$rolebearers{$player->[0]} =  [ $player->[0], 2 ];
	}
	push @allLeaguePlayers, values %members;
	push @allLeaguedraws, values %draw;
	push @allLeaguerolebearers, values %rolebearers;
	$members{193001} = [ $league, 193001 ];
}
find_or_populate( 'Member', [ [ qw/tournament player/ ], 
				@allLeaguePlayers ] );
find_or_populate( 'Draw', [ [ qw/tournament round player pair role opponent/ ], 
				@allLeaguedraws ] );

sub find_or_populate
{
	my $class = $schema->resultset(shift);
	my $entries = shift;
	my $columns = shift @$entries;
	foreach my $row ( @$entries )
	{
		my %hash;
		@hash{@$columns} = @$row;
		$class->find_or_create(\%hash);
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
