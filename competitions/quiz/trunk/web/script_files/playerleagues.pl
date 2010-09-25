#!perl

use strict;
use warnings;
use lib 'lib';

use Config::General;
use Cwd;
use File::Spec;
use List::MoreUtils qw/all/;
use YAML qw/LoadFile/;
use FindBin qw/$Bin/;
use lib "$Bin/../lib/";

BEGIN {
	my @MyAppConf = glob( "$Bin/../*.conf" );
	die "Which of @MyAppConf is the configuration file?"
				unless @MyAppConf == 1;
	%::config = Config::General->new($MyAppConf[0])->getall;
	$::name = $::config{name};
	require "$::name.pm"; $::name->import;
	require "$::name/Schema.pm"; $::name->import;
}

my $leaguedirs = $::config{leagues};
my @leagueids = qw/GL00006 GL00013 CLA0023 FLA0014 MIA0014 BMA0071 FLA0017 FLA0030/;

no strict qw/subs refs/;
my $connect_info = "${::name}::Model::DB"->config->{connect_info};
# my $connect_info = [ 'dbi:SQLite:db/demo','','' ];
my $schema = "${::name}::Schema"->connect( @$connect_info );
use strict;

my $leagues = [
		[ qw/id name field/ ],
	[ "GL00006", "GL00006日語文共同學制虛擬82班二甲", "中級英文聽說訓練" ],
	[ "GL00013", "GL00013日語文共同學制虛擬82班二乙", "中級英文聽說訓練" ],
	[ "MIA0014", " MIA0014日資管大學二甲", "商用英文實務(一)" ],
	[ "BMA0071", " BMA0071日經管大學二甲", "商用英文實務(一)" ],
	[ "FLA0030", "FLA0030夜應外大學三甲", "英文會話(三)" ],
	[ "FLA0014", "FLA0014夜應外大學二甲", "英文會話(一)" ],
	[ "FLA0017", "FLA0017夜應外大學二甲", "跨文化溝通" ],
	[ "CLA0023", "CLA0023日華文大學二甲", "英文聽力及會話(一)" ],
	];

uptodatepopulate( 'Leagues', $leagues );

my $genres = [
			[ qw/id name/ ],
			[ 1, "intermediate" ],
			[ 2, "business" ],
			[ 3, "intercultural" ],
			[ 4, "access" ],
			[ 5, "upper" ],
		];
uptodatepopulate( 'Genre', $genres );

my $leaguegenres = [
			[ qw/league genre/ ],
			[ "GL00006",	1 ],
			[ "GL00013",	1 ],
			[ "FLA0014",	1 ],
			[ "CLA0023",	1 ],
			[ "FLA0017",	3 ],
			[ "FLA0030",	5 ],
			[ "MIA0014",	2 ],
			[ "BMA0071",	2 ],
		];
uptodatepopulate( 'Leaguegenre', $leaguegenres );

my ($leaguefile, $players);

for my $league ( qw/GL00006 GL00013 CLA0023 FLA0014 MIA0014 BMA0071 FLA0017 FLA0030/ ) {
	$leaguefile = LoadFile "$leaguedirs/$league/league.yaml";
	push @{$players->{$league}},
		map {[ $_->{id}, $_->{name}, $_->{password} ]}
					@{$leaguefile->{member}};
}

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
uptodatepopulate( 'Players', $playerpopulator );

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
uptodatepopulate( 'Members', [ [ qw/league player/ ], 
				@allLeaguePlayers ] );

uptodatepopulate( 'Roles', [ [ qw/id name/ ], 
[ 1, "official" ],
[ 2, "player" ],
[ 3, "amateur" ], ] );

uptodatepopulate( 'Rolebearers', [ [ qw/player role/ ], 
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

=head1 AUTHOR

Dr Bean, C<drbean at (@) cpan dot, yes a dot, org>

=head1 COPYRIGHT


This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
