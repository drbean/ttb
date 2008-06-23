#!/usr/bin/perl

use strict;
use warnings;

use YAML qw/ LoadFile DumpFile /;

my $yaml = LoadFile( "$ARGV[0].yaml" );

my @range = @{$yaml->{range}};
my $NewRound;

# have tables hash with index values called tablesWithIndexes
# need  names as well

for my $table ( keys  %{$yaml->{tablesWithIndexes}} )
{
	my @players;
	my @playersAsIndexes;
	for my $id ( @{$yaml->{tablesWithIndexes}->{$table}->{player}} ) 
	{
		warn "$id not defined" 
				unless ( defined $yaml->{names}->{$id} );
		push @players, 
			$yaml->{names}->{$id};
	}
	$NewRound->{tables}->{$table}->{player} = \@players;
}

$NewRound->{tablesWithIndexes} = $yaml->{tablesWithIndexes};
$NewRound->{assistant} = $yaml->{assistant};
$NewRound->{league} = $yaml->{league};
$NewRound->{week} = $yaml->{week};
$NewRound->{round} = $yaml->{round};
$NewRound->{range} = $yaml->{range};
$NewRound->{names} = $yaml->{names};
$NewRound->{index} = $yaml->{index};
$NewRound->{id} = $yaml->{id};
$NewRound->{Warning} = "# This file, $ARGV[0],yaml, was given tables mapping on " . localtime() . " by ids2names.pl" . $yaml->{Warning};

DumpFile( "$ARGV[0].yaml", $NewRound );
