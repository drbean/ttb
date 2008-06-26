#!/usr/bin/perl

use strict;
use warnings;

use YAML qw/ LoadFile DumpFile /;

my $yaml = LoadFile( "$ARGV[0].yaml" );
DumpFile( "$ARGV[0].yaml.bak", $yaml );

my @range = @{$yaml->{range}};
my $NewRound;

# have group of indexes called groupWithIndexes
# need  names as well

foreach my $group ( keys  %{$yaml->{group}} )
{
	foreach my $player ( @{$yaml->{group}->{$group}} ) 
	{
		die "$player not defined" 
			unless ( defined $yaml->{id}->{$player} );
		push @{$NewRound->{groupWithIndexes}->{$group}}, $yaml->{index}->{$player};
	}
}

$NewRound->{assistant} = $yaml->{assistant};
$NewRound->{gradesheets} = $yaml->{gradesheets};
$NewRound->{group} = $yaml->{group};
$NewRound->{id} = $yaml->{id};
$NewRound->{index} = $yaml->{index};
$NewRound->{league} = $yaml->{league};
$NewRound->{name} = $yaml->{name};
$NewRound->{range} = $yaml->{range};
$NewRound->{round} = $yaml->{round};
# $NewRound->{score} = $yaml->{score};
$NewRound->{texts} = $yaml->{texts};
$NewRound->{week} = $yaml->{week};
$NewRound->{Warning} = "# This file, $ARGV[0],yaml, was given groupwithIndexes on " . localtime() . " by names2indexes.pl" . $yaml->{Warning};

DumpFile( "$ARGV[0].yaml", $NewRound );
